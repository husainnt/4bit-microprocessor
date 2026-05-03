module decoder2x4(input[1:0] wr, input write_enable, output reg[3:0] dec_out);
always@(*) begin if(write_enable == 0) begin
if(wr==2'b00) dec_out=4'b0001; else if(wr==2'b01) dec_out=4'b0010;
else if(wr==2'b10) dec_out=4'b0100; else if(wr==2'b11) dec_out=4'b1000;
else dec_out=4'b0000; end else dec_out=4'b0000; end endmodule
//mux
module mux4x1(input[3:0] in0,in1,in2,in3, input[1:0] sel, output reg[3:0] out);
always@(*) begin if(sel==2'b00) out=in0; else if(sel==2'b01) out=in1;
else if(sel==2'b10) out=in2; else if(sel==2'b11) out=in3;
else out=4'b0000; end endmodule
//reg
module REG4bit(output reg[3:0] q, input[3:0] d, input clk, input load, input clr);
initial q = 4'b0000;
always@(negedge clk or negedge clr) begin if(clr==0) q<=4'b0000; 
else begin if(load) q<=d; end end endmodule

//REG_FILE
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

module tb_rf();
reg clk, clr, we; reg [1:0] wr, rd1, rd2; reg [3:0] d_in;
wire [3:0] out1, out2;
register_file_4x4 uut (out1, out2, d_in, wr, rd1, rd2, we, clk, clr);
always #5 clk = ~clk;
initial begin
    $dumpfile("rf_wave.vcd");
    $dumpvars(0, tb_rf);
    clk = 0; clr = 0; #7 clr = 1;
    we = 0; wr = 2'b01; d_in = 4'h7; #10 we = 1;
    rd1 = 2'b01; #10 $finish;
end
endmodule