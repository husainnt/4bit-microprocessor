module alu_4bit(
input[3:0] A,B,
input[2:0] alu_control,
output reg[3:0] result
);
always@(*) 
begin
if(alu_control==3'b000)
result=A&B;
else if(alu_control==3'b001)
result=A|B; 
else if(alu_control==3'b010)
result=A+B; 
else if(alu_control==3'b110)
result=A-B; 
else if(alu_control==3'b111) begin
if(A<B)
result=4'b0001; 
else
result=4'b0000; 
end
else
result=4'b0000; 
end
endmodule