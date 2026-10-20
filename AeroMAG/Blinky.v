module blinky(
    input wire clk_25mhz,
    output wire [7:0] led
);
    
    reg [26:0] timer;
    initial timer = 27'd0;

    // clk a(
    //     .clk(clk_25mhz)
    // );

    reg [7:0] state = 8'b01100101;
    
    always @(posedge clk_25mhz)begin
        if(timer == 27'd12500000)begin
            timer <= 0;
            case(state)
                8'b01100101: state <= 8'b01001100;
                8'b01001100: state <= 8'b10011101;
                8'b10011101: state <= 8'b11011001;
                8'b11011001: state <= 8'b01100101;
                default: state <= 8'b01100101;
            endcase
        end
        else begin
            timer <= timer + 1;
        end
    end

    assign led[7:0] = state[7:0];

endmodule