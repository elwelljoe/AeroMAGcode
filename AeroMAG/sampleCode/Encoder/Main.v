module main;
    //initializes dummy variable for input and output tracking
    reg[7:0] SW, key;
    wire[7:0] LD;

    //calls the encoding function
    encoder uut(
        .SW(SW),
        .key(key),
        .LD(LD)
    );

    initial begin
        //dumps the simulation to an output file
        $dumpfile("output.vcd");
        //dumps all the variables
        $dumpvars(0, main);

        //sets an initial key
        key = 8'd0;
        //sets an example value for the switches
        SW = 8'd22;
        //pauses for 5 seconds
        #5;

        //sets a key
        key = 8'b01011011;
        //sets an example value for switches
        SW = 8'd22;
        //pauses for another 5 seconds
        #5;

        //exits the simulation
        $finish;
        
    end

endmodule