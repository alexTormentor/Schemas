module timer_mod(
input wire reset,
input wire clock,
output reg [5:0] sec,
output reg [5:0] min
);

always @(posedge clock)

begin
	if(reset)
		begin
		sec <= 6'b000000;
		min <= 6'b000000;
		end
	else
		begin
		if(sec == 6'b111011)
			begin
			sec <= 6'b000000;
			min <= min + 6'b000001;
			end
		else
			sec <= sec + 6'b000001;
		end
end
endmodule