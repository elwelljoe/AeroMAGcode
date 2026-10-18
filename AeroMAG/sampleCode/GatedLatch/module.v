module gated_latch(
    input[3:0] SW,
    output wire LD,
    output wire temp
);
    wire Q, Q_;

    nand n1(Q, SW[0], SW[2]);
    nand n2(Q_, SW[1], SW[2]);

    nor n3(LD,Q,temp);
    nor n4(temp, LD, Q_);

endmodule