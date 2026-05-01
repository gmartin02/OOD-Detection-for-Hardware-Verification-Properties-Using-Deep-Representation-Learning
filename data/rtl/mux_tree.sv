// =============================================================================
// Module: mux_tree
// Description: Parameterized N-to-1 Multiplexer (purely combinational)
//   - N_INPUTS input channels of WIDTH bits each
//   - $clog2(N_INPUTS)-bit select signal
//   - Outputs the selected input channel
//   - Out-of-range select produces zero output
// =============================================================================

module mux_tree #(
    parameter int WIDTH    = 32,
    parameter int N_INPUTS = 8,
    parameter int SEL_W    = $clog2(N_INPUTS)
) (
    input  logic [WIDTH-1:0]   data_i [0:N_INPUTS-1],
    input  logic [SEL_W-1:0]   sel_i,
    output logic [WIDTH-1:0]   data_o,
    output logic               valid_o
);

    always_comb begin
        if (sel_i < N_INPUTS[SEL_W-1:0]) begin
            data_o  = data_i[sel_i];
            valid_o = 1'b1;
        end else begin
            data_o  = '0;
            valid_o = 1'b0;
        end
    end

endmodule : mux_tree
