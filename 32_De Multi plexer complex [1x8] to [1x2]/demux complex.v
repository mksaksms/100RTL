module demux_1x8 (
    input  logic din,
    input  logic [2:0] sel,
    output logic [7:0] y
);
    // Using logic equations directly (expanded form)
    assign y[0] = din & ~sel[2] & ~sel[1] & ~sel[0];
    assign y[1] = din & ~sel[2] & ~sel[1] &  sel[0];
    assign y[2] = din & ~sel[2] &  sel[1] & ~sel[0];
    assign y[3] = din & ~sel[2] &  sel[1] &  sel[0];
    assign y[4] = din &  sel[2] & ~sel[1] & ~sel[0];
    assign y[5] = din &  sel[2] & ~sel[1] &  sel[0];
    assign y[6] = din &  sel[2] &  sel[1] & ~sel[0];
    assign y[7] = din &  sel[2] &  sel[1] &  sel[0];
endmodule
