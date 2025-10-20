module one_stage_fsm (
    input  logic clk,
    input  logic rst_n,
    output logic [1:0] light
);

    // State encoding
    typedef enum logic [1:0] {
        RED    = 2'b00,
        GREEN  = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t state;

    // Single always block FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= RED;  // reset to RED
        else begin
            case (state)
                RED:    state <= GREEN;
                GREEN:  state <= YELLOW;
                YELLOW: state <= RED;
                default: state <= RED;
            endcase
        end
    end

    // Output based directly on state
    assign light = state;

endmodule
