module top_level_proximity(
	input CLOCK_50,
	inout [35:0] GPIO,
	input [3:0] KEY,	
	output [17:0] LEDR,
	output [7:0] LEDG
);

logic start;
logic echo, trigger, reset, trig_echo;
logic enable;
logic proximity_alarm

assign enable = 1;

assign echo = GPIO[34];
assign GPIO[35] = trigger;
assign LEDG[1] = echo;
assign LEDG[2] = trigger;
assign LEDG[7] = start;

logic counter_cond;
logic counter;

assign counter_cond = counter < 1;

always_ff @(posedge CLOCK_50) begin
	if (start == 1) begin
		if (counter_cond) begin
			counter = counter + 1;
			trig_echo = 1;
		end else begin
			trig_echo = 0;
		end
	end else begin
		counter = 0;
	end
end



debounce reset_edge(
    .clk(CLOCK_50),
	 .button(!KEY[0]),
    .button_edge(reset)
);

refresher333us measure_interval(
	.clk(CLOCK_50),
	.en(enable),
	.measure(start)
);


sensor_driver u0(
  .clk(CLOCK_50),
  .rst(trig_echo),
  .measure(start),
  .echo(echo),
  .trig(trigger), 
  .distance(LEDR),
  .proximity_sensor(LEDG[0]));
  

  
endmodule


  