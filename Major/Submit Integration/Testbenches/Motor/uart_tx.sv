module uart_tx #(
      parameter CLKS_PER_BIT = (50_000_000/115_200), // E.g. Baud_rate = 115200 with FPGA clk = 50MHz
		// 5 for tb/ 50000000/115200 for real
		//parameter CLKS_PER_BIT = (5),
      parameter BITS_N       = 8, // Number of data bits per UART frame
      parameter PARITY_TYPE  = 2  // 0 for none, 1 for odd parity, 2 for even.
) (
      input clk,
      input rst,
      input [BITS_N-1:0] data_tx,
      output logic uart_out,
      input valid,            // Handshake protocol: valid (when `data_tx` is valid to be sent onto the UART).
      output logic ready      // Handshake protocol: ready (when this UART module is ready to send data).
 );

   logic [BITS_N-1:0] data_tx_temp;
   logic [2:0]        bit_n;

   integer count;


   //logic baud_trigger;
   //assign baud_trigger = (count == CLKS_PER_BIT - 1);

   enum {IDLE, START_BIT, DATA_BITS, PARITY, STOP_BIT} current_state, next_state;

   always_comb begin : fsm_next_state
         case (current_state)
            IDLE:        next_state = valid                       ? START_BIT : IDLE; // Handshake protocol: Only start sending data when valid data comes through.
            START_BIT:   next_state = (count == CLKS_PER_BIT-1)   ? DATA_BITS: START_BIT;
            DATA_BITS:   next_state = (bit_n == BITS_N-1 && count == CLKS_PER_BIT-1)  ? 
                                                                                 (PARITY_TYPE ? PARITY : STOP_BIT) 
                                                                              : DATA_BITS; // Send all `BITS_N` bits.
            PARITY:      next_state = (count == CLKS_PER_BIT-1) ? STOP_BIT : PARITY;
            STOP_BIT:    next_state = (count == CLKS_PER_BIT-1) ? IDLE : STOP_BIT;
            default:     next_state = IDLE;
         endcase
   end
   
   always_ff @( posedge clk ) begin : fsm_ff
      if (rst) begin
         current_state <= IDLE;
         data_tx_temp <= 0;
         bit_n <= 0;
         count <= 0;
      end
      else begin
         current_state <= next_state;
         case (current_state)
            IDLE: begin // Idle -- register the data to send (in case it gets corrupted by an external module). Reset counters.
               data_tx_temp <= data_tx;
               bit_n <= 0;
               count <= 0;
            end
            DATA_BITS: begin // Data transfer -- Count up the bit-index to send.
               if (count == CLKS_PER_BIT-1) begin
                  bit_n <= bit_n + 1'b1;
                  count <= 0;
               end else begin
                  count <= count + 1;
               end
            end
            START_BIT, STOP_BIT, PARITY: begin
               if (count == CLKS_PER_BIT-1) begin
                  count <= 0;
               end else begin
                  count <= count + 1;
               end
            end
         endcase
      end
   end

   always_comb begin : fsm_output
         uart_out = 1'b1; // Default: The UART line is high.
         ready = 1'b0;    // Default: This UART module is only ready for new data when in the IDLE state.
         case (current_state)
            IDLE:   begin
               ready = 1'b1;  // Handshake protocol: This UART module is ready for new data to send.
            end
            DATA_BITS:    begin
               uart_out = data_tx_temp[bit_n]; // Set the UART TX line to the current bit being sent.
            end
            START_BIT:    begin
               uart_out = 1'b0; // The start condition is a zero.
            end
				//unused
            PARITY:       begin
               if (PARITY_TYPE == 1) begin //odd parity
                  uart_out = ~^data_tx_temp;
               end else if (PARITY_TYPE == 2) begin
                  uart_out = ^data_tx_temp;
               end else;
            end
         endcase
   end

 endmodule

