//decoder
module decoder_2to4(output reg[3:0]dec_out,input[1:0]wr,input write_enable);
always@(*)begin
if(write_enable)begin
case(wr)
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
//mux
module Mux_4x1(output reg[3:0]out,input[3:0]in0,in1,in2,in3,input[1:0]sel);
always@(*)begin
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
//4bitreg
module Reg4Bit(output reg[3:0]q,input[3:0]d,input load,input clk);
always@(posedge clk)begin
if(load)
q<=d;
end
endmodule
//regfile
module RegFile(data_out1,data_out2,data_in,wr,write_enable,rd1,rd2,clk);
output[3:0]data_out1,data_out2;
input[3:0]data_in;
input[1:0]wr;
input write_enable;
input[1:0]rd1,rd2;
input clk;
wire[3:0]dec_out;
wire[3:0]q0,q1,q2,q3;
//instantiate decoder
decoder_2to4 d1(dec_out,wr,write_enable);
Reg4Bit r0(q0, data_in, dec_out[0], clk);
Reg4Bit r1(q1, data_in, dec_out[1], clk);
Reg4Bit r2(q2, data_in, dec_out[2], clk);
Reg4Bit r3(q3, data_in, dec_out[3], clk);
Mux_4x1 m1(data_out1, q0, q1, q2, q3, rd1);
Mux_4x1 m2(data_out2, q0, q1, q2, q3, rd2);
endmodule
//testbench
module Tb_MY_REGFILE_4x4();
reg[3:0]d_inp;
reg[1:0]w_out;
reg wr_en;
reg[1:0]read1,read2;
reg clock;
wire[3:0]d_op1,d_op2;
RegFile MY_reg(.data_out1(d_op1),.data_out2(d_op2),.data_in(d_inp),.wr(w_out),.write_enable(wr_en),.rd1(read1),.rd2(read2),.clk(clock));
always#5 clock=~clock;
initial
begin
$dumpfile("Reg_FILE.vcd");
$dumpvars(0,Tb_MY_REGFILE_4x4);
clock=0;
#10 d_inp=6;w_out=1;wr_en=1;//6
#10 wr_en=0;
#10 d_inp=3;w_out=2;wr_en=1;//3
#10 wr_en=0;
#10 d_inp=13;w_out=3;wr_en=1;//13
#10 wr_en=0;
#10 read1=1;read2=2;
end
endmodule
