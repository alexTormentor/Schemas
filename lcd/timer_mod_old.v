module timer_mod(
	input wire reset,
	input wire clock,
	output reg[5:0] sec,
	output reg[5:0] min,
	output reg[5:0] hour
);
    always @(posedge clock) 
	begin
        if (reset) 
		begin
            sec <= 6'b000000;
            min <= 6'b000000;
            hour <= 6'b000000;
        end
        else 
		begin
            if (sec == 6'b111011) 
			begin
	            sec <= 6'b000000;
	            if (min == 6'b111011) 
				begin
		            min <= 6'b000000;
		            if (hour == 6'b010111)
		                hour <= 6'b000000;
		            else
		                hour <= hour + 6'b000001;
		        end
	            else
		            min <= min + 6'b000001;
		    end
            else
                sec <= sec + 6'b000001;
        end
    end
endmodule
