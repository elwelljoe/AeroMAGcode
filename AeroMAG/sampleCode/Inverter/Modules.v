module inverter(
    //declairs input and output
    input [3:0] SW,
    output [3:0] LD
);
    //sets all leds equal to all switches
    assign LD[3:0] = SW[3:0];
    
    //not gate
    not n1(LD[2], SW[0]);

endmodule

module ander(
    //declairs input and output
    input [3:0] SW,
    output [3:0] LD
);
    //assigns switches individually to leds
    assign LD[0] = SW[0];
    assign LD[1] = SW[1];
    assign LD[2] = SW[2];

    //and gate
    and a1(LD[3], SW[2], SW[1], SW[0]);

endmodule