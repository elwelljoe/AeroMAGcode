module tb; //starts the module tb

        reg [3:0] a, b; //sets up two 4 bit variables as registers to be used
        wire [4:0] sum; //sets up a 5 bit output variable

        adder uut( //calls the adder function
            .a(a), //sends a for a in adder
            .b(b), //sends b for b in adder
            .sum(sum) //sends sum for sum in adder
        );

        initial begin //starts the main function
            $dumpfile("output.vcd"); //dumps a .vcd file to a folder
            $dumpvars(0, tb); //dumps a variable in all hierarchys beneath and including tb

            a = 4'd0; b = 4'd0; // assign 0 to a 4 bit variable
            #5; //waits 5 simulation ticks

            a = 4'd3; b = 4'd2;
            #5;

            a = 4'd15; b = 4'd1;
            #5;

            $finish; //finishes writing to the .vcd file
        end //closes the main function

endmodule //ends the module tb