module fft_input_buffer #(
    parameter W = 16,
    parameter NSamples = 1024
) (
    input                clk,
    input                reset,
    input                audio_clk,
    dstream.in           audio_input,
    output logic [W-1:0] fft_input,
    output logic         fft_input_valid
);

    // Your code here!
	 logic fft_read = 0;
    logic full, wr_full;
    async_fifo u_fifo (.aclr(reset),
                        .data(audio_input.data),.wrclk(audio_clk),.wrreq(audio_input.valid),.wrfull(wr_full),
                        .q(fft_input),          .rdclk(clk),      .rdreq(fft_read),         .rdfull(full)    );
    assign audio_input.ready = !wr_full;

    assign fft_input_valid = fft_read; // The Async FIFO is set such that valid data is read out whenever the rdreq flag is high.
    
    //TODO implement a counter n to set fft_read to 1 when the FIFO becomes full (use full, not wr_full).
    logic [10:0] counter = 0;
     // Then, keep fft_read set to 1 until 1024 (NSamples) samples in total have been read out from the FIFO.
    //assign fft_read = full;
    always_comb begin
		fft_read = 1;
        if (reset) begin
            fft_read = 0;
        end else if (fft_read == 1) begin
            if (counter == NSamples) begin
                fft_read = 0;
            end else;
        end else if (full) begin
            fft_read = 1;
        end
    end
    always_ff @(posedge clk) begin : fifo_flush
        // Increment your counter here.
        // Remember to use reset.
        if (reset) begin
            counter <= 0;
        end else if ( fft_read == 0) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end


endmodule
