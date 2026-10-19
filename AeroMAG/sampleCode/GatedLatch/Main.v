module main;
    //defines input and output values to track
    reg [3:0] SW; //4 bits
    wire LD; //1 bit
    wire temp;

    //calls module
    gated_latch uut(
        .SW(SW),
        .LD(LD),
        .temp(temp)
    );

    initial begin
        //dumps the outputs into a file
        $dumpfile("output.vcd");
        //dumps variables to run the simulation
        $dumpvars(0, main);

        //runs through multiple switch combination with a reset being 0x6
        SW = 4'h6; //4 bits with hex value 0x6
        #5;

        SW = 4'h7;
        #5;

        SW = 4'h6;
        #5;
        
        SW = 4'd0;
        #5;

        SW = 4'h6;
        #5;

        $finish;
    end
    
endmodule
