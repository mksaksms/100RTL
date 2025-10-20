module datapath (
    input  logic [7:0] reg_data,
    input  logic [7:0] immediate,
    input  logic       sel,
    output logic [7:0] alu_input
);

    always_comb begin
        alu_input = (sel == 0) ? reg_data : immediate;
    end

endmodule
