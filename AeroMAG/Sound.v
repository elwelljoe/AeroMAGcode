module main(
    input clk_25mhz,
    inout [27:0] gp,
    output [6:0] led
);
    wire [9:0] data;
    wire sclk;

    sclk S1(
        .clk(clk_25mhz),
        .sclk(sclk)
    );

    sensor S2(
        .clk(sclk),
        .sensed(gp[17]),
        .saturated(gp[20]),
        .data(data)
    );

    lights L1(
        .clk(sclk),
        .data(data),
        .led(led)
    );
endmodule

module sclk(
    input clk,
    output reg sclk
);
    initial sclk <= 0;

    always @(posedge clk) begin
        sclk <= ~sclk;
    end
endmodule

module sensor(
    input clk,
    input sensed,
    input saturated,
    output reg [9:0] data,
);
    reg [3:0] bitCount = 0;
    reg [9:0] temp = 0;

    always @(posedge clk)begin
        if(bitCount < 10)begin
            bitCount <= bitCount + 1;
            temp <= (temp << 1) | sensed;
        end
        else begin
            bitCount <= 0;
            if(saturated)begin
                temp <= 0;
            end
            data <= temp;
        end
    end
endmodule

module lights(
    input clk,
    input [9:0] data,
    output reg [6:0] led
);
    reg [27:0] timer = 0;

    always @(posedge clk) begin
        if(timer < 25000000 && led)begin
            timer <= timer + 1;
        end
        else begin
            timer <= 0;
            led <= data;
        end
    end
endmodule