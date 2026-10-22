module main;
    reg clk;
    reg [7:0] data;
    reg start;
    wire sclk;
    wire mosi;
    wire [7:0] miso_data;

    initial clk = 0;
    always #1 clk <= ~clk;

    spi S1(
        .clk(clk),
        .data(data),
        .start(start),
        .sclk(sclk),
        .mosi(mosi),
        .miso_data(miso_data)
    );

    initial begin
        $dumpfile("Output.vcd");
        $dumpvars(0, main);

        start = 1'b1;
        data = 8'b10110011;
        #4;

        start = 1'b1;
        data = 8'b10001011;
        #5;

        start = 1'b1;
        data = 8'b10110100;
        #5;

        start = 1'b1;
        data = 8'b11101001;
        #5;

        $finish;
    end
endmodule