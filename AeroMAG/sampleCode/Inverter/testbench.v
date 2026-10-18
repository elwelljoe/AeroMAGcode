module test;

        reg [15:0] SW;
        wire [15:0] LD;

        inverter uut(
            .SW(SW),
            .LD(LD)
        );

        ander uus(
            .SW(SW),
            .LD(LD)
        );

        initial begin
            $dumpfile("output.vcd");
            $dumpvars(0, test);

            SW = 16'd0;
            #5;

            SW = 16'd535;
            #5;

            $finish;
        end

endmodule