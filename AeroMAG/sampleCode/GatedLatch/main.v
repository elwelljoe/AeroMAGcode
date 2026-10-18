module main;
    reg [3:0] SW;
    wire LD;
    wire temp;

    gated_latch uut(
        .SW(SW),
        .LD(LD),
        .temp(temp)
    );

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, main);

        SW = 4'h6;
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
