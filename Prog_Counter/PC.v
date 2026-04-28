module program_counter(
input clk,
input clr,
input inc_PC,
input branch,
input jump,
input[3:0] offset,
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
pc<=pc+1+offset; 
else if(inc_PC)
pc<=pc+1; 
end
endmodule