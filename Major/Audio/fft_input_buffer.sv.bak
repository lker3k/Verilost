module fft_input_buffer #(
    parameter W = 16,
    parameter NSamples = 1024
) (
    input                      clk,
    input                      reset,
    input                      audio_clk,
    dstream.in                 audio_input,
    output logic [W-1:0]       fft_input,
    output logic               fft_input_valid
);
    logic fft_read;
    logic full, wr_full;

    // Instantiate the FIFO
    async_fifo u_fifo (
        .aclr(reset),
        .data(audio_input.data),        
        .wrclk(audio_clk),
        .wrreq(audio_input.valid),      
        .wrfull(wr_full),
        .q(fft_input),
        .rdclk(clk),
        .rdreq(fft_read),
        .rdfull(full)
    );

    assign audio_input.ready = !wr_full;

    // State machine definitions
    typedef enum logic [1:0] {IDLE_STATE, READ_STATE} state_t;
    state_t state, next_state;

    integer n;

    // State and counter update
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE_STATE;
            n <= 0;
        end else begin
            state <= next_state;
            if (state == READ_STATE) begin
                if (n < NSamples - 1) begin
                    n <= n + 1;
                end else begin
                    n <= 0;
                end
            end else begin
                n <= 0;
            end
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE_STATE: begin
                if (full) begin
                    next_state = READ_STATE;
                end else begin
                    next_state = IDLE_STATE;
                end
            end
            READ_STATE: begin
                if (n == NSamples - 1) begin
                    next_state = IDLE_STATE;
                end else begin
                    next_state = READ_STATE;
                end
            end
            default: next_state = IDLE_STATE;
        endcase
    end

    assign fft_read = (state == READ_STATE);
    assign fft_input_valid = fft_read;
endmodule
