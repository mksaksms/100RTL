// Booth Multiplier (4-bit)
module booth_multiplier (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
    logic [4:0] m, q, q_1;
    logic [7:0] acc;
    integer i;

    always_comb begin
        m   = {a[3], a};
        q   = {b, 1'b0};
        acc = 8'd0;

        for (i = 0; i < 4; i++) begin
            case ({q[0], q_1[0]})
                2'b01: acc = acc + {m, 3'b000};
                2'b10: acc = acc - {m, 3'b000};
            endcase
            acc = acc >>> 1;
            q = q >> 1;
        end
        product = acc;
    end
endmodule