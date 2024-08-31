module whackmole(
	input [17:0] switch,		//input from switch register ////////// change to "SW" to "debounced_sw" if the debounce module is feeding into it
	input [17:0] moles,	// input from the random number generator
	input clk,
	
	output [17:0] led_reg,	// output to the LEDR register
   output [17:0] hit_reg	//output of which bits were successful hits, used for scoring
);

	logic [17:0] previous_switch = 0; //the previous state of the switches
    logic [17:0] whacks = 0;
	 logic [17:0] hits = 0;
	 logic [17:0] whacked_moles =0;

    always_ff @(posedge clk) begin // change pos edge clock to the 1 or 2 second counter
        previous_switch <= switch;				// stores the state of the switches before they are switched in this cycle
    end

    always_comb begin
        //whacking logic
        whacks = switch ^ previous_switch; // any switches that switched are whacks
        hits = whacks & moles; // only bits whacks that hit a mole are hits
        whacked_moles = moles ^ hits; // turns off any moles that were hit
    end
	 
	 assign led_reg = whacked_moles; // outputs to the LED register
	 assign hit_reg = hits;			// passed into adrians module that counts the ON bits
	 
endmodule
