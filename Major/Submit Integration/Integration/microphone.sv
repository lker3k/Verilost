module microphone (
    input    clk,
	 input 	 reset,
    output   i2c_sclk,
    inout    i2c_sdat,
    input    aud_ADCDAT,
    input    aud_BCLK,
    output   aud_XCK,
    input    aud_ADCLRCK,
    output logic bell_detected
    // Add other outputs if necessary
);
    localparam W        = 16;
    localparam NSamples = 1024;

    // Update these parameters based on your bell's frequency range
    localparam k_min = 40; // Minimum FFT bin for bell frequency
    localparam k_max = 60; // Maximum FFT bin for bell frequency

    logic adc_clk;
    adc_pll adc_pll_u (.areset(1'b0), .inclk0(clk), .c0(adc_clk));
    logic i2c_clk;
    i2c_pll i2c_pll_u (.areset(1'b0), .inclk0(clk), .c0(i2c_clk));

    set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(i2c_sclk), .I2C_SDAT(i2c_sdat));

    dstream #(.N(W))                audio_input ();
    dstream #(.N($clog2(NSamples))) pitch_output ();

    mic_load #(.N(W)) u_mic_load (
        .adclrc(aud_ADCLRCK),
        .bclk(aud_BCLK),
        .adcdat(aud_ADCDAT),
        .sample_data(audio_input.data),
        .valid(audio_input.valid)
    );

    assign aud_XCK = adc_clk;

    fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
        .clk(adc_clk),
        .audio_clk(aud_BCLK),
        .reset(reset),
        .audio_input(audio_input),
        .pitch_output(pitch_output)
    );

    //logic bell_detected;
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
		/*
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
	 */

endmodule
