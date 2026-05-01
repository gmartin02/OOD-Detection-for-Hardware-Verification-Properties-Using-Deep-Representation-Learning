// =============================================================================
// Module: fifo
// Description: Parameterized Synchronous FIFO
//   - WIDTH-bit data, DEPTH entries (DEPTH must be a power of 2)
//   - Standard write/read enable interface with full/empty status flags
//   - Synchronous active-high reset clears pointers and status
//   - Combinational read: rdata reflects mem[rptr] immediately
//   - Full/empty disambiguation via last_op flag (no extra counter needed):
//       wptr == rptr && last_op == WRITE  →  full
//       wptr == rptr && last_op == READ   →  empty
//   - Writes ignored when full; reads ignored when empty (safe by design)
//   - Memory contents are not reset (only pointers and flags are)
//
// Original functionality by: upstream source (async-reset, different port names)
// Refactored to: synchronous active-high reset, clk/reset naming, always_ff,
//                consistent style, independent SVA block
// =============================================================================

module fifo #(
    parameter int WIDTH = 32,   // Data width in bits
    parameter int DEPTH = 16    // FIFO depth (must be a power of 2)
) (
    input  logic             clk,
    input  logic             reset,
    // Write interface
    input  logic [WIDTH-1:0] wr_data,
    input  logic             wr_en,
    output logic             full,
    // Read interface
    output logic [WIDTH-1:0] rd_data,
    input  logic             rd_en,
    output logic             empty
);

    // -------------------------------------------------------------------------
    // Local parameters
    // -------------------------------------------------------------------------
    localparam int ADDR_W = $clog2(DEPTH);  // Pointer width

    // Last-operation encoding for full/empty disambiguation
    localparam logic LAST_READ  = 1'b1;
    localparam logic LAST_WRITE = 1'b0;

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [ADDR_W-1:0] wptr;        // Write pointer
    logic [ADDR_W-1:0] rptr;        // Read pointer
    logic              last_op;     // Tracks whether last operation was read or write

    logic [WIDTH-1:0]  mem [0:DEPTH-1];  // Memory array

    // Internal full/empty (driven combinationally, exported directly)
    logic full_int, empty_int;

    // -------------------------------------------------------------------------
    // Full / empty flag logic
    //   Pointers coincide on both full and empty; disambiguate with last_op.
    // -------------------------------------------------------------------------
    assign full_int  = (wptr == rptr) && (last_op == LAST_WRITE);
    assign empty_int = (wptr == rptr) && (last_op == LAST_READ);

    assign full  = full_int;
    assign empty = empty_int;

    // -------------------------------------------------------------------------
    // Write logic — synchronous, ignored when full
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            wptr <= '0;
        end else if (wr_en && !full_int) begin
            mem[wptr] <= wr_data;
            wptr      <= wptr + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    // Read pointer — synchronous, ignored when empty
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            rptr <= '0;
        end else if (rd_en && !empty_int) begin
            rptr <= rptr + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    // Last-operation tracker — initialised to LAST_READ (FIFO starts empty)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            last_op <= LAST_READ;
        end else begin
            if (rd_en && !empty_int) begin
                last_op <= LAST_READ;
            end else if (wr_en && !full_int) begin
                last_op <= LAST_WRITE;
            end
            // Else: retain current value
        end
    end

    // -------------------------------------------------------------------------
    // Combinational read — rd_data always reflects current rptr slot
    // -------------------------------------------------------------------------
    assign rd_data = mem[rptr];

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule : fifo