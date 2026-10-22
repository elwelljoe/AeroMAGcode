module main(
    input clk_25mhz,
    input [6:0] btn,
    output [7:0] led,
    inout [26:0] gp
);
    wire power;
    wire test;

    startup S1(
        .clk(clk_25mhz),
        .pout(gp[10:9]),
        .test(test)
    );

    fpga_power P1(
        .clk(clk_25mhz),
        .power(power),
        .test(test)
    );

    inpt I1(
        .clk(clk_25mhz),
        .pin(gp[7:4]),
        .pout(gp[3:0]),
        .power(power),
        .test(test)
    );
    
    distance_sensor D1(
        .clk(clk_25mhz),
        .pin(gp[17:8]),
        .ld(led),
        .power(power),
        .test(test)
    );

endmodule

module startup(
    input clk,
    output reg test,
    output [1:0] pout
);
    
    reg [1:0] temp;
    reg [28:0] counter;
    reg [7:0] count;
    initial counter = 29'd0;
    initial temp = 2'd0;

    initial test = 0;

    always @(posedge clk)begin
        if(test == 0) begin
            if(counter == 29'd12500000)begin
                counter <= 0;
                if(count == 8'd16) begin
                    temp <= 2'b10;
                    test <= 1;
                end
                else begin
                    temp[0] <= ~temp[0];
                    count<= count + 1;
                end
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

    assign pout = temp;

endmodule

module pins(
    input clk,
    input sense,
    output pin
);
    reg data;

    always @(posedge clk) begin
        if(sense == 0)begin
            data <= 1;
        end
        else begin
            data <= 0;
        end
    end

    assign pin = data;

endmodule

module inpt(
    input clk,
    input [3:0] pin,
    input power,
    input test,
    output [3:0] pout

);
    reg [3:0] temp = 4'b0;

    always @(posedge clk)begin
        if(power == 1 && test == 1)begin
            temp <= pin;
        end
        else begin
            temp <= 0;
        end
    end

    assign pout = temp;

endmodule

module fpga_power(
    input clk,
    input test,
    output power
);  

    reg [30:0] counter;
    reg temp;

    always @(posedge clk)begin
        if(test == 1)begin
            if(temp == 1 && counter == 30'd12500000)begin
                counter <= 30'd0;
                temp <= 0;
            end
            else if(temp == 0 && counter == 30'd12500000)begin
                counter <= 30'b0;
                temp <= 1;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

    assign power = temp;

endmodule

module distance_sensor(
    input clk,
    inout [9:0] pin,
    input power,
    input test,
    output reg [7:0] ld
);
    localparam PERIOD = 21'd1500000;
    localparam TRIG_CYCLES = 9'd249;

    localparam D10 = 21'd8192;
    localparam D20 = 21'd16384;
    localparam D30 = 21'd24576;
    localparam D40 = 21'd32768;
    localparam D50 = 21'd40960;
    localparam D60 = 21'd49152;
    localparam D70 = 21'd57344;
    localparam Cutoff = 21'd65536;

    localparam IDLE = 2'd0;
    localparam TRIGGER = 2'd1;
    localparam WAIT_ECHO = 2'd2;
    localparam MEASURE = 2'd3;

    reg [1:0] state = IDLE;

    reg trig = 1'b0;
    reg [20:0] period_count = 0;
    reg [8:0] trig_count = 0; 
    reg [20:0] echo_count = 0;
    reg [20:0] echo_tick = 0;
    reg [20:0] timeout_count = 0;
    wire echo_in;

    assign pin[0] = trig;
    assign echo_in = pin[9];

    always @(posedge clk)begin
        if(power == 1 && test == 1)begin
            case(state)
                IDLE:begin 
                    trig <= 1'b0;

                    if(period_count >= PERIOD - 1)begin
                        period_count <= 0;
                        trig_count <= 0;
                        trig <= 1;
                        state <= TRIGGER; 
                    end
                    else begin
                        period_count <= period_count + 1;
                    end
                end

                TRIGGER: begin
                    if(trig_count >= TRIG_CYCLES) begin
                        trig <= 0;
                        trig_count <= 0;
                        timeout_count <= 0;
                        state <= WAIT_ECHO;
                    end
                    else begin
                        trig_count <= trig_count + 1;
                    end
                end

                WAIT_ECHO: begin
                    if(echo_in) begin
                        echo_count <= 0;
                        timeout_count <= 0;
                        state <= MEASURE;
                    end
                    else if(timeout_count >= PERIOD - 1) begin
                        echo_tick <= 0;
                        period_count <= 0;
                        timeout_count <= 0;
                        state <= IDLE;
                    end
                    else begin
                        timeout_count <= timeout_count + 1;
                    end
                end

                MEASURE: begin
                    if(!echo_in) begin
                        echo_tick <= echo_count;
                        period_count <= 0;
                        timeout_count <= 0;
                        state <= IDLE;
                    end
                    else if(timeout_count >= PERIOD - 1) begin
                        echo_tick <= 0;
                        period_count <= 0;
                        timeout_count <= 0;
                        state <= IDLE;
                    end
                    else begin
                        echo_count <= echo_count + 1;
                        timeout_count <= timeout_count + 1;
                    end
                end

                default: begin
                    state <= IDLE;
                    trig <= 0;
                end

            endcase
        end
        else begin
            echo_tick <= 0;
        end
    end

    always @(*) begin
        if(echo_tick == 0 || echo_tick > Cutoff)begin
            ld = 8'b00000000;
        end
        else if(echo_tick <= D10)begin
            ld = 8'b00000001;
        end
        else if(echo_tick <= D20)begin
            ld = 8'b00000011;
        end
        else if(echo_tick <= D30)begin
            ld = 8'b00000111;
        end
        else if(echo_tick <= D40)begin
            ld = 8'b00001111;
        end
        else if(echo_tick <= D50)begin
            ld = 8'b00011111;
        end
        else if(echo_tick <= D60)begin
            ld = 8'b00111111;
        end
        else if(echo_tick <= D70)begin
            ld = 8'b01111111;
        end
        else begin
            ld = 8'b11111111;
        end
    end

endmodule
