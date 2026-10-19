module main;
    //declairs values for tracking
    reg reset, tx_clk, ld_tx_data;
    reg [7:0] tx_data; //8 bits
    reg tx_enable;
    wire tx_out, tx_empty;
    reg rx_clk, uld_rx_data;
    wire [7:0] rx_data;
    reg rx_enable, rx_in;
    wire rx_empty;

    //calls module
    uart uut(
        .reset(reset),
        .tx_clk(tx_clk),
        .ld_tx_data(ld_tx_data),
        .tx_data(tx_data),
        .tx_enable(tx_enable),
        .tx_out(tx_out),
        .tx_empty(tx_empty),
        .rx_clk(rx_clk),
        .uld_rx_data(uld_rx_data),
        .rx_data(rx_data),
        .rx_enable(rx_enable),
        .rx_in(rx_in),
        .rx_empty(rx_empty)
    );

    initial begin
        //dumps files for simulation (that doesn't work)
        $dumpfile("UART.vcd");
        //dumps variables
        $dumpvars(0, main);
        
        //sets initial values
        reset = 1'b0;
        uld_rx_data = 1'b1;
        rx_enable = 1'b1;
        //runs simulation for 5 seconds
        #500;

        $finish;
    end

endmodule