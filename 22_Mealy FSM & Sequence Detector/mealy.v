// Mealy FSM

/*
That’s fundamental to all finite state machines, both Mealy and Moore.

In any FSM: next state=f(current state,inputs) (Mealy and Moore both) 

and

output=f(current state,inputs)	(Mealy)
output= f(current state)	 (Moore)
	​

(Moore)
	​
*/ 





module mealy_fsm (
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
            S0: begin
				// In any FSM: next state=f(current state,inputs) (Mealy and Moore both) 
                next = in ? S1 : S0; 
				
				// For mealy output depends on the input 
                out = in ? 1'b1 : 1'b0;
            end
            S1: begin
				// 
				// In any FSM: next state=f(current state,inputs) (Mealy and Moore both) 
                next = in ? S1 : S0;
				// For mealy output depends on the input 
                out = in ? 1'b0 : 1'b1;
            end
        endcase
    end

endmodule