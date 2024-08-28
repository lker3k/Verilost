module whackmole(
   input [17:0] SW,
	input clk,
	output [17:0] LEDR,
   output [17:0] hits
);

    logic [17:0] previous_SW; //the previous state of the switches
    logic [17:0] whacks;

    always_ff @(posedge clk) begin
        previous_SW <= SW;
    end

    always_comb begin
        //whacking logic
        whacks = SW ^ previous_SW; // any bits that changed are whacks
        hits = whacks & LEDR; // only bits whacks that hit a mole are hits
        LEDR = LEDR ^ hits; // turns off any moles that were hit
    end
endmodule
