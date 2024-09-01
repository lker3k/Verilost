/** Copy and paste your seven_seg.v code from Lab 1 here. **/
module seven_seg (
    input      [3:0]  bcd,
    output reg [6:0]  segments // Must be reg to set in always block!!
);

    // Your `always @(*)` block and case block here!
always @(bcd) begin
    case (bcd)
        4'b0000: begin
            segments[6:0] = 7'b1000000;
        end
        4'b0001: begin
            segments[6:0] = 7'b1111001;
        end
        4'b0010: begin
            segments[6:0] = 7'b0100100;
        end
        4'b0011: begin
            segments[6:0] = 7'b0110000;
        end
        4'b0100: begin
            segments[6:0] = 7'b0011001;
        end
        4'b0101: begin
            segments[6:0] = 7'b0010010;
        end
        4'b0110: begin
            segments[6:0] = 7'b0000010;
        end
        4'b0111: begin
            segments[6:0] = 7'b1111000;
        end
        4'b1000: begin
            segments[6:0] = 7'b0000000;
        end
        4'b1001: begin
            segments[6:0] = 7'b0010000;
        end
        default: segments[6:0] = 7'b1111111;
    endcase
end
endmodule
