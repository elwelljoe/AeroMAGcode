module spi(
    input clk,
    input [7:0] data,
    input start,
    output reg sclk,
    output reg mosi,
    output reg cs,
    output [7:0] miso_data
);

    reg [7:0] shift_register;
    reg [2:0] bit_counter = 3'd0;

    initial shift_register = 8'b0;

    always @(posedge clk)begin
        if(start)begin
            cs <= 0;
            shift_register <= data;
            bit_counter <= 0;
        end
        if(!cs)begin
            sclk <= ~sclk;
            if(sclk)begin
                mosi <= shift_register[7];
                shift_register <= {shift_register[6:0], miso_data};
                bit_counter <= bit_counter + 1;
                if(bit_counter == 7)begin
                    cs <= 1;
                end
            end
        end
    end

    assign miso_data = shift_register;

endmodule