module adder( //starts the adder module and opens parantheses to declare variables
    input [3:0] a, //initializes a as a 4 bit variable that takes input
    input [3:0] b, //initializes b as a 4 bit variable that takes input
    output [4:0] sum //initializes sum as a 5 bit input
);

    assign sum = a+b; //assigns the sum of the two intputs to the sum variable

endmodule //ends the module
