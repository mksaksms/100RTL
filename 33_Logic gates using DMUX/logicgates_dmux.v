

module demux_1x2(
    input  logic din,     // input data
    input  logic sel,     // select line
    output logic y0, y1   // outputs
);
    always_comb begin
        // default values
        y0 = 1'b0;
        y1 = 1'b0;

        // if condition to select output
        if (sel == 1'b0)
            y0 = din;
        else
            y1 = din;
    end
endmodule



module not_using_demux (
    input  logic a,
    output logic y
);
    logic y0, y1;

    // DEMUX: routes 1'b1 to one of two outputs depending on 'a'
    demux_1x2 d1 (.din(1'b1), .sel(a), .y0(y0), .y1(y1));

    // For NOT, output is active when 'a' = 0
    assign y = y0;  // y = ~a
endmodule







module and_using_demux (
    input  logic a, b,
    output logic y
);
    logic y0, y1;

    // DEMUX instance
    demux_1x2 d1 (.din(a), .sel(b), .y0(y0), .y1(y1));

    // output is y1 (active only when sel=b=1 and a=1)
    assign y = y1;
endmodule



module nand_using_demux (
    input  logic a, b,
    output logic y
);
    logic y0, y1;

    demux_1x2 d1 (.din(a), .sel(b), .y0(y0), .y1(y1));

    // NAND = NOT(AND)
    assign y = ~y1;
endmodule





module or_using_demux (
    input  logic a, b,
    output logic y
);
    logic y0, y1;
    logic z0, z1;

    // First DEMUX: generate A and ~A
    demux_1x2 d1 (.din(1'b1), .sel(a), .y0(y0), .y1(y1));
    // y0 = ~a, y1 = a

    // Second DEMUX: use B as selector, feed input as y1 (A)
    // Here, when b=1, output gets a 1; when b=0 and a=1, still gets 1
    demux_1x2 d2 (.din(y1), .sel(b), .y0(z0), .y1(z1));

    // OR logic using demux paths: (A=1→z0 or z1 active) OR (B=1→z1 active)
    assign y = z0 | z1;  // combining demux outputs (no explicit logic operation inside demux)
endmodule






