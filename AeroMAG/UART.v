module main(
    input clk_25mhz,
    input [27:0] gp,
    input [6:0] btn,
    output ftdi_rxd
);
    reg [3:0] resetCnt = 4'd0;
    reg [1:0] resetSync = 2'd0;
    reg [7:0] sync0 = 0, sync1 = 0, sample = 0, stable = 0;
    reg [15:0] dbCnt = 0;
    reg [7:0] snapshot  = 0;
    reg [7:0] last_sent = 8'hFF;
    reg [2:0] idx = 0;
    reg sending = 0;

    wire por = (resetCnt != 4'hF);
    wire btnReset = resetSync[1];
    wire reset = por | btnReset;
    wire [7:0] data;
    wire sclk;
    wire empty;
    wire ld = sending && empty;

    parameter clk_Hz = 25_000_000;
    parameter BAUD = 9600;

    localparam HALF = clk_Hz/BAUD/2;
    localparam DB = BAUD/100;

    sensor S1(
        .clk(clk_25mhz),
        .btn(btn[4:1]),
        .test(data)
    );

    baudClk B1(
        .clk(clk_25mhz),
        .HALF(HALF),
        .sclk(sclk)
    );

    uarttx Tx(
        .reset(reset),
        .clk(sclk),
        .loadDat(ld),
        .enable(btn[1]),
        .out(ftdi_rxd),
        .data(tx_byte),
        .empty(empty)
    );

    always @(posedge clk_25mhz) begin
        resetSync <= {resetSync[0], ~btn[0]};
        if(por)begin
            resetCnt <= resetCnt + 1;
        end
    end

    always @(posedge sclk) begin
        if(reset) begin
            sync0 <= 0;
            sync1 <= 0;
            sample <= 0;
            stable <= 0;
            dbCnt <= 0;
        end
        else begin
            sync0 <= data;
            sync0 <= sync0;
            if(sync1 != sample)begin
                sample <= sync1;
                dbCnt <= 0;
            end
            else if(dbCnt < DB)begin
                dbCnt <= dbCnt + 1;
            end
            else begin
                stable <= sample;
            end
        end
    end

    function [7:0] hex(input [3:0] n);
        hex = (n < 10) ? 8'h30 + n : 8'h37 + n;
    endfunction

    reg [7:0] tx_byte;
    always @(*) begin
        case (idx)
            0: tx_byte = hex(snapshot[7:4]);
            1: tx_byte = hex(snapshot[3:0]);
            2: tx_byte = 8'h0D;
            default: tx_byte = 8'h0A;
        endcase
    end

    always @(posedge sclk) begin
        if (reset) begin
            sending <= 0; 
            idx <= 0; 
            last_sent <= 8'hFF;
        end 
        else if (!sending) begin
            if (stable != last_sent) begin
                snapshot <= stable;
                last_sent <= stable;
                idx <= 0;
                sending <= 1;
            end
        end 
        else if (empty) begin
            if (idx == 3) sending <= 0;
            idx <= idx + 1;
        end
    end
endmodule

module sensor(
    input clk,
    input [3:0] btn,
    output reg [7:0] test
);
    always @(posedge clk)begin
        test <= {4'h8,~btn[3:0]};
    end
endmodule

module control(
    input clk,
    input [7:0] btn,
    output reg [7:0] data
);
    always @(posedge clk)begin
        data <= ~btn;
    end
endmodule

module baudClk(
    input clk,
    input [31:0] HALF,
    output reg sclk
);
    reg [10:0] div = 0;
    initial sclk = 0;

    always @(posedge clk)begin
        if(div == HALF - 1)begin
            div <= 0;
            sclk <= ~sclk;
        end
        else begin
            div <= div + 1;
        end
    end
endmodule

module uartrx(
    input reset,
    input clk,
    input unloadDat,
    input enable,
    input in,
    output reg [7:0] data,
    output reg empty
);

    reg [7:0] rx_reg;
    reg [3:0] rx_sample_cnt;
    reg [3:0] rx_cnt;
    reg rx_frame_err;
    reg rx_over_run;
    reg rx_d1;
    reg rx_d2;
    reg rx_busy;

    always @(posedge clk or posedge reset)
        if(reset) begin
            //resets all values
            rx_reg <= 0;
            data <= 0;
            rx_sample_cnt <= 0;
            rx_cnt <= 0;
            rx_frame_err <= 0;
            rx_over_run <= 0;
            empty <= 1;
            rx_d1 <= 1;
            rx_d2 <= 1;
            rx_busy <= 0;
        end
        else begin
            //syncs d1 and d2 to the register
            rx_d1 <= rx_reg;
            rx_d2 <= rx_d1;
            if(unloadDat) begin
                //show that rx is empty and set the data from register
                data <= rx_reg;
                empty <= 1;
            end
            if(enable) begin
                //tests if rx is busy and d2 is 0
                if(!rx_busy && !rx_d2) begin
                    //logs rx as busy and starts the sampling and counting
                    rx_busy <= 1;
                    rx_sample_cnt <= 1;
                    rx_cnt <= 0;
                end
                if(rx_busy) begin
                    //incriments sample count until it reaches 7
                   rx_sample_cnt <= rx_sample_cnt+1;
                   if(rx_sample_cnt == 7) begin
                        if((rx_d2 == 1) && (rx_cnt == 0)) begin
                            //clear busy lable
                            rx_busy <= 0;
                        end
                        else begin
                            //count clock cycles until it hits 9
                            rx_cnt <= rx_cnt + 1;
                            if(rx_cnt > 0 && rx_cnt < 9)begin
                                //sets register at the count-1 to d2
                                rx_reg[rx_cnt-1] <=rx_d2;
                            end
                            if(rx_cnt == 9)begin
                                //marks rx as not busy
                                rx_busy <= 0;
                                if(rx_d2 == 0) begin
                                    //marks as an error
                                    rx_frame_err <= 1;
                                end
                                else begin
                                    //lables rx as full
                                    empty <= 0;
                                    rx_frame_err <= 0;
                                    //if empty is 1 rx isnt overrun, otherwise it is
                                    rx_over_run <= (empty) ? 0:1;
                                end
                            end
                        end
                   end
                end
            end
            if(!enable)begin
                //marks rx as not busy if enable is 0
                rx_busy <= 0;
            end
        end
endmodule

module uarttx(
    input reset,
    input enable,
    input clk,
    input loadDat,
    input [7:0] data,
    output reg out,
    output reg empty
);

    reg [7:0] tx_reg;
    reg tx_over_run;
    reg [3:0] tx_cnt;

    always @(posedge clk or posedge reset)
        if(reset) begin
            //resets everything
            tx_reg <= 0;
            empty <= 1;
            tx_over_run <= 0;
            out <= 1;
            tx_cnt <= 0;
        end
        else begin
            if(loadDat)begin
                if(!empty)begin
                    //shows tx isn't overrun
                    tx_over_run <= 0;
                end
                else begin
                    //sets the register
                    tx_reg <= data;
                    //marks tx as full
                    empty <= 0;
                end
            end
            if(enable && !empty)begin
                //starts a count for tx
                tx_cnt <= tx_cnt + 1;
                if(tx_cnt == 0)begin
                    //shows theres no output for tx
                    out <= 0;
                end
                if(tx_cnt > 0 && tx_cnt < 9)begin
                    //sets output to the register at some count-1
                    out <= tx_reg[tx_cnt - 1];
                end
                if(tx_cnt == 9)begin
                    //allows tx to output
                    out <= 1;
                    //resets counter
                    tx_cnt <= 0;
                    //marks tx as empty
                    empty <= 1;
                end
            end
            if(!enable)begin
                //stops tx from counting if tx is not enabled
                tx_cnt <= 0;
            end
        end
endmodule
