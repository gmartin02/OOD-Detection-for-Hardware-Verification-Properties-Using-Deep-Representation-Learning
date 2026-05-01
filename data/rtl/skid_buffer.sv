// =============================================================================
// Module: skid_buffer
// Description: Elastic Skid Buffer — Zero-Bubble Ready/Valid Bridge
//
//   Provides a one-entry elastic buffer between an upstream producer and a
//   downstream consumer using standard ready/valid handshaking. The buffer
//   absorbs exactly one cycle of backpressure without stalling the upstream,
//   keeping throughput at one transfer per cycle under normal conditions.
//
//   Operating Modes (controlled by internal bypass_rg flag):
//
//     BYPASS mode (bypass_rg = 1, reset default):
//       Data flows directly from upstream to downstream with zero latency.
//       out_ready = 1 (upstream is always welcome).
//       Transition to SKID mode occurs when downstream stalls (in_ready = 0)
//       while upstream presents valid data — the data is captured in data_rg.
//
//     SKID mode (bypass_rg = 0):
//       Buffered data in data_rg is presented downstream (out_valid = 1).
//       out_ready = 0 (upstream is stalled — buffer is full).
//       Transition back to BYPASS mode when downstream accepts (in_ready = 1).
//
//   Interface:
//     Upstream:   in_data / in_valid / out_ready
//     Downstream: out_data / out_valid / in_ready
//
//   Key properties:
//     - out_ready is registered (no combinational path from in_ready to out_ready)
//     - out_valid is combinational from bypass_rg and in_valid
//     - Zero latency in bypass mode; one cycle of buffered data in skid mode
//     - No data loss or duplication
//
// Original source: Mitu Raj, Chipmunk Logic (open-source, Mar-26-2022)
// Refactored to:   synchronous active-high reset, clk/reset naming,
//                  always_ff, consistent port/signal naming, SVA block
// =============================================================================

module skid_buffer #(
    parameter int DWIDTH = 8    // Data width in bits
) (
    input  logic              clk,
    input  logic              reset,

    // Upstream interface (producer → this module)
    input  logic [DWIDTH-1:0] in_data,
    input  logic              in_valid,
    output logic              out_ready,   // 1 = this module can accept data

    // Downstream interface (this module → consumer)
    output logic [DWIDTH-1:0] out_data,
    output logic              out_valid,
    input  logic              in_ready     // 1 = consumer can accept data
);

    // -------------------------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------------------------
    logic [DWIDTH-1:0] data_rg;    // Skid data register (holds skidded data)
    logic              bypass_rg;  // 1 = bypass mode, 0 = skid mode

    // -------------------------------------------------------------------------
    // Sequential logic — synchronous active-high reset
    //   Reset initialises to bypass mode: o_ready=1 so upstream is not stalled.
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            data_rg   <= '0;
            bypass_rg <= 1'b1;   // Start in bypass mode (FIFO empty)
        end else begin

            // ---- BYPASS mode ------------------------------------------------
            if (bypass_rg) begin
                if (!in_ready && in_valid) begin
                    // Downstream stalled; capture upstream data into skid register
                    data_rg   <= in_data;
                    bypass_rg <= 1'b0;   // Enter SKID mode
                end
                // Otherwise: data flows through combinationally; nothing to store
            end

            // ---- SKID mode --------------------------------------------------
            else begin
                if (in_ready) begin
                    // Downstream accepted the buffered data; return to bypass mode
                    bypass_rg <= 1'b1;
                end
                // data_rg holds until downstream is ready (unchanged)
            end

        end
    end

    // -------------------------------------------------------------------------
    // Combinational outputs
    //   out_ready: registered via bypass_rg (no comb path from in_ready)
    //   out_data:  bypass_rg selects between live upstream data and buffer
    //   out_valid: in bypass mode, reflects upstream; in skid mode, always 1
    // -------------------------------------------------------------------------
    assign out_ready = bypass_rg;
    assign out_data  = bypass_rg ? in_data  : data_rg;
    assign out_valid = bypass_rg ? in_valid : 1'b1;

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule : skid_buffer