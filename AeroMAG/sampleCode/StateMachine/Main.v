module(
    input clk_25mhz,
    output reg [7:0] led
);

    //initializations
    reg[23:0] timer;
    reg[1:0] state;
    initial begin
        timer = 24'd0;
        led = 0;
        state = 2'd0;
    end

    always @(posedge clk_25mhz) begin
        if(timer == 24'd6250000)begin
        
            //state machine
            case(state)
                0: begin //all off
                    led <= 8'b00000000;
                end

                1: begin //first half on
                    led <= 8'b00001111;
                end

                2: begin //second half on
                    led <= 8'b11110000;
                end

                3: begin //all on
                    led <= 8'b11111111;
                end
            endcase

            //increment state
            state <= state + 1;
            //reset to first state
            if(state == 3)begin
                state <= 0;
            end   
        end
        else begin //timer increment
            timer <= timer + 1;
        end
    end
endmodule