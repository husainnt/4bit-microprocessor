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