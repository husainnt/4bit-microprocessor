//IM
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
//imm
mem[5]=16'b0000_0100_00_01_10_00;//andi
mem[6]=16'b0000_0101_00_01_11_00;//ori
mem[7]=16'b0000_0110_00_01_10_00;//addi
mem[8]=16'b0000_0111_00_01_11_00;//subi
mem[9]=16'b0000_1001_00_01_10_00;//slti
//branch
mem[10]=16'b0000_1010_00_01_10_00;//beq
mem[11]=16'b0000_1011_00_01_10_00;//bne
//jmp
mem[12]=16'b0000_1100_0000_0011;//j
end
always@(*) 
instruction=mem[addr];
endmodule

module tb_im();
reg [3:0] addr;
wire [15:0] inst;
instruction_memory uut (addr, inst);
initial begin
    $dumpfile("im_wave.vcd");
    $dumpvars(0, tb_im);
    addr = 0; #10 addr = 2; #10 addr = 12; #10 $finish;
end
endmodule