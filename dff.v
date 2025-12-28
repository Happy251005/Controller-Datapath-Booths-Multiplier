module dff(input clk, input d, output reg q, input clr);
always @(posedge clk or posedge clr) begin
    if (clr) begin
        q <= 0;
    end else begin
        q <= d;
    end
end
endmodule
