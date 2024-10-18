module top_level(
	input CLOCK_50,
	inout [35:0] GPIO,
	input [3:0] KEY,
	output [7:0] LEDR,
	output [7:0] LEDG
);

logic start, reset;
logic echo, trigger;
assign start = 1;

assign echo = GPIO[34];
assign GPIO[35] = trigger;


debounce reset_edge(
    .clk(CLOCK_50),
	 .button(!KEY[2]),
    .button_edge(reset)
);

sensor_driver u0(
  .clk(CLOCK_50),
  .rst(reset),
  .measure(start),
  .echo(echo),
  .trig(trigger), 
  .distance(LEDR),
  .proximity_sensor(LEDG[0]));
  
endmodule