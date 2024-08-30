module integration(
    input clk,
    input [17:0] led,
    input [17:0] whacked,
    output [6:0]  display0,
    output [6:0]  display1,
    output [6:0]  display2,
    output [6:0]  display3
);
    wire [10:0] score;
    bit_counter bit_counter0 (
        //Inputs
        .clk(clk),
        .led(led),
        .whacked(whacked),
        //Output
        .score(score));

    display display_u0(
        //Inputs
        .clk(clk),
        .value(score),
        //Outputs
        .display0(display0),
        .display1(display1),
        .display2(display2),
        .display3(display3));
endmodule
