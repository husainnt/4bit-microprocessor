//Prog Counter
module program_counter(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input[3:0] ovf_flagfset,
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
pc<=pc+1+ovf_flagfset; 
else if(inc_PC)
pc<=pc+1; 
end
endmodule

module tb_pc();
reg clk, clr, inc_PC, branch, jump;
reg [3:0] offset, jump_addr;
wire [3:0] pc;

program_counter uut (clk, clr, inc_PC, branch, jump, offset, jump_addr, pc);

always #5 clk = ~clk;
initial begin
    $dumpfile("pc_wave.vcd");
    $dumpvars(0, tb_pc);
    clk = 0; clr = 1; inc_PC = 0; branch = 0; jump = 0;
    #10 clr = 0; inc_PC = 1;
    #20 jump = 1; jump_addr = 4'hA;
    #10 jump = 0;
    #20 $finish;
end
endmodule