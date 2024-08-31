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
	logic [4:0] bonus = 1; 				// the score multiplier
	logic [4:0] prev_hit;
	
	always_comb begin : count_bit_mask
	   hit_num = 0;
		for (i = 0; i<18;i=i+1) begin: count_bit
			if (hit_reg[i] == 1) begin
				hit_num = hit_num+1;
			end else;
		end
	end
	
	
//bonus points logic
	always_comb begin : bonus_logic
		if (prev_hit < hit_num) begin	//full combo
			bonus = 2;
		end else if (hit_num > 8) begin
			bonus = 5;
		end else begin
			bonus = 1;
		end
	end

	always_ff @(posedge clk) begin : updating_count
		if (!reset) begin
			temp_count = 0;
		end else begin
			temp_count <= prev_t_count + (hit_num * bonus);
		end
		prev_hit <= hit_num;
		
		
	end
	always_ff @(negedge clk) begin : save_prev_count
		if (!reset) begin
			prev_t_count <= 0;
		end else begin
			prev_t_count <= temp_count;
		end
	end
	
	assign score = temp_count;
endmodule
