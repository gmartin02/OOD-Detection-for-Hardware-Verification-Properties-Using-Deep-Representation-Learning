// =============================================================================
// Module: dual_port_ram
// Description: Parameterized Simple Dual-Port RAM
//   - One write port (port A) and one read port (port B)
//   - Synchronous write, synchronous read (1-cycle read latency)
//   - No read-during-write hazard handling (undefined if same address)
//   - DEPTH entries of WIDTH bits each
// =============================================================================

module dual_port_ram #(
    parameter int WIDTH  = 32,
    parameter int DEPTH  = 16,
    parameter int ADDR_W = $clog2(DEPTH)
) (
    input  logic               clk,
    // Write port (A)
    input  logic               wr_en,
    input  logic [ADDR_W-1:0]  wr_addr,
    input  logic [WIDTH-1:0]   wr_data,
    // Read port (B)
    input  logic               rd_en,
    input  logic [ADDR_W-1:0]  rd_addr,
    output logic [WIDTH-1:0]   rd_data
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Write port
    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // Read port
    always_ff @(posedge clk) begin
        if (rd_en) begin
            rd_data <= mem[rd_addr];
        end
    end

endmodule : dual_port_ram
