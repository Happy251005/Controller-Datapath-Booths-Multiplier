module control(output reg ldA,clrA,sftA,ldQ,clrQ,sftQ,ldM,clrff,ldcount,decCount,addSub,done, input eqz,Q0,Qm1,start,clk,rst);
reg [2:0] next_state,state;
parameter S0 = 3'b000,
          S1 = 3'b001,
          S2 = 3'b010,
          S3 = 3'b011, 
          S4 = 3'b100, 
          S5 = 3'b101, 
          S6 = 3'b110,
          S7 = 3'b111; 

always @(posedge clk) begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end

always @(*) begin
    // default signal assignments
    ldA = 0; clrA = 0; sftA = 0;
    ldQ = 0; clrQ = 0; sftQ = 0;
    ldM = 0; clrff = 0; done = 0;
    ldcount = 0; decCount = 0; addSub = 0;

    // default next state
    next_state = state;

    // state machine logic
    case (state)
        S0: if(start) next_state = S1;
        else next_state = S0;
        S1: begin
            clrA = 1; ldM = 1; ldcount = 1; clrff = 1;
            next_state = S7;
        end
        S7: begin
            ldQ = 1;
            clrff = 1;
            next_state = S2;
        end
        S2: begin
            if (eqz) next_state = S6;
            else if({Q0,Qm1} == 2'b01) next_state = S3;
            else if({Q0,Qm1} == 2'b10) next_state = S4;
            else next_state = S5;
        end
        S3: begin
            ldA = 1;
            next_state = S5;
        end
        S4: begin
            ldA = 1;
            addSub = 1;
            next_state = S5;
        end
        S5: begin
            addSub = 0;
            sftA = 1; sftQ = 1; decCount = 1;
            next_state = S2;
        end
        S6: begin
            done = 1;
            next_state = S6;
        end
        default: next_state = S0;
    endcase

end

endmodule