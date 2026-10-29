module accelerometer(
    input clk_25mhz,
    inout [27:0] gp,
    output [7:0] led
);
    wire [7:0] data;
    wire dout;
    wire busy;
    wire din;
    wire sclk;

    assign gp[26] = sclk;

    sclk S1(
        .clk(clk_25mhz),
        .sclk(sclk)
    );

    lights L1(
        .clk(clk_25mhz),
        .data(data),
        .ld(led)
    );

    i2c I1(
        .clk(clk_25mhz),
        .sclk(sclk),
        .sda(gp[27]),
        .data(data)
    );
endmodule

module sclk(
    input clk,
    output reg sclk
);
    initial sclk = 0;
    reg [4:0] timer = 0;

    always @(posedge clk)begin
        if(timer == 31)begin
            sclk <= ~sclk;
            timer <= 0;
        end
        else begin
            timer <= timer + 1;
        end
    end
endmodule

module i2c(
    input clk,
    input sclk,
    inout sda,
    output reg [7:0] data
);
    reg [3:0] stage;
    reg [7:0] bitCount;
    reg [7:0] pause;
    reg [7:0] stand;
    reg test;
    reg temp;
    reg ack;
    reg break;

    initial begin
        stage = 0;
        bitCount = 0;
        test = 0;
        temp = 1;
        ack = 0;
        data = 0;
        pause = 0;
        stand = 0;
        break = 0;
    end
    
    assign sda = (temp == 0) ? 1'b0:1'bz;
        
    always @(posedge clk)begin
        case(stage)
            0: begin //idle
                if(sclk && sda && pause >= 100)begin //starts communication
                    temp <= 0;
                    pause <= 0;
                    stage <= 1;
                end
                else begin
                    pause <= pause + 1;
                end
            end 
            1: begin //write
                if(!sclk && !test) begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //D0
                            0: temp <= 1;
                            1: temp <= 1;
                            2: temp <= 0;
                            3: temp <= 1;
                            4: temp <= 0;
                            5: temp <= 0;
                            6: temp <= 0;
                            7: temp <= 0;
                        endcase
                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end 
                end
                else if(sclk)begin
                    if(ack)begin
                        if(!sda && pause < 100)begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 2;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            break <= 1;
                            stage <= 4;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            2: begin //defines address
                if(!sclk && !test)begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //6B
                            0: temp <= 0;
                            1: temp <= 1;
                            2: temp <= 1;
                            3: temp <= 0;
                            4: temp <= 1;
                            5: temp <= 0;
                            6: temp <= 1;
                            7: temp <= 1;
                        endcase

                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end
                end
                else if(sclk)begin
                    if(ack)begin
                        if(!sda)begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 3;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            break <= 1;
                            stage <= 4;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            3: begin //wakes sensor
                if(!sclk && !test)begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //00
                            0: temp <= 0;
                            1: temp <= 0;
                            2: temp <= 0;
                            3: temp <= 0;
                            4: temp <= 0;
                            5: temp <= 0;
                            6: temp <= 0;
                            7: temp <= 0;
                        endcase

                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end
                end
                else if(sclk)begin
                    if(ack)begin
                        if(!sda)begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 4;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 4;
                            break <= 1;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            4: begin //stop
                if(!sclk)begin
                    temp <= 0;
                end
                else if(temp == 0)begin
                    temp <= 1;
                    pause <= 0;
                    stage <= 5;
                end
                else if(break == 1)begin
                    temp = 1;
                    pause <= 0;
                    stage <= 0;
                end
            end
            5: begin //idle
                if(sclk && sda && pause >= 100)begin //starts communication
                    temp <= 0;
                    pause <= 0;
                    stage <= 6;
                end
                else begin
                    pause <= pause + 1;
                end
            end 
            6: begin //write
                if(!sclk && !test) begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //D0
                            0: temp <= 1;
                            1: temp <= 1;
                            2: temp <= 0;
                            3: temp <= 1;
                            4: temp <= 0;
                            5: temp <= 0;
                            6: temp <= 0;
                            7: temp <= 0;
                        endcase
                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end 
                end
                else if(sclk)begin
                    if(ack)begin
                        if(!sda && pause < 100)begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 7;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 11;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            7: begin //defines address
                if(!sclk && !test)begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //3B
                            0: temp <= 0;
                            1: temp <= 0;
                            2: temp <= 1;
                            3: temp <= 1;
                            4: temp <= 1;
                            5: temp <= 0;
                            6: temp <= 1;
                            7: temp <= 1;
                        endcase

                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end
                end
                else if(sclk)begin
                    if(ack)begin
                        if(!sda)begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 8;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 11;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            8: begin //restarts
                if(!sclk)begin
                    temp <= 1;
                end
                else begin
                    if(sda) begin
                        temp <= 0;
                        stage <= 9;
                    end
                end
            end
            9: begin //read
                if(!sclk && !test)begin
                    test <= 1;
                    if(bitCount < 8)begin
                        case(bitCount) //D1
                            0: temp <= 1;
                            1: temp <= 1;
                            2: temp <= 0;
                            3: temp <= 1;
                            4: temp <= 0;
                            5: temp <= 0;
                            6: temp <= 0;
                            7: temp <= 1;
                        endcase
                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        temp <= 1;
                        ack <= 1;
                        bitCount <= 10;
                    end
                end
                else if(sclk)begin
                    if(ack == 1)begin
                        if(!sda && pause < 100)begin
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 10;
                        end
                        else begin
                            test <= 0;
                            ack <= 0;
                            bitCount <= 0;
                            pause <= 0;
                            stage <= 11;
                        end
                        pause <= pause + 1;
                    end
                    else begin
                        test <= 0;
                    end
                end
            end
            10: begin //reads data
                if(sclk && !test)begin
                    test <= 1;
                    if(bitCount < 8)begin
                        stand <= {stand[6:0], sda};
                        bitCount <= bitCount + 1;
                    end
                    else if(bitCount == 8)begin
                        data <= stand;
                        test <= 0;
                        bitCount <= 0;
                        stage <= 11;
                    end
                end
                else if(!sclk)begin
                    test <= 0;
                end
            end
            11: begin //stop
                if(!sclk)begin
                    temp <= 0;
                end
                else if(temp == 0)begin
                    temp <= 1;
                    pause <= 0;
                    stage <= 5;
                end
            end
        endcase
    end
endmodule

module lights(
    input clk,
    input [7:0] data,
    output reg [7:0] ld
);
    wire signed [8:0] store = {data[7], data};
    wire signed [8:0] value = store + 9'sd64;
    reg [2:0] position;

    always @(posedge clk)begin
        if(value < 0)begin
            position <= 3'd0;
        end
        else if(value >= 128)begin
            position <= 3'd7;
        end
        else begin
            position <= value[6:4];
        end
        ld <= position;
    end
endmodule