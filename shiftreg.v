module shiftreg(input clk, input ld, clr, sft, sr_in, input [15:0] data_in, output reg [15:0] data_out);
always @(posedge clk or posedge clr) begin
    if (clr) begin
        data_out <= 16'b0;
    end else if (ld) begin
        data_out <= data_in;
    end else if (sft) begin
        data_out <= {sr_in, data_out[15:1]};
    end
end
endmodule
