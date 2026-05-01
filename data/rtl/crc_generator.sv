// =============================================================================
// Module: crc_generator
// Description: Parameterized Serial CRC Generator
//   - Computes CRC one bit at a time (serial input)
//   - Configurable CRC width (default CRC-8)
//   - Uses LFSR-style shift-and-XOR with configurable polynomial
//   - init: load initial CRC value; data_valid: shift in one bit per cycle
//   - crc_o holds the running CRC after each bit
// =============================================================================

module crc_generator #(
    parameter int CRC_W = 8,
    parameter logic [CRC_W-1:0] POLY = 8'h07  // CRC-8 default polynomial
) (
    input  logic              clk,
    input  logic              reset,
    input  logic              init,
    input  logic [CRC_W-1:0]  init_val,
    input  logic              data_valid,
    input  logic              data_bit,
    output logic [CRC_W-1:0]  crc_o
);

    logic feedback;

    assign feedback = crc_o[CRC_W-1] ^ data_bit;

    always_ff @(posedge clk) begin
        if (reset) begin
            crc_o <= '0;
        end else if (init) begin
            crc_o <= init_val;
        end else if (data_valid) begin
            crc_o <= {crc_o[CRC_W-2:0], 1'b0} ^ (feedback ? POLY : '0);
        end
    end

endmodule : crc_generator
