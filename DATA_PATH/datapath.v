//Program Counter
module program_counter(
output reg[3:0]pc_addr,
input pc_enable,
input clk,
input reset
);
always@(posedge clk or posedge reset)begin
if(reset)
pc_addr<=4'b0000;
else if(pc_enable)
pc_addr<=pc_addr+1;
end
endmodule

//4-bit ALU
module alu_4bit(
input[3:0]opA,opB,
input[2:0]alu_sel,
output reg[3:0]alu_out
);
always@(*)begin
case(alu_sel)
3'b000:alu_out=opA&opB;
3'b001:alu_out=opA|opB;
3'b010:alu_out=opA+opB;
3'b110:alu_out=opA-opB;
3'b111:alu_out=(opA<opB)?4'b0001:4'b0000;
default:alu_out=4'b0000;
endcase
end
endmodule

//Decoder 2x4
module decoder2x4(
input[1:0]wr_addr,
input wr_enable,
output reg[3:0]dec_out
);
always@(*)begin
if(wr_enable)begin
case(wr_addr)
2'b00:dec_out=4'b0001;
2'b01:dec_out=4'b0010;
2'b10:dec_out=4'b0100;
2'b11:dec_out=4'b1000;
default:dec_out=4'b0000;
endcase
end else begin
dec_out=4'b0000;
end
end
endmodule

//MUX 4x1
module mux4x1(
input[3:0]in0,in1,in2,in3,
input[1:0]sel,
output reg[3:0]mux_out
);
always@(*)begin
case(sel)
2'b00:mux_out=in0;
2'b01:mux_out=in1;
2'b10:mux_out=in2;
2'b11:mux_out=in3;
default:mux_out=4'b0000;
endcase
end
endmodule

//4-bit Register
module REG4bit(
output reg[3:0]reg_q,
input[3:0]reg_d,
input clk,
input load
);
always@(posedge clk)begin
if(load)
reg_q<=reg_d;
end
endmodule

//4x4 Register File
module register_file_4x4(
output[3:0]rd_data1,rd_data2,
input[3:0]wr_data,
input[1:0]wr_addr,rd_addr1,rd_addr2,
input wr_enable,
input clk
);
wire[3:0]dec_out;
wire[3:0]reg0,reg1,reg2,reg3;

decoder2x4 decoder(wr_addr,wr_enable,dec_out);

REG4bit reg_inst0(reg0,wr_data,clk,dec_out[0]);
REG4bit reg_inst1(reg1,wr_data,clk,dec_out[1]);
REG4bit reg_inst2(reg2,wr_data,clk,dec_out[2]);
REG4bit reg_inst3(reg3,wr_data,clk,dec_out[3]);

mux4x1 mux_rd1(reg0,reg1,reg2,reg3,rd_addr1,rd_data1);
mux4x1 mux_rd2(reg0,reg1,reg2,reg3,rd_addr2,rd_data2);

endmodule

//Datapath
module datapath(
input clk,
input reset,
input pc_enable,
input wr_enable,
input[3:0]instr,
input[2:0]alu_sel,
input[3:0]ext_data,
input sel_data_src,
output[3:0]alu_out,
output[3:0]pc_out
);

wire[1:0]wr_addr=instr[3:2];
wire[1:0]rd_addr=instr[1:0];

wire[3:0]rf_out1,rf_out2;
reg[3:0]write_data;

//assign write_data = (sel_data_src) ? ext_data : alu_out;

always @(*) begin
if(sel_data_src)
write_data = ext_data;
else
write_data = alu_out;
end

program_counter PC(
.pc_addr(pc_out),
.pc_enable(pc_enable),
.clk(clk),
.reset(reset)
);

register_file_4x4 RF(
.rd_data1(rf_out1),
.rd_data2(rf_out2),
.wr_data(write_data),
.wr_addr(wr_addr),
.wr_enable(wr_enable),
.rd_addr1(rd_addr),
.rd_addr2(rd_addr),
.clk(clk)
);

alu_4bit ALU(
.opA(rf_out1),
.opB(rf_out2),
.alu_sel(alu_sel),
.alu_out(alu_out)
);

endmodule

//Tb
module testbenchtask();

reg clk;
reg reset;
reg pc_enable;
reg wr_enable;
reg[3:0]instr;
reg[2:0]alu_sel;
reg[3:0]ext_data;
reg sel_data_src;

wire[3:0]alu_out;
wire[3:0]pc_out;

datapath uut(
.clk(clk),
.reset(reset),
.pc_enable(pc_enable),
.wr_enable(wr_enable),
.instr(instr),
.alu_sel(alu_sel),
.ext_data(ext_data),
.sel_data_src(sel_data_src),
.alu_out(alu_out),
.pc_out(pc_out)
);

always#5 clk=~clk;

initial begin
$dumpfile("my_data_path.vcd");
$dumpvars(0,testbenchtask);

clk=0;
reset=1;
pc_enable=0;
wr_enable=0;
instr=4'b0000;
alu_sel=3'b000;
ext_data=4'b0000;
sel_data_src=1'b0;

#10 reset=0;

ext_data=4'b1010;
instr=4'b0000;
wr_enable=1;
sel_data_src=1;

#10 wr_enable=0;

instr=4'b0100;
alu_sel=3'b010;
sel_data_src=0;
wr_enable=1;

#10 wr_enable=0;

#100
$finish;

end
endmodule