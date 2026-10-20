module pins(
    input clk_25mhz,
    output [27:0] gn, //all pins marked -
    output [27:0] gp //all pins marked +
);

    reg [27:0] timer;
    reg data;
    initial timer = 28'd0;

    always @(posedge clk_25mhz)begin
        if(timer == 28'd25000000)begin
            timer <= 0;
            data = ~data;
        end
        else begin
            timer <= timer + 1;
        end
    end

    assign gp [13] = data;

endmodule