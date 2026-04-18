module program_counter(
input clock,
input rst,
input[3:0]address,
output reg[3:0]pc
);

always@(posedge clock or posedge rst)begin
if(rst)
pc<=4'b0000;
else
pc<=address;
end
endmodule
//instrunction memory
module instruction_memory(
input[3:0]addr,
output reg[3:0]instruction
);

reg[3:0]mem[0:15];
initial begin
mem[0]=4'b0001;
mem[1]=4'b0010;
mem[2]=4'b0011;
mem[3]=4'b0100;
end

always@(addr)begin
instruction=mem[addr];
end
endmodule

module my_4b_PC_tb;
reg clock;
reg rst;
reg[3:0]address;
wire[3:0]pc;
wire[3:0]instr;

program_counter pc1(
.clock(clock),
.rst(rst),
.address(address),
.pc(pc)
);

instruction_memory im1(
.addr(pc),
.instruction(instr)
);

always begin
#5 clock=~clock;
end

initial begin
$dumpfile("PC_wave.vcd");
$dumpvars(0,my_4b_PC_tb );
clock=0;
rst=0;
address=0;

rst=1;
#10 rst=0;

#10 address=0;
#10 address=1;
#10 address=2;
end
endmodule

