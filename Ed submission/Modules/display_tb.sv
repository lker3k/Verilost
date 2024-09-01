module display_tb;

    logic clk;
    logic [10:0] value;
    logic [6:0] display3, display2, display1, display0;

    display DUT (.*);

    initial forever #1 clk = ~clk; 

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        clk = 0;
        value = 1438;
        #(2*25);
        $display("7Segs: %b, %b, %b, %b",display3,display2,display1,display0);
        $finish();
    end

endmodule
