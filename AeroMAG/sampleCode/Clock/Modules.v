module traffic_light(
    input [1:0] SW, //labeling sw as a 2 bit input
    input clk, //labeling clk as a 1 bit input
    output [3:0] LD, //labeling ld as a 4 bit input
    output red, yellow, green //labeling colors as 1 bit outputs
);

    reg [1:0] state = 2'b00; //defining initial state
    wire SCLK, x, A; //1 bit wires for outputs
    wire S0, S0_, S1, S1_, S2, S2_; //1 bit wires for outputs
    wire S0_new, S1_new; //1 bit wires for outputs

    slow_clk slow(  //calling clock function
        .CLK(clk), //passing clk to function
        .SCLK(SCLK) //passing sclk to function
    );

    always @(posedge SCLK) begin //enables begin always on rising edge
        if(SW[0]) begin //sesting it glitched
            state <= 2'b00; //fail state of red
        end
        else begin
            case(state) //setting up state machine
                2'b00: state <= 2'b01; //if red go to green
                2'b01: state <= 2'b10; //if green go to yellow
                2'b10: state <= 2'b00; //if yellow go back to red
                default: state <= 2'b00; //defaults to red
            endcase //this cycles in order and must have each case point to another case so nothing breaks
        end
    end

    assign red = (state == 2'b00); //assigns a state to red
    assign yellow = (state == 2'b10); //assigns a state to yellow
    assign green = (state == 2'b01); //assigns a state to green

    //assigning values to ld to simulate later
    assign LD[3] = SCLK; 
    assign LD[2] = state[1];
    assign LD[1] = state[0];
    assign LD[0] = SW[0];

endmodule

module slow_clk(
    input CLK,
    output reg SCLK
);
    reg [28:0] count = 0; //sets a counter register
    initial SCLK = 0; //initializes sclk to 0

    always @(posedge CLK) // ensures the function always starts on a rising edge of the clock
        begin
            if(count < 7) //ensures the timing of each state change
                begin
                    count <= count+1; //iterates the count
                end
            else
                begin
                    count <= 0; //sets count to 0
                    SCLK <= ~SCLK; //inverts sclk
                end
        end

endmodule