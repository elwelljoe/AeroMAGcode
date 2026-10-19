module main;
    //initializes registers and wires for simulation
    reg [1:0] SW;
    reg clk;
    wire [3:0] LD;
    wire red, yellow, green;

    //calls function and passes values
    traffic_light uut(
        .SW(SW),
        .clk(clk),
        .LD(LD),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    //sets an initial clock value
    initial clk = 0;
    //sets how long each clock cycle takes
    always #5 clk = ~clk;

    initial begin
        //writes to an output simulation file
        $dumpfile("output.vcd");
        $dumpvars(0, main);

        //generic state for sw to allow cycling of lights
        SW = 2'b10;
        //sets the simulation time to 300 seconds
        #300;

        //stops the collection of data
        $finish;
    end

endmodule