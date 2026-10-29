module main(
    input clk_25mhz,
    input [6:0] btn,
    inout [27:0] gp,
    output [7:0] led
);
    wire [7:0] inpt = {btn[6:3], gp[4:2]};
    wire sclk;
    wire start;

    parameter BAUD = 9600;
    parameter CLK = 25_000_000;
    localparam HALF = CLK/BAUD/2;
    localparam DB = BAUD/100;

    button B1(
        .clk(clk_25mhz),
        .btn(inpt),
        .start(start),
        .data(led)
    );
    
    sclk S1(
        .clk(clk_25mhz),
        .half(HALF),
        .sclk(sclk)
    );

    enable E1(
        .clk(clk_25mhz),
        .enable(gp[0]),
        .disble(gp[1]),
        .start(start)
    );

    uarttx Tx(
        .clk(sclk),
        .reset(btn[0]),
        .enable(start),
        .loadDat(),
        .data(led),
        .out(),
        .empty()
    );
endmodule

module button(
    input clk,
    input [7:0] btn,
    input start,
    output reg [7:0] data
);

    always @(posedge clk)begin
        if(start)begin
            data <= btn;
        end
    end
endmodule

module uarttx(
    input clk,
    input reset,
    input enable,
    input loadDat,
    input [7:0] data,
    output reg out,
    output reg empty
);
endmodule

module sclk(
    input clk,
    input [31:0] half,
    output reg sclk
);
    reg [24:0] timer = 0;

    always @(posedge clk)begin
        if(timer == half - 1)begin
            timer <= 0;
            sclk <= ~sclk;
        end
        else begin
            timer <= timer + 1;
        end
    end
endmodule

module enable(
    input clk,
    input enable,
    input disble,
    output reg start
);
    always @(posedge clk)begin
        if(enable)begin
            start <= 1;
        end
        else if(disble)begin
            start <= 0;
        end
    end
endmodule

module sync(
    input clk,
    input btn,
    output reg resetCnt
);
    
endmodule