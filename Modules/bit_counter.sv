module bit_counter(
   input           clk,
   input [17:0]    led,
	input [17:0] 	whacked,
   output [10:0]    score
);
   logic [4:0] led_temp;			// count led bit thats HIGH
	integer i;
	logic [10:0] temp_count = 0;	// temp score to assign the score at the end of the clock cycle
	logic [10:0] prev_t_count=0;	// previous score from last cycle
	logic combo = 0; 				// the score multiplier
	
	always_comb begin : count_bit_mask
	   led_temp = 0;
		for (i = 0; i<18;i=i+1) begin: count_bit
			if (whacked[i] == 1) begin
				led_temp = led_temp+1;
			end else;
		end
	end

	always_comb begin : combo_logic
		if (prev_t_count == 0) begin
			combo = 1;
		end else if ((led & whacked) == led) begin	//full combo
			if (combo != 5) begin
				combo = combo + 1;
			end else;
		end else begin //miss combo, reset the combo
			combo = 1;
		end
	end

	always_ff @(posedge clk) begin : updating_count
		temp_count <= prev_t_count + (led_temp*combo);
	end
	always_ff @(negedge clk) begin : save_prev_count
		prev_t_count <= temp_count;
	end
	assign score = temp_count;
endmodule
