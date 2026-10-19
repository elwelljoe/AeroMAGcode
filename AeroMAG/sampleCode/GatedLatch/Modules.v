module gated_latch(
    //defined inputs and outputs
    input[3:0] SW,
    output LD,
    output temp
);
    //defined editable outputs
    wire Q, Q_;

    //not and gate (ask for truth table if you don't understand either gates)
    nand n1(Q, SW[0], SW[2]);
    nand n2(Q_, SW[1], SW[2]);

    //not or gate
    nor n3(LD,Q,temp);
    nor n4(temp, LD, Q_);

endmodule