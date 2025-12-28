module datapath(input clk, input ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff,ldcount ,decCount, addSub,
                     input [15:0] data_in,
                     output eqz,
                     output Q0,
                     output Qm1);
wire [15:0] A, Q, Z,M;
wire [4:0] count;
assign Q0 = Q[0];
assign eqz = (count==0);

shiftreg pA(.clk(clk), .ld(ldA), .clr(clrA), .sr_in(A[15]), .data_in(Z),.sft(sftA), .data_out(A));
shiftreg pQ(.clk(clk), .ld(ldQ), .clr(clrQ), .sr_in(A[0]), .data_in(data_in),.sft(sftQ), .data_out(Q));
pipo pM(.clk(clk), .ld(ldM), .data_in(data_in), .data_out(M));
dff pQm1(.clk(clk), .d(Q0), .q(Qm1), .clr(clrff));
alu alu1(.A(A), .B(M), .addSub(addSub), .Z(Z));
cntr cn(.clk(clk), .ld(ldcount), .dec(decCount), .count(count));
endmodule