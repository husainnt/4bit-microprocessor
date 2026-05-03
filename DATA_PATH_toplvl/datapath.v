//Datapath
module datapath(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input wr_en,
input alu_src,
input[1:0] ALUOp,
input AddSub,
input Cin, 
output[3:0] opcode,
output zero_flag
);
wire[3:0] pc_val;
wire[15:0] inst;
wire[3:0] d1,d2,alu_res,alu_B_in;
wire caary_flag,ovf_flag,SF,ZF; 
reg[3:0] mux_out;
assign opcode=inst[11:8];

program_counter PC_inst(
.clk(clk),
.clr(clr),
.inc_PC(inc_PC),
.branch(branch),
.jump(jump),
.ovf_flagfset(inst[3:0]),
.jump_addr(inst[3:0]),
.pc(pc_val)
);

instruction_memory IM_inst(
.addr(pc_val),
.instruction(inst)
);

wire [1:0] rs = inst[7:6];
wire [1:0] rt = inst[5:4];
wire [1:0] rd = inst[3:2];

register_file_4x4 RF_inst(
.data_out1(d1),
.data_out2(d2),
.data_in(alu_res),
.wr(alu_src ? rt : rd),
.rd1(rs),
.rd2(rt),
.write_enable(wr_en),
.clk(clk),
.clr(~clr) 
);

