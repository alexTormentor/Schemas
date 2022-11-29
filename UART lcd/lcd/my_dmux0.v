module my_dmux0(
  input wire [7:0]in,
  input wire select,
  output reg [7:0]out1,
  output reg [7:0]out2
);

always @(select)
begin
  case( in )
   0:
	out1 = in;
   1:
	out2 = in;
  endcase
end

endmodule