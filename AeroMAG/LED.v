module blinker(
    input clk_25mhz,
    output [27:0] gp
);
    reg [1:0] temp = 2'b00;
    reg [27:0] counter = 28'd0;
    reg [4:0] rpt = 4'd0;

    always @(posedge clk_25mhz)begin
        if(counter == 12500000)begin
            temp[0] <= ~temp[0];
            counter <= 0;
            if(rpt == 10)begin
                temp <= ~temp;
                rpt <= 0;
            end
            else begin
                rpt <= rpt + 1;
            end
        end
        else begin
            counter <= counter + 1;
        end
    end

    assign gp[10:9] = temp;

endmodule