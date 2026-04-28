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