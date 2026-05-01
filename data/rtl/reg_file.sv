// =============================================================================
// Module: reg_file
// Description: Parameterized Register File
//   - DW-bit wide data, DEPTH registers
//   - Synchronous write (write takes effect at next rising clock edge)
//   - Combinational (asynchronous) read
//   - Synchronous active-high reset initializes all registers to 0
//   - Read-during-write returns old data (write-first if desired, see note)
// =============================================================================

module reg_file #(
    parameter int DW    = 32,                   // Data width in bits
    parameter int DEPTH = 16                    // Number of registers
) (
    input  logic                        clk,
    input  logic                        reset,
    // Write port
    input  logic                        wr_en,
    input  logic [$clog2(DEPTH)-1:0]   wr_addr,
    input  logic [DW-1:0]              wr_data,
    // Read port
    input  logic [$clog2(DEPTH)-1:0]   rd_addr,
    output logic [DW-1:0]              rd_data
);

    // Register array
    logic [DW-1:0] mem [0:DEPTH-1];

    // --------------------------------------------------------------------
    // Synchronous write with synchronous reset (all registers → 0)
    // --------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < DEPTH; i++) begin
                mem[i] <= '0;
            end
        end else if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // --------------------------------------------------------------------
    // Combinational (asynchronous) read
    //   Returns current register value; if a write is in progress to
    //   rd_addr this cycle, returns OLD value (write takes effect next cycle)
    // --------------------------------------------------------------------
    assign rd_data = mem[rd_addr];

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule