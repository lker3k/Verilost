module filterselect_tb;
    // Parameters
    localparam CLK_PERIOD = 20; // Clock period (20ns = 50MHz)

    // Testbench signals
    logic clk;
    logic reset;
    logic left;
    logic right;
    logic select;
    logic [2:0] filter_mode;
    logic address;
    logic chipselect;
    logic byteenable;
    logic read;
    logic write;
    logic waitrequest;
    logic [7:0] readdata;
    logic [1:0] response;
    logic [7:0] writedata;

    // Instantiate the hello_lcd module
    filterselect dut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .chipselect(chipselect),
        .byteenable(byteenable),
        .read(read),
        .write(write),
        .waitrequest(waitrequest),
        .readdata(readdata),
        .response(response),
        .writedata(writedata),
        .left(left),
        .right(right),
        .select(select),
        .filter_mode(filter_mode)
    );



    // Clock generation
    initial begin : clk_gen
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Testbench procedure
    initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        reset = 1;
        left = 1;
        right = 1;
        select = 1;
        readdata = 8'h00;
        response = 2'b00;

        // Wait for a few clock cycles
        #(5 * CLK_PERIOD);

        // Release reset
        reset = 0;

        // Wait for a few clock cycles
		  
        #(30 * CLK_PERIOD);
        left = 0;
        #(2 * CLK_PERIOD);
        left = 1;
        #(2 * CLK_PERIOD);
		  left = 0;
        #(2 * CLK_PERIOD);
        left = 1;
        #(2 * CLK_PERIOD);
        select = 0;
        #(2 * CLK_PERIOD);
        select = 1;
        #(2 * CLK_PERIOD);
        // Wait for the sequence to complete
        #(dut.N_INSTRS * CLK_PERIOD * 2);

        // Stop the simulation
        $finish();
    end

    logic random_stall;
    always_ff @(posedge clk) begin : waitrequest_random_stall
        // Randomly stall by asserting waitrequest:
        random_stall <= (($urandom() % 8) >= 5); // Stall 37.5% of the time (when write=1).
    end
    assign waitrequest = write ? random_stall : 1'b0;

    always_ff @(posedge clk) begin : write_monitor
        if (write && !waitrequest) begin
            //if (address == 0) $display("Written control instruction %b to address %b.", writedata, address);
            //else              
				$display("Written ASCII character %c to address %b.", writedata, address);        
        end
    end

endmodule