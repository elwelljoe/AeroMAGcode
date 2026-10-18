module inverter(
    input [15:0] SW,
    output [15:0] LD
);

    assign LD[15:0] = SW[15:0];
    
    not n1(LD[15], SW[0]);

endmodule

module ander(
    input [15:0] SW,
    output [15:0] LD
);

    assign LD[0] = SW[0];
    assign LD[1] = SW[1];
    assign LD[2] = SW[2];

    and a1(LD[15], SW[2], SW[1], SW[0]);

endmodule