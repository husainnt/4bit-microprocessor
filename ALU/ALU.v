//ALU
module alu_4bit(
input[3:0] A,B,
input[1:0] ALUOp,
input AddSub,
input Cin,
output reg[3:0] ans,
output reg caary_flag,
output reg ovf_flag,
output reg SF,
output reg ZF
);
reg[4:0] x;
always@(*) 
begin
caary_flag = 0;
ovf_flag = 0;
SF = 0;
ZF = 0;

if(ALUOp==2'b00)
ans=A&B;

else if(ALUOp==2'b01)
ans=A|B; 

else if(ALUOp==2'b10) begin

if(AddSub==0) begin
x = A + B + Cin;
ans = x[3:0];
caary_flag = x[4];
if((A[3]==B[3]) && (ans[3]!=A[3]))
ovf_flag = 1;
end
else begin
x = A + (~B) + Cin; 
ans = x[3:0];
caary_flag = x[4];
if((A[3]!=B[3]) && (ans[3]!=A[3]))
ovf_flag = 1;
end
end
else if(ALUOp==2'b11) begin
if(A<B)
ans=4'b0001; 
else
ans=4'b0000; 
end
else
ans=4'b0000; 
SF = ans[3];
if(ans==4'b0000)
ZF = 1;
else
ZF = 0;
end
endmodule

module tb_alu();
reg [3:0] A, B; reg [1:0] Op; reg AS, Ci;
wire [3:0] ans; wire CF, OF, SF, ZF;
alu_4bit uut (A, B, Op, AS, Ci, ans, CF, OF, SF, ZF);
initial begin
    $dumpfile("alu_wave.vcd");
    $dumpvars(0, tb_alu);
    A = 5; B = 3; Op = 2'b10; AS = 0; Ci = 0; // ADD
    #10 AS = 1; Ci = 1; // SUB
    #10 $finish;
end
endmodule