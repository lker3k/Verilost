import lcd_inst_pkg::*;
	
module programmer (
    input  logic clk,
    input  logic reset,
    input  logic left,
    input  logic right,
    input  logic select,
    output logic [2:0] filter_mode,
    // Avalon-MM signals to LCD_Controller slave:
    output logic address,
    output logic chipselect,
    output logic byteenable,
    output logic read,
    output logic write,
    input  logic waitrequest,
    input  logic [7:0] readdata,
    input  logic [1:0] response,
    output logic [7:0] writedata
);
    // State encoding for FSM
    typedef enum logic [1:0] {IDLE, WRITE_OP} state_t;
    state_t current_state, next_state;

    typedef enum logic [2:0] {NOFILTER, DESATURATE, COLOURSHIFT, BLUR, EDGE} filter_select_t;
    filter_select_t current_filter, next_filter;

    // Rising edge detect
    logic redge_right, right_q; 
    logic redge_left, left_q; 
    logic redge_select, select_q; 
    always_ff @(posedge  clk) begin : rising_edge_ff
        right_q <= right;
        left_q <= left;
        select_q <= select;
    end

    assign redge_right = ~right_q & right; // rising edge detected!
    assign redge_left = ~left_q & left;
    assign redge_select = ~select_q & select;

    always_comb begin
    //next_state = current_state; // Default Value for next_state
        case (current_filter)
            NOFILTER    : next_filter = (redge_right) ? DESATURATE    : (redge_left) ? EDGE           : NOFILTER;
            DESATURATE  : next_filter = (redge_right) ? COLOURSHIFT   : (redge_left) ? NOFILTER       : DESATURATE;
            COLOURSHIFT : next_filter = (redge_right) ? BLUR          : (redge_left) ? DESATURATE     : COLOURSHIFT;
            BLUR        : next_filter = (redge_right) ? EDGE          : (redge_left) ? COLOURSHIFT    : BLUR;
            EDGE        : next_filter = (redge_right) ? NOFILTER      : (redge_left) ? BLUR           : EDGE;
            //default     : next_state = NOFILTER;
        endcase
    end


    always_ff @(posedge clk) begin : next_filter_logic
        current_filter <= next_filter;
    end

    logic [2:0] selected_filter;
    always_ff @(posedge redge_select) begin : select_mode
        selected_filter <= current_filter;
    end

    always_comb begin : filter_output
        case (selected_filter)
            NOFILTER    : filter_mode = 0;
            DESATURATE  : filter_mode = 1;
            COLOURSHIFT : filter_mode = 2;
            BLUR        : filter_mode = 3;
            EDGE        : filter_mode = 4;
            default     : filter_mode = 0;
        endcase
    end

    // LCD instructions
    localparam N_INSTRS = 11; // Change this to the number of instructions you have below:
    logic [8:0] instructions [N_INSTRS];//= '{CLEAR_DISPLAY, _H, _e, _l, _l, _o, _SPACE, _W, _o, _r, _l, _d, _EXCLAMATION}; // Clear display then display "Hi".
    // In the above array, **bit-8 is the 1-bit `address`** and bits 7 down-to 0 give the 8-bit data.
    always_comb begin
        if          (NOFILTER) begin instructions       = '{CLEAR_DISPLAY,      _N,     _o,     _SPACE, _F,     _i,     _l,     _t,     _e,     _r,     _SPACE};
        end else if (DESATURATE) begin instructions     = '{CLEAR_DISPLAY,      _D,     _e,     _s,     _a,     _t,     _u,     _r,     _a,     _t,     _e};
        end else if (COLOURSHIFT) begin instructions    = '{CLEAR_DISPLAY,      _S,     _h,     _i,     _f,     _t};
        end else if (BLUR) begin instructions           = '{CLEAR_DISPLAY,      _B,     _l,     _u,     _r};
        end else if (EDGE) begin instructions           = '{CLEAR_DISPLAY,      _E,     _d,     _g,     _e};
        end else begin instructions                     = '{CLEAR_DISPLAY,      _E,     _R,     _R,     _O,     _R,     _EXCLAMATION};
        end
    end
    //........................................................................................
    //........................................................................................
    // LCD FSM
    integer instruction_index = 0, next_instruction_index; // You can use these to count.
    
    always_ff @(posedge clk) begin
        if (reset) begin
            instruction_index <= 0;
            next_instruction_index <= 0;

        end else begin
            current_state <= next_state;
             case (current_state)
                WRITE_OP: begin
                    if (waitrequest == 0) begin
                        instruction_index <= instruction_index + 1;
                    end
                end
             endcase
        end
    end

    always_comb begin: next_state_logic
        next_state = IDLE;
        case (current_state) 
            IDLE:       next_state = (instruction_index < N_INSTRS) ? WRITE_OP : IDLE;
            WRITE_OP:   next_state = (waitrequest == 0) ? IDLE : WRITE_OP;
        endcase
    end

	always_comb begin: fsm_output
		address		= '0;
		chipselect  = 0;
		write       = 0;
		writedata   = '0;
		read 		= 0;
		byteenable  = 1;
        case (current_state) 
            IDLE:       begin
                address     = instructions[instruction_index][8];
                chipselect  = 0;
                write       = 0;
                writedata   = 0;
				read 		= 0;
				byteenable  = 1;
            end

            WRITE_OP:   begin
                chipselect  = 1;
                write       = 1;
                writedata   = instructions[instruction_index][7:0];
				read 		= 0;
				byteenable  = 1;
            end
        endcase

    end

endmodule
