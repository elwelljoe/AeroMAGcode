module startup;

endmodule

module fpga_power;

endmodule

module read;

endmodule

module clk(
    input CLK,
    output reg SCLK
);
    wire val;
    reg [28:0] count;
    initial SCLK = 0;

    assign val = 50;

    always @(posedge CLK) begin
        if(count < val) begin
            count <= count + 1;
        end
        else begin
            count <= 0;
            SCLK <= ~SCLK;
        end

    end
endmodule

module blinky(
    input clk,
    input glitch,
    output [7:0] LD,
    output wifi_gpio
);

    reg [7:0] state = 8'b00000000;
    wire SCLK;

    clk c(
        .CLK(clk),
        .SCLK(SCLK)
    );

    always @(posedge clk)begin
        if(glitch == 0) begin
            state <= 8'b00000000;
        end
        else begin
            case(state)
                8'b01100101: state <= 8'b01001100;
                8'b01001100: state <= 8'b10011101;
                8'b10011101: state <= 8'b11011001;
                8'b11011001: state <= 8'b01100101;
                default: state <= 8'b01100101;
            endcase
        end
    end

    assign LD[0] = state[0];
    assign LD[1] = state[1];
    assign LD[2] = state[2];
    assign LD[3] = state[3];
    assign LD[4] = state[4];
    assign LD[5] = state[5];
    assign LD[6] = state[6];
    assign LD[7] = state[7];

endmodule
