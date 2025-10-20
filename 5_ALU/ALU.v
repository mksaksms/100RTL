module alu #(
    parameter int WIDTH
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [      1:0] sel,
    output logic             neg,
    output logic             pos,
    output logic             zero,
    output logic [WIDTH-1:0] out
);

    always_comb begin
        case (sel)
            // Addition
            2'b00: out = in0 + in1;
            // Subtraction
            2'b01: out = in0 - in1;
            // And
            2'b10: out = in0 & in1;
            // Or
            2'b11: out = in0 | in1;
        endcase

        // By moving the flag definitions outside the case statements, we
        // guarantee that all flags are defined on all paths, which eliminates
        // the latches.
        if (out == 0) begin
            pos  = 1'b0;
            neg  = 1'b0;
            zero = 1'b1;
        end else if (out[WIDTH-1] == 1'b0) begin
            pos  = 1'b1;
            neg  = 1'b0;
            zero = 1'b0;
        end else begin
            pos  = 1'b0;
            neg  = 1'b1;
            zero = 1'b0;
        end
    end
	
	
	
endmodule