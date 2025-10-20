module multiplier_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);

    assign product = a * b;

endmodule
