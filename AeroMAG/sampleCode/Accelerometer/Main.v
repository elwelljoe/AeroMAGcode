module main;
    reg clk;
    wire din;
    reg dout;
    wire cs;

    always #5 clk = ~clk;

    accelerometer a1(
        .clk_25mhz(clk),
        .din(din),
        .dout(dout),
        .cs(cs)
    );

    initial begin
        $dumpfile("Output.vcd");
        $dumpvars(0, main);

        dout = 1;
        #500;

        $finish;
    end

endmodule