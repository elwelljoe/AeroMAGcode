module main;
    //sets input and output for passing to the module
    reg [2:0] SW;
    wire [1:0] LD;

    //calls function
    fullAdder uut(
        .SW(SW),
        .LD(LD)
    );

    initial begin
        //printing out values
        $dumpfile("output.vcd");
        $dumpvars(0, main);
        
        //run through every bit combination for simulation
        SW = 3'b000;
        #5;
        
        SW = 3'b001;
        #5;
        
        SW = 3'b010;
        #5;

        SW = 3'b011;
        #5;

        SW = 3'b100;
        #5;

        SW = 3'b101;
        #5;

        SW = 3'b110;
        #5;

        SW = 3'b111;
        #5;

        $finish;
    end

endmodule