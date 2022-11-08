module bin6_to_dec(
input wire [5:0] value,
output reg [3:0] dig0,
output reg [3:0] dig1
);

always @(value)

begin
	dig0 = value % 10;
	dig1 = value / 10;
end
endmodule