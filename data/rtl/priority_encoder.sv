// =============================================================================
// Module: priority_encoder
// Description: Parameterized Priority Encoder (purely combinational)
//   - Encodes the position of the highest-priority (lowest-index) set bit
//   - WIDTH-bit input, $clog2(WIDTH)-bit encoded output
//   - valid_o deasserted when no bits are set
// =============================================================================

module priority_encoder #(
    parameter int WIDTH = 8,
    parameter int OUT_W = $clog2(WIDTH)
) (
    input  logic [WIDTH-1:0]  req_i,
    output logic [OUT_W-1:0]  enc_o,
    output logic              valid_o
);

    always_comb begin
        enc_o   = '0;
        valid_o = 1'b0;
        for (int i = 0; i < WIDTH; i++) begin
            if (req_i[i] && !valid_o) begin
                enc_o   = OUT_W'(i);
                valid_o = 1'b1;
            end
        end
    end

endmodule : priority_encoder
