module rng #(
  parameter OFFSET = 1, // base number 1 for 1 LED (minimum moles)
    parameter MAX_VALUE = 2622143, // Maximum value for the output
    parameter SEED = 123457        // random choosing point
) (
    input clk,
    input reset,
    input change,
  output reg [17:0] random_value // Width based on 18 bit number
);


    reg [17:1] lfsr; // Adjusted LFSR size for proper feedback and coverage

    // Initialize the shift register to SEED, which should be a non-zero value:
    initial lfsr = SEED; // Initialize only the relevant bits of the LFSR

    // Set the feedback:
    wire feedback;
    reg [17:0] current_value;

    always @(posedge clk or negedge reset) begin
	    if (!reset) begin
            lfsr <= 18'b0; // Adjust the width here
            random_value <= 0;
        end 
        else if (change) begin
            lfsr <= {lfsr[17:1], feedback}; // Shift the LFSR and input the feedback bit
            current_value <= lfsr[17:1]; // Truncate or map LFSR to match the width
            random_value <= current_value + OFFSET;
        end else begin 
				random_value <= 18'b0;
			end
    end

    assign feedback = lfsr[13] ^ lfsr[12]; // Feedback based on adjusted LFSR size

endmodule
