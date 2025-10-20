module seq_1011_detector (
    input  wire clk,
    input  wire reset,
    input  wire in_bit,
    output reg  detected
);

    // State encoding
    typedef enum logic [2:0] {
        S0 = 3'b000,  // No bits matched yet
        S1 = 3'b001,  // matched "1"
        S2 = 3'b010,  // matched "10"
        S3 = 3'b011,  // matched "101"
        S4 = 3'b100   // matched "1011" (detection)
    } state_t;

    state_t current_state, next_state;

    // Sequential state transition
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = current_state;  // default
        detected   = 1'b0;

        case (current_state)
            S0: begin
                if (in_bit) next_state = S1;  // got '1'
            end

            S1: begin
                if (in_bit)
                    next_state = S1;  // stay in S1 for consecutive 1s
                else
                    next_state = S2;  // got '10'
            end

            S2: begin
                if (in_bit)
                    next_state = S3;  // got '101'
                else
                    next_state = S0;  // restart
            end

            S3: begin
                if (in_bit) begin
                    next_state = S4;  // got '1011'
                    detected   = 1'b1; // output high immediately
                end else
                    next_state = S2;  // got '1010' → still "10"
            end

            S4: begin
                // Overlapping detection: last bit '1' can be start of new pattern
                if (in_bit)
                    next_state = S1;
                else
                    next_state = S2;
                detected = 1'b0;
            end
        endcase
    end
endmodule

