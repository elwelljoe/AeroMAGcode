module encoder(
    //declairs the inputs and outputs and their sizes
    input [7:0] SW, //8 bits
    input [7:0] key,
    output [7:0] LD

);
    //exclusive or for each led bit to encode the data
    xor x1(LD[0], key[0], SW[0]);
    xor x2(LD[1], key[1], SW[1]);
    xor x3(LD[2], key[2], SW[2]);
    xor x4(LD[3], key[3], SW[3]);
    xor x5(LD[4], key[4], SW[4]);
    xor x6(LD[5], key[5], SW[5]);
    xor x7(LD[6], key[6], SW[6]);
    xor x8(LD[7], key[7], SW[7]);


endmodule