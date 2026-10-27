module blinking(
    input clk_25mhz,
    output [7:0] led
);

    //initialize timer
    reg [23:0] timer;
    initial timer = 24'd0;

    initial led = 0;g

    //main loop
    always @(posedge clk_25mhz) begin
        //pulses every half second
        if(timer == 24'd6250000)begin
            timer <= 0;
            //if all are on turn them off
            if(led == 8'b11111111)begin
                led <= 0;
            end
            //turns lights on one at a time until all are on
            else begin
                led <= (led << 1) | 1;
            end
        end
        //timer increment
        else begin
            timer <= timer + 1;
        end
    end
endmodule