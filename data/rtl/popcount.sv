// =============================================================================
// Module: popcount
// Description: Population Count / Bit Counter (purely combinational)
//   - Counts the number of set (1) bits in a WIDTH-bit input vector
//   - Uses an adder tree for efficient parallel reduction
//   - Output width is $clog2(WIDTH+1) to represent values 0 through WIDTH
// =============================================================================

module popcount #(
    parameter int WIDTH = 16,
    parameter int OUT_W = $clog2(WIDTH + 1)
) (
    input  logic [WIDTH-1:0]  data_i,
    output logic [OUT_W-1:0]  count_o,
    output logic              all_set,
    output logic              none_set
);

    always_comb begin
        count_o = '0;
        for (int i = 0; i < WIDTH; i++) begin
            count_o = count_o + {{(OUT_W-1){1'b0}}, data_i[i]};
        end
    end

    assign all_set  = (count_o == WIDTH[OUT_W-1:0]);
    assign none_set = (count_o == '0);

endmodule : popcount
