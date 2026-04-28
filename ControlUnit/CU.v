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
