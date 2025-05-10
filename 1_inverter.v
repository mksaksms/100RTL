module inverter (
    input  logic a,       // Input signal
    output logic y        // Output (inverted) signal
);

    // Invert the input
    assign y = ~a;

endmodule
