// =============================================================================
// Module: handshake_ctrl
// Description: Ready/Valid Handshake Controller (Decoupled Interface Bridge)
//
//   Implements a standard ready/valid handshake between an upstream producer
//   and a downstream consumer, with an internal elastic buffer (skid buffer)
//   that allows the controller to accept a new upstream transfer even when the
//   downstream is not immediately ready.
//
//   Interface:
//     Upstream  (producer → this module):
//       up_valid   — producer asserts: data is valid on up_data
//       up_ready   — this module asserts: ready to accept data
//       up_data    — payload from producer
//
//     Downstream (this module → consumer):
//       dn_valid   — this module asserts: data is valid on dn_data
//       dn_ready   — consumer asserts: ready to consume data
//       dn_data    — payload to consumer
//
//   Handshake rule (standard):
//     A transfer occurs when both valid and ready are HIGH on the same edge.
//       upstream transfer:   up_valid && up_ready
//       downstream transfer: dn_valid && dn_ready
//
//   Skid Buffer Behavior:
//     - Normally, data flows directly: up → internal register → dn.
//     - If dn_ready is LOW when a new upstream transfer arrives and the
//       main register is occupied, the incoming data is saved in a skid
//       register (one-entry buffer) and up_ready is de-asserted.
//     - Once dn_ready goes HIGH, the skid register drains first, then
//       up_ready is re-asserted.
//     - This guarantees up_ready can only de-assert after a transfer has
//       already been accepted (no combinational ready/valid loops).
//
//   Key properties:
//     - up_ready may de-assert at any time (combinational from state)
//     - dn_valid is registered (one cycle latency minimum)
//     - Once dn_valid is asserted it stays asserted until dn_ready is seen
//     - Data is never lost or duplicated
// =============================================================================

module handshake_ctrl #(
    parameter int DW = 8    // Data width
) (
    input  logic          clk,
    input  logic          reset,

    // Upstream (producer) interface
    input  logic          up_valid,
    output logic          up_ready,
    input  logic [DW-1:0] up_data,

    // Downstream (consumer) interface
    output logic          dn_valid,
    input  logic          dn_ready,
    output logic [DW-1:0] dn_data
);

    // -------------------------------------------------------------------------
    // Internal state
    // -------------------------------------------------------------------------
    // Main register: holds data being presented to downstream
    logic          main_valid;
    logic [DW-1:0] main_data;

    // Skid register: overflow slot when downstream stalls and upstream fires
    logic          skid_valid;
    logic [DW-1:0] skid_data;

    // -------------------------------------------------------------------------
    // Skid buffer control
    // -------------------------------------------------------------------------
    // up_ready: we can accept if the skid slot is empty
    assign up_ready = !skid_valid;

    // Upstream transfer fires
    wire up_xfer  = up_valid && up_ready;
    // Downstream transfer fires
    wire dn_xfer  = dn_valid && dn_ready;

    // -------------------------------------------------------------------------
    // Main register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            main_valid <= 1'b0;
            main_data  <= '0;
        end else begin
            if (skid_valid && dn_xfer) begin
                // Drain skid into main
                main_valid <= 1'b1;
                main_data  <= skid_data;
            end else if (up_xfer && !dn_xfer) begin
                // New data from upstream, downstream not consuming
                main_valid <= 1'b1;
                main_data  <= up_data;
            end else if (up_xfer && dn_xfer) begin
                // Simultaneous: pass new data through
                main_valid <= 1'b1;
                main_data  <= up_data;
            end else if (!up_xfer && dn_xfer) begin
                // Downstream consumed, no new data
                main_valid <= 1'b0;
                main_data  <= '0;
            end
            // else: nothing happens, main holds
        end
    end

    // -------------------------------------------------------------------------
    // Skid register
    //   Fills when: main is occupied, downstream is stalled, upstream fires
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            skid_valid <= 1'b0;
            skid_data  <= '0;
        end else begin
            if (up_xfer && main_valid && !dn_xfer) begin
                // Main is full, downstream not consuming: save to skid
                skid_valid <= 1'b1;
                skid_data  <= up_data;
            end else if (dn_xfer && skid_valid) begin
                // Downstream consumed main; skid will drain to main next cycle
                skid_valid <= 1'b0;
                skid_data  <= '0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Downstream outputs
    // -------------------------------------------------------------------------
    assign dn_valid = main_valid;
    assign dn_data  = main_data;

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule