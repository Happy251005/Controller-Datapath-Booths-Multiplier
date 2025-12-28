module alu(input [15:0] A, input [15:0] B, input addSub, output reg [15:0] Z);
always @(*) begin
    if (addSub) begin
        Z = A - B;
    end else begin
        Z = A + B;
    end
end
endmodule