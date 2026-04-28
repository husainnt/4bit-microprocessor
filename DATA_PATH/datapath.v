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
