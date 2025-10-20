module subtractor_4bit (
    input  logic [3:0] a,      // Minuend
    input  logic [3:0] b,      // Subtrahend
    output logic [3:0] diff,   // Result of a - b
    output logic       borrow  // Borrow-out flag
);

    logic [4:0] result;

    // Subtract using 2’s complement: a - b = a + (~b + 1)
    assign result = {1'b0, a} + (~{1'b0, b}) + 1;


endmodule
