module fpga_power(
    input clk_25mhz,
    output wire [7:0] led
);
    reg [7:0] var;
    wire SCLK;
    reg [28:0] counter;
    initial var = 8'd1;
    initial counter = 29'd0;

    startup SU(
        .clk_25mhz(clk_25mhz),
        .led(led)
    );

    always @(posedge clk_25mhz) begin
        if(counter < 28'd25000000) begin
            counter <= counter + 1;
        end
        else begin
            var <= var << 1;
            counter <= 0;
            if(var >= 8'b10000000) begin
                var <= 8'b1;
            end
        end
    end
    assign led[7:0] = var[7:0];
endmodule