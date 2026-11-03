module main(
    input clk_25mhz,
    output reg [7:0] led
);

    //initializations
    reg[24:0] timer;
    reg[1:0] state;
    initial begin
        timer = 25'd0;
        led = 0;
        state = 2'd0;
    end

    always @(posedge clk_25mhz) begin
        if(timer == 25'd6250000)begin
            timer <= 0;
            //state machine
            case(state)
                0:begin
                    led <= 8'b00000000;
                end 

                1:begin
                    led <= 8'b00001111;
                end

                2:begin
                    led <= 8'b11110000;
                end

                3:begin
                    led <= 8'b11111111;
                end
            endcase
            state <= state + 1;
            if(state == 3)begin
                state <= 0;
            end
        end
        else begin //timer increment
            timer <= timer + 1;
        end
    end
endmodule