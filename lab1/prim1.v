module prim1(in, out);
input wire [3:0]in;
 output reg [7:0]out;
always@(in) begin
case (in)
0: out = 8'hC0;
1: out = 8'hF9;
2: out = 8'hA4;
3: out = 8'hB0;
4: out = 8'h99;
5: out = 8'h92;
6: out = 8'h82;
7: out = 8'hF8;
8: out = 8'h80;
9: out = 8'h90;
10: out = 8'h88;
11: out = 8'h83;
12: out = 8'hC6;
13: out = 8'hA1;
14: out = 8'h86;
15: out = 8'h8E;
endcase
end

endmodule
