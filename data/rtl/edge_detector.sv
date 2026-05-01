// =============================================================================
// Module: edge_detector
// Description: Multi-Channel Edge Detector
//   - WIDTH independent channels, each detecting rising/falling/any edges
//   - One pipeline stage: captures previous value, compares with current
//   - Three output vectors: rise (0→1), fall (1→0), toggle (any change)
//   - Synchronous active-high reset clears history to zero
// =============================================================================

module edge_detector #(
    parameter int WIDTH = 8
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [WIDTH-1:0]  sig_i,
    output logic [WIDTH-1:0]  rise_o,
    output logic [WIDTH-1:0]  fall_o,
    output logic [WIDTH-1:0]  toggle_o
);

    logic [WIDTH-1:0] sig_prev;

    always_ff @(posedge clk) begin
        if (reset)
            sig_prev <= '0;
        else
            sig_prev <= sig_i;
    end

    assign rise_o   = sig_i & ~sig_prev;
    assign fall_o   = ~sig_i & sig_prev;
    assign toggle_o = sig_i ^ sig_prev;

endmodule : edge_detector
