module clk(
    input clk,
    output reg SCLK
);
    wire val;
    reg [28:0] count;
    initial SCLK = 0;

    assign val = 50;

    always @(posedge clk) begin
        if(count < val) begin
            count <= count + 1;
        end
        else begin
            count <= 0;
            SCLK <= ~SCLK;
        end

    end
endmodule