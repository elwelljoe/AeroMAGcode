module main;
        //creates input and output variables to track
        reg [3:0] SW; //4 bits
        wire [3:0] LD;

        //calls inverter module
        inverter uut(
            .SW(SW),
            .LD(LD)
        );

        //calls ander module
        ander uus(
            .SW(SW),
            .LD(LD)
        );

        initial begin
            //dumps simulation to an output file
            $dumpfile("output.vcd");
            //dumps variables for simulation
            $dumpvars(0, test);

            //example 
            SW = 16'd0;
            #5;

            SW = 16'd535;
            #5;

            $finish;
        end

endmodule