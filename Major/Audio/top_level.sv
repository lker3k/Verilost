module top_level (
    input    CLOCK_50,
    output   I2C_SCLK,
    inout    I2C_SDAT,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    input  [3:0] KEY,
    input    AUD_ADCDAT,
    input    AUD_BCLK,
    output   AUD_XCK,
    input    AUD_ADCLRCK,
    output logic [17:0] LEDR
    // Add other outputs if necessary
);
    localparam W        = 16;
    localparam NSamples = 1024;

    // Update these parameters based on your bell's frequency range
    localparam k_min = 22; // Minimum FFT bin for bell frequency
    localparam k_max = 23; // Maximum FFT bin for bell frequency

    logic adc_clk;
    adc_pll adc_pll_u (.areset(1'b0), .inclk0(CLOCK_50), .c0(adc_clk));
    logic i2c_clk;
    i2c_pll i2c_pll_u (.areset(1'b0), .inclk0(CLOCK_50), .c0(i2c_clk));

    set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

    dstream #(.N(W))                audio_input ();
    dstream #(.N($clog2(NSamples))) pitch_output ();

    mic_load #(.N(W)) u_mic_load (
        .adclrc(AUD_ADCLRCK),
        .bclk(AUD_BCLK),
        .adcdat(AUD_ADCDAT),
        .sample_data(audio_input.data),
        .valid(audio_input.valid)
    );

    assign AUD_XCK = adc_clk;

    fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
        .clk(adc_clk),
        .audio_clk(AUD_BCLK),
        .reset(~KEY[0]),
        .audio_input(audio_input),
        .pitch_output(pitch_output)
    );

    logic bell_detected;
    logic [$clog2(NSamples)-1:0] display_value;

    always_ff @(posedge adc_clk) begin
        if (pitch_output.valid) begin
            // Check if the peak_k falls within the bell frequency range
            if ((pitch_output.data >= k_min) && (pitch_output.data <= k_max)) begin
                bell_detected <= 1'b1;
            end else begin
                bell_detected <= 1'b0;
            end
            display_value <= bell_detected; // Use bell_detected for display
        end
    end

    display u_display (
        .clk(adc_clk),
        .value(display_value),
        .display0(HEX0),
        .display1(HEX1),
        .display2(HEX2),
        .display3(HEX3)
    );

    assign LEDR[0] = bell_detected; // Indicate detection on LED
    // Connect bell_detected to motor control or other modules as needed

endmodule
