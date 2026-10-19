module uart (
    //defines inputs and outputs
    input reset,
    input tx_clk,
    input ld_tx_data,
    input [7:0] tx_data,
    input tx_enable,
    output reg tx_out,
    output reg tx_empty,
    input rx_clk,
    input uld_rx_data,
    output reg [7:0] rx_data,
    input rx_enable,
    input rx_in,
    output reg rx_empty
);
    //defines dummy variables that don't change through the program
    reg [7:0] tx_reg;
    reg tx_over_run;
    reg [3:0] tx_cnt;
    reg [7:0] rx_reg;
    reg [3:0] rx_sample_cnt;
    reg [3:0] rx_cnt;
    reg rx_frame_err;
    reg rx_over_run;
    reg rx_d1;
    reg rx_d2;
    reg rx_busy;
    reg clk;

    //calls clock function
    slow_clk a(
        .CLK(clk),
        .SCLK(rx_clk)
    );

    slow_clk b(
        .CLK(clk),
        .SCLK(tx_clk)
    );

    //runs program every time the cloc is rising or reset is one
    always @(posedge rx_clk or posedge reset)
        if(reset) begin
            //resets all values
            rx_reg <= 0;
            rx_data <= 0;
            rx_sample_cnt <= 0;
            rx_cnt <= 0;
            rx_frame_err <= 0;
            rx_over_run <= 0;
            rx_empty <= 1;
            rx_d1 <= 1;
            rx_d2 <= 1;
            rx_busy <= 0;
        end
        else begin
            //syncs d1 and d2 to the register
            rx_d1 <= rx_reg;
            rx_d2 <= rx_d1;
            if(uld_rx_data) begin
                //show that rx is empty and set the data from register
                rx_data <= rx_reg;
                rx_empty <= 1;
            end
            if(rx_enable) begin
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
                                    rx_empty <= 0;
                                    rx_frame_err <= 0;
                                    //if empty is 1 rx isnt overrun, otherwise it is
                                    rx_over_run <= (rx_empty) ? 0:1;
                                end
                            end
                        end
                   end
                end
            end
            if(!rx_enable)begin
                //marks rx as not busy if enable is 0
                rx_busy <= 0;
            end
        end

    //on every positive edge of tx_clk or reset
    always @(posedge tx_clk or posedge reset)
        if(reset) begin
            //resets everything
            tx_reg <= 0;
            tx_empty <= 1;
            tx_over_run <= 0;
            tx_out <= 1;
            tx_cnt <= 0;
        end
        else begin
            if(ld_tx_data)begin
                if(!tx_empty)begin
                    //shows tx isn't overrun
                    tx_over_run <= 0;
                end
                else begin
                    //sets the register
                    tx_reg <= tx_data;
                    //marks tx as full
                    tx_empty <= 0;
                end
            end
            if(tx_enable && !tx_empty)begin
                //starts a count for tx
                tx_cnt <= tx_cnt + 1;
                if(tx_cnt == 0)begin
                    //shows theres no output for tx
                    tx_out <= 0;
                end
                if(tx_cnt > 0 && tx_cnt < 9)begin
                    //sets output to the register at some count-1
                    tx_out <= tx_reg[tx_cnt - 1];
                end
                if(tx_cnt == 9)begin
                    //allows tx to output
                    tx_out <= 1;
                    //resets counter
                    tx_cnt <= 0;
                    //marks tx as empty
                    tx_empty <= 1;
                end
            end
            if(!tx_enable)begin
                //stops tx from counting if tx is not enabled
                tx_cnt <= 0;
            end
        end

endmodule

module slow_clk(
    input CLK,
    output reg SCLK
);
    reg [28:0] count = 0; //sets a counter register
    initial SCLK = 0; //initializes sclk to 0

    always @(posedge CLK) // ensures the function always starts on a rising edge of the clock
        begin
            if(count < 7) //ensures the timing of each state change
                begin
                    count <= count+1; //iterates the count
                end
            else
                begin
                    count <= 0; //sets count to 0
                    SCLK <= ~SCLK; //inverts sclk
                end
        end

endmodule