module adc(
    //defining inputs and outputs
    input clk_25mhz, //assigning the clock to the on board clock
    inout [27:0] gp, //assigning input and output values for the board
    output reg [7:0] led //assigning output bits to leds
);
    //defining module local paramaters
    localparam PERIOD = 21'd1500000; //defines the wait period until the sensor triggers
    localparam TRIG_CYCLES = 9'd249; //defines how many cycles each trigger takes

    //defining distance paramaters
    localparam D10 = 21'd8192;
    localparam D20 = 21'd16384;
    localparam D30 = 21'd24576;
    localparam D40 = 21'd32768;
    localparam D50 = 21'd40960;
    localparam D60 = 21'd49152;
    localparam D70 = 21'd57344;

    //defines states for state machine
    localparam IDLE = 2'd0;
    localparam TRIGGER = 2'd1;
    localparam WAIT_ECHO = 2'd2;
    localparam MEASURE = 2'd3;

    //defines initial state
    reg [1:0] state = IDLE;

    //defining and initializing variables
    reg trig = 1'b0; //trigger to start signal generation
    reg [20:0] period_count = 0; //timer for idle state
    reg [8:0] trig_count = 0; 
    reg [20:0] echo_count = 0;
    reg [20:0] echo_tick = 0;
    reg [20:0] timeout_count = 0;
    wire echo_in;

    //assigning inputs and outputs
    assign gp[8] = trig;
    assign echo_in = gp[17];

    always @(posedge clk_25mhz)begin //checks if the clock is on the positive edge
        case(state) //starts an fsm similar to python
            IDLE:begin //idle state
                trig <= 1'b0; //trigger reset

                if(period_count >= PERIOD - 1)begin
                    //resetting values and initiating a trigger
                    period_count <= 0;
                    trig_count <= 0;
                    trig <= 1;
                    //moves to trigger state
                    state <= TRIGGER; 
                end
                else begin
                    //incriments period count every rising clock edge
                    period_count <= period_count + 1;
                end
            end

            TRIGGER: begin //trigger state
                if(trig_count >= TRIG_CYCLES) begin
                    //resetting variables
                    trig <= 0;
                    trig_count <= 0;
                    timeout_count <= 0;
                    //moving to wait state
                    state <= WAIT_ECHO;
                end
                else begin
                    //incrimenting trig_count
                    trig_count <= trig_count + 1;
                end
            end

            WAIT_ECHO: begin //wait state
                if(echo_in) begin //if echo senses something
                    //resets values
                    echo_count <= 0;
                    timeout_count <= 0;
                    //moves to measure state
                    state <= MEASURE;
                end
                else if(timeout_count >= PERIOD - 1) begin
                    //resets variables
                    echo_tick <= 0;
                    period_count <= 0;
                    timeout_count <= 0;
                    //moves to idle state
                    state <= IDLE;
                end
                else begin
                    //incriments the time count to stall the state switc
                    timeout_count <= timeout_count + 1;
                end
            end

            MEASURE: begin //measure state
                if(!echo_in) begin //if echo doesn't sense anything
                    //assigns the counts to the ticks
                    echo_tick <= echo_count;
                    //resets count variables
                    period_count <= 0;
                    timeout_count <= 0;
                    //moves to idle state
                    state <= IDLE;
                end
                else if(timeout_count >= PERIOD - 1) begin
                    //resets ticks and count variables
                    echo_tick <= 0;
                    period_count <= 0;
                    timeout_count <= 0;
                    //moves to idle state
                    state <= IDLE;
                end
                else begin
                    //increments counts for measurement
                    echo_count <= echo_count + 1;
                    //increments counter for pausing between each measurement
                    timeout_count <= timeout_count + 1;
                end
            end

            default: begin //defines default state
                state <= IDLE;
                trig <= 0;
            end

        endcase
    end

    always @(*) begin //sets these values constantly
        //sets led power based on distance
        if(echo_tick == 0)begin
            led = 8'b00000000;
        end
        else if(echo_tick <= D10)begin
            led = 8'b00000001;
        end
        else if(echo_tick <= D20)begin
            led = 8'b00000011;
        end
        else if(echo_tick <= D30)begin
            led = 8'b00000111;
        end
        else if(echo_tick <= D40)begin
            led = 8'b00001111;
        end
        else if(echo_tick <= D50)begin
            led = 8'b00011111;
        end
        else if(echo_tick <= D60)begin
            led = 8'b00111111;
        end
        else if(echo_tick <= D70)begin
            led = 8'b01111111;
        end
        else begin
            led = 8'b11111111;
        end
    end

endmodule