module debounce #(
  parameter DELAY_COUNTS = 2500 // 50us with clk period 20ns is ____ counts
) (
    input clk, button,
    output reg button_pressed
);

  // Use a synchronizer to synchronize `button`.
  wire button_sync; // Output of the synchronizer. Input to your debounce logic.
  synchroniser button_synchroniser (.clk(clk), .x(button), .y(button_sync));

  // Note: Use the synchronized `button_sync` wire as the input signal to the debounce logic.
  

  /*** Fill in the following scaffold: ***/
  reg [11:0]count;
  reg prev_button;
  // Set the count flip-flop:
  always @(posedge clk) begin
      if (button_sync != prev_button) begin
        count <= 0;
      end
      else if (count == DELAY_COUNTS) begin
        count <= count + 0;
      end
      else begin
        count <= count + 1;
      end
  end

  // Set the prev_button flip-flop:
  always @(posedge clk) begin
    if (button_sync != prev_button) begin
      prev_button <= button_sync;
    end
    else;
  end

  // Set the button_pressed flip-flop:
  always @(posedge clk) begin
    if (button_sync == prev_button && count == DELAY_COUNTS) begin
      button_pressed <= button_sync;
    end
    else;
  end

endmodule


