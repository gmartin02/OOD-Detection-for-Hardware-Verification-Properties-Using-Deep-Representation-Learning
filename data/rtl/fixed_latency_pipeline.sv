// =============================================================================
// Module: fixed_latency_pipeline
// Description: Parameterized Fixed-Latency Pipeline
//   - N pipeline stages, each adding exactly 1 cycle of latency
//   - Total latency: N cycles from in_valid to out_valid
//   - Data (in_data) and valid (in_valid) propagate together through stages
//   - Synchronous active-high reset clears all valid bits and data registers
//   - No backpressure: data is always accepted (no ready/stall)
//   - out_valid is asserted exactly N cycles after in_valid
// =============================================================================

module fixed_latency_pipeline #(
    parameter int N  = 4,   // Pipeline depth (number of stages)
    parameter int DW = 8    // Data width in bits
) (
    input  logic         clk,
    input  logic         reset,
    input  logic         in_valid,   // Data valid at pipeline input
    input  logic [DW-1:0] in_data,  // Input data
    output logic         out_valid,  // Data valid at pipeline output (N cycles later)
    output logic [DW-1:0] out_data  // Output data (N cycles later)
);

    // Pipeline stage registers
    // stage_valid[0] is driven by in_valid; stage_valid[N-1] drives out_valid
    logic         stage_valid [0:N-1];
    logic [DW-1:0] stage_data  [0:N-1];

    // --------------------------------------------------------------------
    // Stage 0: Capture inputs
    // --------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            stage_valid[0] <= 1'b0;
            stage_data[0]  <= '0;
        end else begin
            stage_valid[0] <= in_valid;
            stage_data[0]  <= in_data;
        end
    end

    // --------------------------------------------------------------------
    // Stages 1 through N-1: Shift register chain
    // --------------------------------------------------------------------
    generate
        for (genvar i = 1; i < N; i++) begin : gen_stages
            always_ff @(posedge clk) begin
                if (reset) begin
                    stage_valid[i] <= 1'b0;
                    stage_data[i]  <= '0;
                end else begin
                    stage_valid[i] <= stage_valid[i-1];
                    stage_data[i]  <= stage_data[i-1];
                end
            end
        end
    endgenerate

    // --------------------------------------------------------------------
    // Output: driven from last stage
    // --------------------------------------------------------------------
    assign out_valid = stage_valid[N-1];
    assign out_data  = stage_data[N-1];

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule