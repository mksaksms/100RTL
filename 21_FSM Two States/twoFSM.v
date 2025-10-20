// FSM - Two States
module fsm_two_state (
    input  logic clk, rst_n, in,
    output logic out
);

    typedef enum logic {S0, S1} state_t;
    state_t state, next;

    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)
            state <= S0;
        else
            state <= next;

    always_comb begin
        case (state)
            S0: next = in ? S1 : S0;
            S1: next = in ? S1 : S0;
        endcase
    end

    assign out = (state == S1);

endmodule