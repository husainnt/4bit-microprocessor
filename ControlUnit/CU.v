//CU
module CU(
input clock,
input reset,
input [3:0] opcode,
input zero_flag,
output reg [1:0] ALUOp,
output reg AddSub, 
output reg Cin,  
output reg wr_en,
output reg alu_src,
output reg inc_PC,
output reg branch,
output reg jump,
output reg [1:0] state
);

reg [1:0] current_state;
reg [1:0] next_state;

parameter FETCH=2'b00;
parameter DECODE=2'b01;
parameter EXECUTE=2'b10;
parameter WRITEBACK=2'b11;

always @(*) begin
if(current_state==FETCH) next_state=DECODE;
else if(current_state==DECODE) next_state=EXECUTE;
else if(current_state==EXECUTE) next_state=WRITEBACK;
else if(current_state==WRITEBACK) next_state=FETCH;
else next_state=FETCH;
end

always @(posedge clock or posedge reset) begin
if(reset) current_state<=FETCH;
else current_state<=next_state;
state<=current_state;
end

always @(*) begin
ALUOp=2'b00; AddSub=0; Cin=0; wr_en=1; alu_src=0; inc_PC=0; branch=0; jump=0;
if(current_state==DECODE) begin
if(opcode==4'b0000) begin ALUOp=2'b00; end
else if(opcode==4'b0010) begin ALUOp=2'b10; end
else if(opcode==4'b0011) begin ALUOp=2'b10; AddSub=1; Cin=1; end
end
else if(current_state==EXECUTE) begin
if(opcode==4'b1100) jump=1;
end
else if(current_state==WRITEBACK) begin
if(opcode==4'b1100) inc_PC=0;
else begin wr_en=0; inc_PC=1; end
end
end
endmodule

module tb_cu();
reg clk, reset, zf; reg [3:0] op;
wire [1:0] alu_op, st; wire as, ci, we, src, ipc, br, jp;
CU uut (clk, reset, op, zf, alu_op, as, ci, we, src, ipc, br, jp, st);
always #5 clk = ~clk;
initial begin
    $dumpfile("cu_wave.vcd");
    $dumpvars(0, tb_cu);
    clk = 0; reset = 1; #10 reset = 0; op = 4'b0010; #50 $finish;
end
endmodule