module proximity(
	input clk,
	inout [35:0] gpio,
	output [7:0] distance,
	output proximity_sensor
);

logic start;
logic echo, trigger, reset;
logic enable;
//logic proximity_sensor;

assign enable = 1;
assign echo = gpio[34];
assign gpio[35] = trigger;
/*
assign LEDG[1] = echo;
assign LEDG[2] = trigger;
assign LEDG[7] = start;
*/
logic counter_cond;
logic counter;

assign counter_cond = counter < 1;

always_ff @(posedge clk) begin
	if (start == 1) begin
		if (counter_cond) begin
			counter = counter + 1;
			reset = 1;
		end else begin
			reset = 0;
		end
	end else begin
		counter = 0;
	end
end



/*debounce reset_edge(
    .clk(CLOCK_50),
	 .button(!KEY[0]),
    .button_edge(reset)
);*/

refresher100ms measure_interval(
	.clk(clk),
	.en(enable),
	.measure(start)
);


sensor_driver u0(
  .clk(clk),
  .rst(reset),
  .measure(start),
  .echo(echo),
  .trig(trigger), 
  .distance(distance),
  .proximity_sensor(proximity_sensor));
endmodule


  
