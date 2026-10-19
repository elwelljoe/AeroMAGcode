module fullAdder (
    //defines input, output, and bit size
    input [2:0] SW, //3 bits
    output [1:0] LD //2 bits
);
    //define one bit editable values
    wire A, B, C, D, E, F;
    wire Sum, Co;

    //assign inputs
    assign A = SW[0];
    assign B = SW[1];
    assign C = SW[2];

    //exclusive or values (ask if you need an explination)
    xor x1(D, A, B);
    xor x2(Sum, D, C);
    //and values
    and a1(F, A, B);
    and a2(E, C, D);
    //or values
    or o1(Co, E, F);

    //assigns outputs to LD bits
    assign LD[0] = Sum;
    assign LD[1] = Co;

endmodule