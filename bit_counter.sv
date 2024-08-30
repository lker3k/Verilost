module bit_counter(
    input           clk,
    input [17:0]    led,
    output [10:0]    count
);
   logic [4:0] led_temp;
	integer i;
	logic [10:0] temp_count = 0;
	logic [10:0] prev_t_count=0;

	always_comb begin : count_bit_mask
	   led_temp = 0;
		for (i = 0; i<18;i=i+1) begin: count_bit
			if (led[i] == 1) begin
				led_temp = led_temp+1;
			end else;
		end
	end
	always_ff @(posedge clk) begin : updating_count
		temp_count <= prev_t_count + led_temp;
	end
	always_ff @(negedge clk) begin : save_prev_count
		prev_t_count <= temp_count;
	end
	assign count = temp_count;
endmodule
