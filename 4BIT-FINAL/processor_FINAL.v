//Prog Counter
module program_counter(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input[3:0] offset,
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
pc<=pc+1+offset; 
else if(inc_PC)
pc<=pc+1; 
end
endmodule

//IM
module instruction_memory(
input[3:0] addr,
output reg[15:0] instruction
);
reg[15:0] mem[0:15];
initial begin
mem[0]=16'b0010000001001000;
mem[1]=16'b0110000001000011;
mem[2]=16'b0011000001001000;
mem[3]=16'b1000000001001000;
mem[4]=16'b1001000001000010;
mem[5]=16'b1010000001000010;
mem[6]=16'b1011000001000010;
mem[7]=16'b1100000000000011;
end
always@(*) 
instruction=mem[addr];
endmodule

//ALU
module alu_4bit(
input[3:0] A,B,
input[2:0] alu_control,
output reg[3:0] result
);
always@(*) 
begin
if(alu_control==3'b000)
result=A&B;
else if(alu_control==3'b001)
result=A|B; 
else if(alu_control==3'b010)
result=A+B; 
else if(alu_control==3'b110)
result=A-B; 
else if(alu_control==3'b111) begin
if(A<B)
result=4'b0001; 
else
result=4'b0000; 
end
else
result=4'b0000; 
end
endmodule

module decoder2x4(
input[1:0] wr,
input write_enable,
output reg[3:0] dec_out
);
always@(*) begin
if(write_enable) begin
if(wr==2'b00)
dec_out=4'b0001;
else if(wr==2'b01)
dec_out=4'b0010;
else if(wr==2'b10)
dec_out=4'b0100;
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
input load
);
always@(posedge clk) begin
if(load)
q<=d; 
end
endmodule

//REG_FILE
module register_file_4x4(
output[3:0] data_out1,data_out2,
input[3:0] data_in,
input[1:0] wr,rd1,rd2,
input write_enable,
input clk
);
wire[3:0] dec_out;
wire[3:0] r0,r1,r2,r3;
decoder2x4 d1(wr,write_enable,dec_out);
REG4bit reg0(r0,data_in,clk,dec_out[0]);
REG4bit reg1(r1,data_in,clk,dec_out[1]);
REG4bit reg2(r2,data_in,clk,dec_out[2]);
REG4bit reg3(r3,data_in,clk,dec_out[3]);
mux4x1 m1(r0,r1,r2,r3,rd1,data_out1);
mux4x1 m2(r0,r1,r2,r3,rd2,data_out2);
endmodule

//Datapath
module datapath(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input wr_en,
input alu_src,
input[2:0] alu_control,
output[3:0] opcode,
output zero_flag
);
wire[3:0] pc_val;
wire[15:0] inst;
wire[3:0] d1,d2,alu_res,alu_B_in;
reg[3:0] mux_out;
assign opcode=inst[11:8];
program_counter PC_inst(
.clk(clk),
.clr(clr),
.inc_PC(inc_PC),
.branch(branch),
.jump(jump),
.offset(inst[3:0]),
.jump_addr(inst[3:0]),
.pc(pc_val)
);
instruction_memory IM_inst(
.addr(pc_val),
.instruction(inst)
);
register_file_4x4 RF_inst(
.data_out1(d1),
.data_out2(d2),
.data_in(alu_res),
.wr(inst[3:2]),
.rd1(inst[7:6]),
.rd2(inst[5:4]),
.write_enable(wr_en),
.clk(clk)
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
.alu_control(alu_control),
.result(alu_res)
);
assign zero_flag=(alu_res==4'b0000);
endmodule

//CU
module CU(
input clock,
input reset,
input [3:0] opcode,
input zero_flag,
output reg [2:0] ALU_cntrl,
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
ALU_cntrl=3'b000;
wr_en=0;
alu_src=0;
inc_PC=0;
branch=0;
jump=0;

if(current_state==DECODE) begin
if(opcode==4'b0000) ALU_cntrl=3'b000;
else if(opcode==4'b0001) ALU_cntrl=3'b001;
else if(opcode==4'b0010) ALU_cntrl=3'b010;
else if(opcode==4'b0011) ALU_cntrl=3'b110;
else if(opcode==4'b1000) ALU_cntrl=3'b111;
else if(opcode==4'b0110) begin ALU_cntrl=3'b010; alu_src=1; end
else if(opcode==4'b1010) ALU_cntrl=3'b110;
else if(opcode==4'b1011) ALU_cntrl=3'b110;
end

else if(current_state==EXECUTE) begin
if(opcode==4'b1100) jump=1;
else if(opcode==4'b1010) begin if(zero_flag==1) branch=1; end
else if(opcode==4'b1011) begin if(zero_flag==0) branch=1; end
end

else if(current_state==WRITEBACK) begin
if(opcode==4'b1100) inc_PC=0;
else if(opcode==4'b1010) begin if(branch==0) inc_PC=1; else inc_PC=0; end
else if(opcode==4'b1011) begin if(branch==0) inc_PC=1; else inc_PC=0; end
else begin wr_en=1; inc_PC=1; end
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
wire[2:0] alu_ctrl;
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
.alu_control(alu_ctrl),
.opcode(op),
.zero_flag(z_flag)
);
CU control(
.clock(clk),
.reset(reset),
.opcode(op),
.zero_flag(z_flag),
.ALU_cntrl(alu_ctrl),
.wr_en(w_en),
.alu_src(a_src),
.inc_PC(i_pc),
.branch(br),
.jump(jmp),
.state(st)
);
endmodule

module tb_top();
reg clk;
reg reset;
top_lvl uut (
.clk(clk),
.reset(reset)
);
always #5 clk = ~clk;
initial begin
$dumpfile("final_wave.vcd");
$dumpvars(0, tb_top);
clk = 0;
reset = 1;
#15 
reset = 0;
#400 
$finish;
end
endmodule