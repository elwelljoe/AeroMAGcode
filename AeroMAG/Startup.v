module startup(
    input clk_25mhz,
    output wire [7:0] led
);
    
    reg [7:0] temp;
    reg [28:0] counter;
    initial counter = 29'd0;
    initial temp = 8'd0;

    always @(posedge clk_25mhz)begin
        if(counter == 28'd12500000) begin
            counter <= 0;
            temp <= (temp << 1) | 1'b1;
            if(temp == 8'b11111111)begin
                temp <= 1;
            end
        end
        else begin
            counter <= counter + 1;
        end
    end

    assign led[7:0] = temp[7:0];

endmodule