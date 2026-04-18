module ALU_1B_GTL(a,b,cin,s1,s0,binv,out,cout);
input a,b,cin,s1,s0,binv;
output out,cout;
wire b_new;
wire and1;
wire or1;
wire xor1;
wire xor2;
wire c1,c2;

xor(b_new,b,binv);
and(and1,a,b);
or(or1,a,b);
//FA
xor(xor1,a,b_new);
xor(xor2,xor1,cin);
and(c1,a,b_new);
and(c2,cin,xor1);
or(cout,c1,c2);

wire w1,w2,w3,w4;
and(w1,and1,~s1,~s0);
and(w2,or1,~s1,s0);
and(w3,xor2,s1,~s0);
and(w4,xor2,s1,s0);
or(out,w1,w2,w3,w4);
endmodule
//4bit
module ALU_4B_GTL #(parameter SIZE = 4)
(input a3,a2,a1,a0,input b3,b2,b1,b0,input s2,s1,s0,output r3,r2,r1,r0,output cf,zf,sf,of);
wire c0,c1,c2,c3;
wire sub;
wire z1,z2;
wire slt_bit;
or(sub,s0,s2);
ALU_1B_GTL u0(a0,b0,sub,s1,s0,sub,r0,c0);
ALU_1B_GTL u1(a1,b1,c0,s1,s0,sub,r1,c1);
ALU_1B_GTL u2(a2,b2,c1,s1,s0,sub,r2,c2);
ALU_1B_GTL u3(a3,b3,c2,s1,s0,sub,r3,c3);
//flags
and(cf,c3,1'b1);
and(sf,r3,1'b1);
nor(z1,r0,r1);
nor(z2,r2,r3);
and(zf,z1,z2);
xor(of,c2,c3);
//slt
xor(slt_bit,r3,of);
wire nr0,nr1,nr2;
//lsb=slt
and(nr0,slt_bit,s2);
and(nr1,1'b0,s2);
and(nr2,1'b0,s2);

wire n_s2;
not(n_s2,s2);
wire r0_final,r1_final,r2_final,r3_final;

and(r0_final,r0,n_s2);
and(r1_final,r1,n_s2);
and(r2_final,r2,n_s2);
and(r3_final,r3,n_s2);

or(r0,r0_final,nr0);
or(r1,r1_final,nr1);
or(r2,r2_final,nr2);
or(r3,r3_final,1'b0);
endmodule
module test;
parameter SIZE = 4;
reg a3,a2,a1,a0,b3,b2,b1,b0,s2,s1,s0;
wire r3,r2,r1,r0,cf,zf,sf,of;

ALU_4B_GTL #(SIZE) myalu(a3,a2,a1,a0,b3,b2,b1,b0,s2,s1,s0,r3,r2,r1,r0,cf,zf,sf,of);
initial begin
$dumpfile("ALU_wave.vcd");
$dumpvars(0, test);
a3=0;a2=0;a1=1;a0=1;b3=0;b2=0;b1=0;b0=1;s2=0;s1=0;s0=0;#10;
a3=0;a2=1;a1=0;a0=0;b3=0;b2=0;b1=0;b0=1;s2=0;s1=0;s0=1;#10;
a3=1;a2=1;a1=0;a0=0;b3=1;b2=0;b1=1;b0=0;s2=0;s1=1;s0=0;#10;
a3=0;a2=0;a1=0;a0=1;b3=0;b2=0;b1=1;b0=0;s2=1;s1=0;s0=0;#10;
end
endmodule
