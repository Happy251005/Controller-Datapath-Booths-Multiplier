module cntr(input clk, input ld, input dec, output reg [4:0] count);
always @(posedge clk) begin
    if (ld) begin
        count <= 16;
    end else if (dec) begin
        count <= count - 1;
    end
end     
endmodule