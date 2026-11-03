module main(
    input clk_25mhz,
    input [6:0] btn,
    inout [27:0] gp,
    output [7:0] led,
    output ftdi_rxd
);
    wire [7:0] inpt = {btn[6:3], gp[4:2], 1'd0};
    wire sclk;
    wire start;
    wire [7:0] data;
    wire [7:0] txDat;
    wire ld;
    wire empty;

    parameter BAUD = 9600;
    parameter CLK = 25_000_000;
    localparam HALF = CLK/BAUD/2;
    localparam DB = BAUD/100;

    button B1(
        .clk(clk_25mhz),
        .btn(inpt),
        .start(start),
        .data(led)
    );
    
    sclk S1(
        .clk(clk_25mhz),
        .half(HALF),
        .sclk(sclk)
    );

    enable E1(
        .clk(clk_25mhz),
        .enable(gp[0]),
        .dsable(gp[1]),
        .start(start)
    );

    debounce db(
        .clk(sclk),
        .reset(~btn[0]),
        .db(DB),
        .data(inpt),
        .stable(data)
    );

    txComm #(.W(8)) Co(
        .clk(sclk),
        .reset(~btn[0]),
        .stable(data),
        .empty(empty),
        .txDat(txDat),
        .ld(ld)
    );

    uarttx Tx(
        .clk(sclk),
        .reset(~btn[0]),
        .enable(start),
        .loadDat(ld),
        .data(txDat),
        .out(ftdi_rxd),
        .empty(empty)
    );
endmodule

module button(
    input clk,
    input [7:0] btn,
    input start,
    output reg [7:0] data
);

    always @(posedge clk)begin
        if(start)begin
            data <= btn;
        end
    end
endmodule

module sclk(
    input clk,
    input [31:0] half,
    output reg sclk
);
    reg [24:0] timer = 0;

    initial sclk = 0;

    always @(posedge clk)begin
        if(timer == half - 1)begin
            timer <= 0;
            sclk <= ~sclk;
        end
        else begin
            timer <= timer + 1;
        end
    end
endmodule

module enable(
    input clk,
    input enable,
    input dsable,
    output reg start
);
    reg test = 0;
    reg [28:0] downTime = 0;

    initial start = 0;
    always @(posedge clk)begin
        if(downTime == 12500000)begin
            downTime <= 0;
            if(enable && !start)begin
                start <= 1;
            end
            else if(enable && start)begin
                start <= 0;
            end
        end
        else begin
            downTime <= downTime + 1;
        end
    end
endmodule

module debounce(
    input clk,
    input reset,
    input [31:0] db,
    input [7:0] data,
    output reg [7:0] stable
);
    reg [7:0] sync0;
    reg [7:0] sync1;
    reg [7:0] sample;
    reg [10:0] cnt;
    always @(posedge clk)begin
        if(reset)begin
            sync0 <= 0;
            sync1 <= 0;
            sample <= 0;
            stable <= 0;
            cnt <= 0;
        end
        else begin
            sync0 <= data;
            sync1 <= sync0;
            if(sync1 != sample)begin
                sample <= sync1;
                cnt <= 0;
            end
            else if(cnt < db)begin
                cnt <= cnt + 1;
            end
            else begin
                stable <= sample;
            end
        end
    end
endmodule

module txComm #(parameter W = 8)(
    input clk,
    input reset,
    input [W-1:0] stable,
    input empty,
    output reg [7:0] txDat,
    output ld
);
    reg sending = 0;
    reg [3:0] idx = 0;
    reg [W-1:0] snapshot = 0;
    reg [W-1:0] lastSent = 0;

    assign ld = sending && empty;

    // W bit characters (MSB first), then CR, then LF
    always @(*) begin
        if (idx < W)       txDat = snapshot[W-1-idx] ? "1" : "0";
        else if (idx == W) txDat = 8'h0D;
        else               txDat = 8'h0A;
    end

    always @(posedge clk) begin
        if (reset) begin
            sending  <= 0;
            idx      <= 0;
            lastSent <= 0;
        end
        else if (!sending) begin
            if(stable == 0) begin
                lastSent <= 0;
            end
            else if (stable != lastSent) begin
                snapshot <= stable;
                lastSent <= stable;
                idx      <= 0;
                sending  <= 1;
            end
        end
        else if (empty) begin              // ld is high this cycle, uarttx grabs txDat
            if (idx == W + 1) sending <= 0;
            idx <= idx + 1;
        end
    end
endmodule

module uarttx(
    input clk,
    input reset,
    input enable,
    input loadDat,
    input [7:0] data,
    output reg out,
    output reg empty
);
    reg [7:0] register;
    reg [3:0] counter;
    reg sending = 0;

    always @(posedge clk)begin
        if(reset)begin
            out <= 1;
            empty <= 1;
            register <= 0;
            counter <= 0;
        end
        else if(!sending)begin
            out <= 1;
            if(loadDat && empty)begin
                register <= data;
                empty <= 0;
                sending <= 1;
                counter <= 0;
            end
        end
        else begin
            if(counter == 0)begin
                out <= 0;
            end
            else if(counter < 9)begin
                out <= register[counter - 1];
            end
            else begin
                out <= 1;
            end
            if(counter == 9)begin
                sending <= 0;
                empty <= 1;
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
endmodule