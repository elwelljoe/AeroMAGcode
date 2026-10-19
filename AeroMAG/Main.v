module main;
    reg clk, glitch;
    wire sclk, WG;
    wire [7:0] LD;

    clk a(
        .CLK(clk),
        .SCLK(SCLK)
    );

    blinky b(
        .clk(SCLK),
        .LD(LD),
        .wifi_gpio(WG),
        .glitch(glitch)
    );

    initial glitch = 1;
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("AeroMAGSim.vcd");
        $dumpvars(0, main);

        #200;

        $finish;
    end

endmodule
