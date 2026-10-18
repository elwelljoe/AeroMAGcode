module td;
    reg[7:0] SW, key;
    wire[7:0] LD;

    encoder uut(
        .SW(SW),
        .key(key),
        .LD(LD)
    );

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, td);

        key = 8'd0;
        SW = 8'd22;
        #5;

        key = 8'b01011011;
        SW = 8'd22;
        #5;

        $finish;
        
    end

endmodule