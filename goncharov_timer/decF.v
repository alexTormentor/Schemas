module decF(in, out);
input wire [3:0]in;
output reg [7:0]out;
always@(in) begin
case (in)
0: out = 'hC0;
1: out = 8'hF9;
2: out = 8'hA4;
3: out = 8'hB0;
4: out = 8'h99;
5: out = 8'h92;
6: out = 8'h82;
7: out = 8'hF8;
8: out = 8'h80;
9: out = 8'h90;
endcase
end

endmodule