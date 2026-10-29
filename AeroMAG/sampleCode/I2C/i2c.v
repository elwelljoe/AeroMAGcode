module main;
    reg clk;
    reg key;
    wire sclk;
    reg data;
    wire [5:0] counter;
    wire [9:0] sdCount;
    wire [7:0] dataIn;
    wire resetN;
    reg go;
    reg [6:0] sdCounter;
    reg sdi;

    assign resetN = key;

    initial clk = 0;
    always #1 clk <= ~clk;

    sclk S1(
        .clk(clk),
        .sclk(sclk)
    );

    generation G1(
        .clk(sclk),
        .data(dataIn)
    );

    read R1(
        .clk(sclk),
        .data(dataIn),
        .din(data)
    );

    i2c I1(
        .clk(sclk)
    );
endmodule

module sclk(
    input clk,
    output reg sclk
);
    initial sclk = 0;
    reg [3:0] counter = 0;

    always @(posedge clk)begin
        if(counter == 2)begin
            sclk <= ~sclk;
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
endmodule

module generation(
    input clk,
    output reg [7:0] data
);
    reg [5:0] counter = 0;
    always @(posedge clk)begin
        case(counter)
            1: data <= 8'b01001101;
            2: data <= 8'b01110101;
            3: data <= 8'b11011011;
            4: data <= 8'b10111001;
            5: data <= 8'b01110110;
        endcase
        if(counter == 6)begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1; 
        end
    end
endmodule

module read(
    input clk,
    inout [7:0] data,
    output reg din
);
    reg [7:0] counter = 0;
    reg [7:0] temp;
    assign data = temp;

    always @(posedge clk)begin
        if(counter == 8)begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
            din <= temp[7];
            temp <= temp << 1;
        end
    end
endmodule

module test(
    input clk,
    input sclk,
    output reg check
);
    reg test = 0;
    initial check = 0;

    always @(posedge clk)begin
        if(test == 0 && sclk == 1)begin
            check <= ~check;
            test <= 1;
        end
        else if(sclk == 0)begin
            test <= 0;
        end
    end
endmodule

module i2c(
    input clk,
    input din,
    output reg [7:0] data,
    output reg pause,
    output reg dout
); 

    always @(posedge clk)begin
        case(counter)
            
        endcase 
    end

endmodule