module moore_fsm (
    input  logic clk, rst_n, in,
    output logic out
);

    // State encoding
    typedef enum logic {S0, S1} state_t;
    state_t state, next;

    // State register
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)
            state <= S0;
        else
            state <= next;

    // Next-state logic
    always_comb begin
        case (state)
            S0: next = in ? S1 : S0;
            S1: next = in ? S1 : S0;
            default: next = S0;
        endcase
    end

    // Output logic depends ONLY on the current state (Moore)
    always_comb begin
        case (state)
            S0: out = 1'b0;
            S1: out = 1'b1;
            default: out = 1'b0;
        endcase
    end

endmodule
