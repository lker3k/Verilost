module bit_counter(
   input           clk,
   input [17:0]    led_moles,
	input [17:0] 	hit_reg,
	input reset,
   output [10:0]    score
);
   logic [4:0] hit_num;			// count led bit thats HIGH
	integer i;
	logic [10:0] temp_count = 0;	// temp score to assign the score at the end of the clock cycle
	logic [10:0] prev_t_count=0;	// previous score from last cycle
	logic combo = 0; 				// the score multiplier
	
	always_comb begin : count_bit_mask
	   hit_num = 0;
		for (i = 0; i<18;i=i+1) begin: count_bit
			if (hit_reg[i] == 1) begin
				hit_num = hit_num+1;
			end else;
		end
	end

	always_comb begin : combo_logic
		if (prev_t_count == 0) begin
			combo = 1;
		end else if ((led_moles & hit_reg) == led_moles) begin	//full combo
			if (combo != 5) begin
				combo = combo + 1;
			end else;
		end else begin //miss combo, reset the combo
			combo = 1;
		end
	end

	always_ff @(posedge clk) begin : updating_count
		if (!reset) begin
			temp_count = 0;
		end else begin
			temp_count <= prev_t_count + (hit_num*combo);
		end
	end
	always_ff @(negedge clk) begin : save_prev_count
		prev_t_count <= temp_count;
	end
	assign score = temp_count;
endmodule
