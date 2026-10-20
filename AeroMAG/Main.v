module main(
    input clk_25mhz,
    input [6:0] btn,
    output [7:0] led,
    output [7:0] gp
);
    wire in;
    wire out;

    assign in = btn[0];
    assign gp[3] = out;


    startup SU(
        .clk(clk_25mhz),
        .led(led)
    );

    pins P1(
        .clk(clk_25mhz),
        .sense(in),
        .pin(out)
    );

    // inpt I1(
    //     .clk(clk_25mhz),
    //     .pin(in),
    //     .pout(out)
    // );

endmodule

module startup(
    input clk,
    output wire [7:0] led
);
    
    reg [7:0] temp;
    reg [28:0] counter;
    initial counter = 29'd0;
    initial temp = 8'd0;

    always @(posedge clk)begin
        if(counter == 28'd12500000) begin
            counter <= 0;
            temp <= (temp << 1) | 1'b1;
            if(temp == 8'b11111111)begin
                temp <= 1;
            end
        end
        else begin
            counter <= counter + 1;
        end
    end

    assign led[7:0] = temp[7:0];

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
    input pin,
    output pout
);
    reg temp;

    always @(posedge clk)begin
        if(pin == 1)begin
            temp <= 1'b1;
        end
        else begin
            temp <= 1'b0;
        end
    end

    assign pout = temp;

endmodule
