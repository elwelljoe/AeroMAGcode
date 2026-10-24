module main;
    reg clk;
    wire din;
    wire dout;
    reg cs;
    wire sclk;
    wire clk_out;
    wire [11:0] data;
    wire [11:0] datr;
    wire busy;
    wire [3:0] timer;

    initial clk = 0;

    always #1 clk = ~clk;

    accelerometer a2(
        .clk(sclk),
        .datr(datr),
        .dout(dout),
        .busy(busy),
        .bit_count(timer)
    );

    sclk s1(
        .clk(clk),
        .sclk(sclk)
    );

    adc a1(
        .clk(sclk),
        .dout(dout),
        .cs(cs),
        .busy(busy),
        .dataout(data)
    );

    generation G1(
        .clk(clk),
        .datr(datr),
        .busy(busy)
    );

    initial begin
        $dumpfile("Output.vcd");
        $dumpvars(0, main);

        cs = 1;
        #5

        cs = 0;
        #1000

        $finish;
    end

endmodule

module accelerometer(
    input clk,
    input [11:0] datr,
    output reg dout,
    output reg busy,
    output reg [3:0] bit_count
);
    reg [11:0] data;
    reg [1:0] state;
    reg [11:0] counter = 12'd0;

    localparam RESET = 2'd0;
    localparam READ = 2'd1;
    localparam WRITE = 2'd2;

    initial state = RESET;
    initial bit_count = 0;

    always @(posedge clk)begin
        case(state)
            RESET: begin
                data <= 12'd0;
                counter <= 0;
                busy <= 0;
                dout <= 0;
                state <= READ;
            end
            READ: begin
                busy <= 1;
                data <= datr;
                counter <= counter + 1;
                state <= WRITE;
            end
            WRITE: begin
                if(bit_count < 11)begin
                    dout <= data[11];
                    data <= data << 1;
                    bit_count <= bit_count + 1;
                end
                else begin
                    bit_count <= 0;
                    state <= RESET;
                end
            end
        endcase
    end
endmodule

module adc(
    input clk,
    input cs,
    input dout,
    input busy,
    output reg [11:0] dataout
);
    initial dataout = 0;

    always @(posedge clk)begin
        if(!cs && busy == 0)begin
            dataout <= dataout;
        end
        else begin
            dataout <= {dataout[10:0], dout};
        end
    end
endmodule

module sclk(
    input clk,
    output reg sclk
);
    initial sclk = 1;

    always @(posedge clk)begin
        sclk <= ~sclk;
    end
endmodule

module generation(
    input clk,
    input busy,
    input cs,
    output reg [11:0] datr
);
    reg [3:0] state = 0;

    always @(posedge clk)begin
        if(state < 4'd15 && busy == 0)begin
            state <= state + 1;
            case(state)
                0: datr <= 12'b011001100100;
                1: datr <= 12'b111010110111;
                2: datr <= 12'b101110101110;
                3: datr <= 12'b111110101100;
                4: datr <= 12'b000101100111;
                5: datr <= 12'b110110001100;
                6: datr <= 12'b010011001010;
                7: datr <= 12'b111010001100;
                8: datr <= 12'b010101001101;
                9: datr <= 12'b011100001011;
                10: datr <= 12'b111001100111;
                11: datr <= 12'b100010110011;
                12: datr <= 12'b101010101111;
                13: datr <= 12'b101101011011;
                14: datr <= 12'b101011011101;
                15: datr <= 12'b101010011001;
            endcase
        end
        else if(state == 4'd15)begin
            state<= 0;
        end
    end
endmodule
