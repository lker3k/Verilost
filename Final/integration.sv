module integration(
    input CLOCK_50,
    input [17:0] SW,
    input [3:0] KEY,

    output [17:0] LEDR,
    output [6:0] HEX0, HEX1, HEX2, HEX3
);
    //wire [17:0] switch; //debounce switch
    //wire [3:0] key;     //debounce key
    wire general_timer; //general clock for every module
    wire [17:0] moles;  //random moles
    wire [17:0] hit;    //player's hit
    wire [10:0] score;  //player's score
    /*
    genvar i;
    generate 
        for (i=0, i<18, i=i+1) begin : switch_debounce
            debounce sw_debounce (
                //Input 
                .clk(CLOCK_50),
                .button(SW[i]),
                //Output 
                .button_pressed(switch[i])
            );
        end
        for (i=0, i<4, i=i+1) begin : key_debounce
            debounce k_debounce (
                //Input
                .clk(CLOCK_50),
                .button(KEY[i]),
                //Output
                .button_pressed(key[i])
            );
        end
    endgenerate
    */
    timer general_clk (
        //Input
        .clk(CLOCK_50),
        .enable(KEY[3]),
        .reset(KEY[0]),
        //Output
        .max_reached(general_timer));

    rng rng (
        //Input
        .clk(CLOCK_50),
        .reset(KEY[0]),
        .change(general_timer),
        //Output
        .random_value(moles));
    
    whackmole whacking_logic (
        //Input 
        .clk(general_timer),
        .moles(moles),
        .switch(SW),
        //Output
        .hit_reg(hit),
        .led_reg(LEDR));
    
    bit_counter hit_counter (
        //Input
        .clk(general_timer),
        .reset(KEY[0]),
        .led_moles(moles),
        .hit_reg(hit),
        //Output
        .score(score));
    
    display display (
        //Input
        .clk(CLOCK_50),
        .value(score),
        //Output
        .display0(HEX0),
        .display1(HEX1),
        .display2(HEX2),
        .display3(HEX3));
endmodule