always@(*) begin
if(alu_src==1'b1)
mux_out=inst[3:0];
else
mux_out=d2;
end
assign alu_B_in=mux_out;

alu_4bit ALU_inst(
.A(d1),
.B(alu_B_in),
.ALUOp(ALUOp),
.AddSub(AddSub),
.Cin(Cin),
.ans(alu_res),
.caary_flag(caary_flag),
.ovf_flag(ovf_flag),
.SF(SF),
.ZF(ZF)
);

assign zero_flag = ZF;
endmodule

module program_counter(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input[3:0] ovf_flagfset,
input[3:0] jump_addr,
output reg[3:0] pc
);
always@(posedge clk or posedge clr) 
begin
if(clr)
pc<=4'b0000; 
else if(jump)
pc<=jump_addr;
else if(branch)
pc<=pc+1+ovf_flagfset; 
else if(inc_PC)
pc<=pc+1; 
end
endmodule

module instruction_memory(
input[3:0] addr,
output reg[15:0] instruction
);
reg[15:0] mem[0:15];
initial begin
mem[0]=16'b0000_0000_00_01_10_00;//and
mem[1]=16'b0000_0001_00_01_11_00;//or
mem[2]=16'b0000_0010_00_01_10_00;//add
mem[3]=16'b0000_0011_00_01_11_00;//sub
mem[4]=16'b0000_1000_00_01_10_00;//slt
mem[5]=16'b0000_0100_00_01_10_00;//andi
mem[6]=16'b0000_0101_00_01_11_00;//ori
mem[7]=16'b0000_0110_00_01_10_00;//addi
mem[8]=16'b0000_0111_00_01_11_00;//subi
mem[9]=16'b0000_1001_00_01_10_00;//slti
mem[10]=16'b0000_1010_00_01_10_00;//beq
mem[11]=16'b0000_1011_00_01_10_00;//bne
mem[12]=16'b0000_1100_0000_0011;//j
end
always@(*) 
instruction=mem[addr];
endmodule

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

module register_file_4x4(
output[3:0] data_out1,data_out2,
input[3:0] data_in,
input[1:0] wr,rd1,rd2,
input write_enable,
input clk,
input clr
);
wire[3:0] dec_out;
wire[3:0] r0,r1,r2,r3;

decoder2x4 d1(wr,write_enable,dec_out);
REG4bit reg0(r0,data_in,clk,dec_out[0], clr);
REG4bit reg1(r1,data_in,clk,dec_out[1], clr);
REG4bit reg2(r2,data_in,clk,dec_out[2], clr);
REG4bit reg3(r3,data_in,clk,dec_out[3], clr);
mux4x1 m1(r0,r1,r2,r3,rd1,data_out1);
mux4x1 m2(r0,r1,r2,r3,rd2,data_out2);
endmodule

module decoder2x4(
input[1:0] wr,
input write_enable,
output reg[3:0] dec_out
);
always@(*) begin
if(write_enable == 0) begin
if(wr==2'b00)
dec_out=4'b0001;
else if(wr==2'b01)
dec_out=4'b0100; 
else if(wr==2'b10)
dec_out=4'b0010;
else if(wr==2'b11)
dec_out=4'b1000;
else
dec_out=4'b0000;
end
else
dec_out=4'b0000;
end
endmodule

module mux4x1(
input[3:0] in0,in1,in2,in3,
input[1:0] sel,
output reg[3:0] out
);
always@(*) begin
if(sel==2'b00)
out=in0;
else if(sel==2'b01)
out=in1;
else if(sel==2'b10)
out=in2;
else if(sel==2'b11)
out=in3;
else
out=4'b0000;
end
endmodule

module REG4bit(
output reg[3:0] q,
input[3:0] d,
input clk,
input load,
input clr
);
initial q = 4'b0000;
always@(negedge clk or negedge clr) begin
if(clr==0)
q<=4'b0000; 
else begin
if(load)
q<=d; 
end
end
endmodule
//Top levl
module top_lvl(
input clk,
input reset
);
wire[3:0] op;
wire z_flag;
wire[1:0] ALUOp;
wire AddSub,Cin;
wire w_en,i_pc,br,jmp,a_src;
wire[1:0] st;

datapath DP(
.clk(clk),
.clr(reset),
.inc_PC(i_pc),
.branch(br),
.jump(jmp),
.wr_en(w_en),
.alu_src(a_src),
.ALUOp(ALUOp),
.AddSub(AddSub),
.Cin(Cin),
.opcode(op),
.zero_flag(z_flag)
);

CU control(
.clock(clk),
.reset(reset),
.opcode(op),
.zero_flag(z_flag),
.ALUOp(ALUOp),
.AddSub(AddSub),
.Cin(Cin),
.wr_en(w_en),
.alu_src(a_src),
.inc_PC(i_pc),
.branch(br),
.jump(jmp),
.state(st)
);
endmodule

// --- CONTROL UNIT ---

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
if(current_state==FETCH)
next_state=DECODE;
else if(current_state==DECODE)
next_state=EXECUTE;
else if(current_state==EXECUTE)
next_state=WRITEBACK;
else if(current_state==WRITEBACK)
next_state=FETCH;
else
next_state=FETCH;
end

always @(posedge clock or posedge reset) begin
if(reset)
current_state<=FETCH;
else
current_state<=next_state;
state<=current_state;
end
always @(*) begin
ALUOp=2'b00;
AddSub=0;
Cin=0;
wr_en=1;
alu_src=0;
inc_PC=0;
branch=0;
jump=0;
if(current_state==DECODE) begin
//and
if(opcode==4'b0000) begin
ALUOp=2'b00;
AddSub=0;
Cin=0;
end
//or
else if(opcode==4'b0001) begin
ALUOp=2'b01;
AddSub=0;
Cin=0;
end
//add
else if(opcode==4'b0010) begin
ALUOp=2'b10;
AddSub=0;
Cin=0;
end
//sub
else if(opcode==4'b0011) begin
ALUOp=2'b10;
AddSub=1;
Cin=1;
end
//slt
else if(opcode==4'b1000) begin
ALUOp=2'b11;
AddSub=0;
Cin=0;
end
//andi
else if(opcode==4'b0100) begin
ALUOp=2'b00;
alu_src=1;
AddSub=0;
Cin=0;
end
//ori
else if(opcode==4'b0101) begin
ALUOp=2'b01;
alu_src=1;
AddSub=0;
Cin=0;
end
//addi
else if(opcode==4'b0110) begin
ALUOp=2'b10;
alu_src=1;
AddSub=0;
Cin=0;
end
//subi
else if(opcode==4'b0111) begin
ALUOp=2'b10;
AddSub=1;
Cin=1;
alu_src=1;
end
//slti
else if(opcode==4'b1001) begin
ALUOp=2'b11;
alu_src=1;
AddSub=0;
Cin=0;
end
//beq
else if(opcode==4'b1010) begin
ALUOp=2'b10;
AddSub=1;
Cin=1;
end
//bne
else if(opcode==4'b1011) begin
ALUOp=2'b10;
AddSub=1;
Cin=1;
end
end
else if(current_state==EXECUTE) begin
//jump
if(opcode==4'b1100) begin
jump=1;
end
//beq
else if(opcode==4'b1010) begin
if(zero_flag==1)
branch=1;
end
//bne
else if(opcode==4'b1011) begin
if(zero_flag==0)
branch=1;
end
end
else if(current_state==WRITEBACK) begin
//jump
if(opcode==4'b1100) begin
inc_PC=0;
wr_en=1;
end

//beq
else if(opcode==4'b1010) begin
wr_en=1;
if(zero_flag==1)
inc_PC=0;
else
inc_PC=1;
end
//bne
else if(opcode==4'b1011) begin
wr_en=1;
if(zero_flag==0)
inc_PC=0;
else
inc_PC=1;
end
else begin
wr_en=0; 
inc_PC=1;
end
end
end
endmodule

// --- TB ---

module tb_top();
reg clk;
reg reset;

top_lvl uut (
.clk(clk),
.reset(reset)
);

always #5 clk = ~clk;

initial begin
$monitor("TIME=%0t | PC=%d | OPCODE=%b | ALU_RES=%d | ZERO=%b | STATE=%b",
$time,
uut.DP.pc_val,
uut.op,
uut.DP.alu_res,
uut.z_flag,
uut.control.state
);
end

initial begin
$dumpfile("final_proc.vcd");
$dumpvars(0, tb_top);
clk = 0;
reset = 1;
#15;
reset = 0;

#5;
uut.DP.RF_inst.reg0.q = 4'd5;
uut.DP.RF_inst.reg1.q = 4'd3;
uut.DP.RF_inst.reg2.q = 4'd0;
uut.DP.RF_inst.reg3.q = 4'd0;
#300;
$finish;
end
endmodule