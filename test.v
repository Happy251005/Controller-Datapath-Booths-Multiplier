module test;
reg clk, start,rst;
reg [15:0] data_in;

control ctrl(ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, ldcount, decCount, addSub, done, eqz, Q0, Qm1, start, clk,rst);
datapath dp(clk, ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, ldcount, decCount, addSub, data_in, eqz, Q0, Qm1);

/*
//----THIS IS FOR MONITORING INTERNAL SIGNALS----
initial begin
    clk = 0;
    #999 $display("Output = %d", {dp.A,dp.Q});
    #1000 $finish;
end


always #5 clk = ~clk;

initial begin
    rst = 1; start = 0; data_in = 16'd0;
    #10 rst = 0;
    #10 start = 1;
    #7 data_in = 16'd6;
   #10 data_in = 16'd7;
end

initial begin
  $monitor($time,
    " A=%0d Q=%0d M=%0d Q0=%b Qm1=%b count=%0d done=%b state=%0d",
     dp.A, dp.Q, dp.M, dp.Q[0], dp.Qm1, dp.count, done, ctrl.state);
end
*/

task automaticrun_test(input signed [15:0] multiplicand, input signed [15:0] multiplier);
reg signed [31:0] expected;
begin
    expected = multiplicand * multiplier;

    // reset the design
    rst   = 1; start = 0; data_in = 0;
    repeat (2) @(posedge clk);
    rst = 0;

    
    data_in = multiplicand;
    // start multiplication
    start = 1;
    @(posedge clk);
    // load multiplicand
    @(posedge clk);
    // load multiplier
    data_in = multiplier;
    @(posedge clk);
    start   = 0;

    wait (done == 1);
    if ({dp.A,dp.Q} !== expected) begin
        $display("Test Failed: %d * %d != %d (got %d)", multiplicand, multiplier, multiplicand * multiplier, $signed({dp.A,dp.Q}));
    end else begin
        $display("Test Passed: %d * %d = %d", multiplicand, multiplier, $signed({dp.A,dp.Q}));
    end
end
endtask

always #5 clk = ~clk;

initial begin
clk=0;
automaticrun_test(16'd3, 16'd5);
automaticrun_test(16'd7, 16'd6);
automaticrun_test(16'd12, -16'd81);
$finish;
end

endmodule