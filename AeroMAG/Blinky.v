module blinky(
    input clk_25mhz,
    output [7:0] led
);
    
    //initialize timer variable @ t=0
    reg [26:0] timer;
    initial timer = 27'd0;

    // clk a(
    //     .clk(clk_25mhz)
    // );

    //initialize the current state that the LED will be set to
    reg [7:0] state = 8'b01100101;
    
    //change the state of the LED (what it will be set to)
    always @(posedge clk_25mhz)begin
        //pulses every 1 second
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
        //increment the timer variable
        else begin
            timer <= timer + 1;
        end
    end

    //set the LED state
    assign led[7:0] = state[7:0];

endmodule