module timer #(
    parameter int CYCLES = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic go,
    output logic done
);

    typedef enum logic {
        INACTIVE = 1'b0,
        ACTIVE
    } state_t;
    state_t state_r, next_state;

    localparam int NUM_BITS = $clog2(CYCLES);
    logic [NUM_BITS-1:0] count_r;
    logic [NUM_BITS-1:0] next_count = '0;

    always_comb begin
        next_state = state_r;

        case (state_r)
            INACTIVE: begin
                done = 1'b1;
                next_count = count_r;
                if (go) next_state = ACTIVE;
            end

            ACTIVE: begin
                done = 1'b0;
                next_count = count_r + 1'b1;
                if (count_r == NUM_BITS'(CYCLES - 1)) begin
                    done = 1'b1;
                    next_state = INACTIVE;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        count_r <= next_count;
        state_r <= next_state;
        if (rst) state_r <= INACTIVE;
    end
endmodule