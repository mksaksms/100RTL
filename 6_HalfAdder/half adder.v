
// Module: add_carry_out2
// Description: An simplified version of the previous module.

module add_carry_out2 #(
    parameter int WIDTH = 16
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    output logic [WIDTH-1:0] sum,
    output logic             carry_out
);

    // Instead of declaring a separate wider variable and then slicing into it,
    // we can instead use the concantenation operator on the LHS of the
    // assignment. SV chooses the width of an operation based on the max of the
    // operand widths AND the result width. Since the result is 1 bit wider,
    // SV will automatically 0 extend the operands to match. We could have
    // similarly remove the manual concatenations from the previous modules.
    assign {carry_out, sum} = in0 + in1;

endmodule


 
// Module: add_carry_inout
// Description: An extended version of the previous adder that also has a
//              carry in.

module add_carry_inout #(
    parameter int WIDTH = 16
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             carry_in,
    output logic [WIDTH-1:0] sum,
    output logic             carry_out
);

    // The carry in is automatically extended to match the result width, so
    // we only need to add it to the previous version.
    assign {carry_out, sum} = in0 + in1 + carry_in;

endmodule



