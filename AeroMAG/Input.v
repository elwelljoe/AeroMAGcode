module inpt(
    input clk_25mhz,
    output [7:0] gp
);

    wire [3:0] pin;
    reg [3:0] pout;
    initial pout = 4'd0;
    

    always @(posedge clk_25mhz)begin
        if(pin[3] == 1)begin
            pout[3] <= 1'b1;
        end
        else begin
            pout[3] <= 1'b0;
        end
    end

    assign gp[7:4] = pin[3:0];
    assign gp[3:0] = pout[3:0];

endmodule