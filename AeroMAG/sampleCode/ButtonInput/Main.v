module main(
    input clk_25mhz,
    output reg [7:0] led,
    inout [27:0] gp
);
    //variable definitions
    wire start;

    enable E1(
        .clk(clk_25mhz),
        .enable(gp[0]),
        .start(start)
    );

    button B1(
        .clk(clk_25mhz),
        .btn(gp[4:1]),
        .start(start),
        .data(led)
    );

endmodule

//module to enable/disable
module enable(
    input clk,
    input enable,
    output reg start
);
    //will start with everything disabled
    initial start = 0;
    
    //button downtime
    reg [28:0] down = 0;

    always @(posedge clk)begin
        //checks every second for a button press
        if(down == 12500000)begin
            down <= 0;
            //if button is pressed and not enabled, will enable
            if(enable && !start)begin
                start <= 1;
            end
            //if button pressed and enabled, will disable
            else if(enable && start)begin
                start <= 0;
            end
        end
        else begin
            down <= down + 1;
        end
    end
endmodule

module button(
    input clk,
    input [3:0] btn,
    input start,
    output reg [7:0] data
);

    always @(posedge clk) begin
        //pulses every half second
        if(start)begin
            if(timer == 24'd6250000)begin
                case(btn)
                    4'b0001: data <= (data << 1) | 1; //left shift and add 1
                    4'b0010: data <= data << 1; //left shift
                    4'b0100: data <= data >> 1; //right shift
                    4'b1000: data <= 8'b00000000; //reset leds
                    default: data <= data;
                endcase
            end
            else begin //timer increment
                timer <= timer + 1;
            end
        end
    end

endmodule