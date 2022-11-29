module clock_divider1Hz(
	input wire clock,
	output reg out
);
    reg[11:0]clkr_4000 = 12'b0;
    initial begin
        out = 0;
    end
    always @(posedge clock)
    begin
        clkr_4000 <= clkr_4000 + 12'b1;
        if (clkr_4000 == 200)
        begin
            clkr_4000 <= 12'b0;
            out <= ~out;
        end
    end
endmodule
