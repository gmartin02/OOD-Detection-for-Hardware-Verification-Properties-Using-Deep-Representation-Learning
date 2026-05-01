// =============================================================================
// Module: lzc
// Description: Leading / Trailing Zero Counter (purely combinational)
//
//   Counts the number of leading zeros (from MSB) or trailing zeros (from LSB)
//   in the WIDTH-bit input vector in_i, using a binary tournament tree.
//
//   MODE parameter:
//     MODE = 0  →  Trailing Zero Counter (TZC): cnt_o = number of zeros from LSB
//     MODE = 1  →  Leading  Zero Counter (LZC): cnt_o = number of zeros from MSB
//
//   Special case — all-zeros input:
//     empty_o is asserted; cnt_o holds (WIDTH - 1), i.e. the maximum count.
//     Example (WIDTH=8, MODE=0): in_i=8'b0 → empty_o=1, cnt_o=7
//
//   Output width: CNT_WIDTH = $clog2(WIDTH) bits, sufficient to represent
//   values 0 through WIDTH-1.
//
//   No clock or reset — this module is purely combinational.
//
// Original source: ETH Zurich / University of Bologna (Solderpad SHL-0.51)
// Refactored to:   self-contained (no external packages or includes),
//                  consistent style, independent SVA block
// =============================================================================

module lzc #(
    parameter int unsigned WIDTH     = 8,               // Input vector width (>= 1)
    parameter bit          MODE      = 1'b0,            // 0 = trailing, 1 = leading
    // Derived — do not override
    parameter int unsigned CNT_WIDTH = $clog2(WIDTH)    // Output counter width
) (
    input  logic [WIDTH-1:0]     in_i,     // Input vector
    output logic [CNT_WIDTH-1:0] cnt_o,    // Zero count
    output logic                 empty_o   // Asserted when in_i is all zeros
);

    // -------------------------------------------------------------------------
    // Degenerate case: WIDTH == 1
    // -------------------------------------------------------------------------
    if (WIDTH == 1) begin : gen_degenerate

        assign cnt_o[0] = !in_i[0];   // 0 if bit is set, 1 if zero (== "1 trailing zero")
        assign empty_o  = !in_i[0];

    end else begin : gen_lzc

        // ---------------------------------------------------------------------
        // Binary tournament tree implementation
        //   NumLevels levels of 2-input mux/OR nodes reduce WIDTH inputs
        //   down to a single root. Each node selects the lower index (LSB-first
        //   for TZC; MSB-first for LZC after the flip).
        // ---------------------------------------------------------------------
        localparam int unsigned NumLevels = $clog2(WIDTH);

        // Pre-computed per-input index table: index_lut[j] == j
        logic [WIDTH-1:0][NumLevels-1:0] index_lut;

        // Tournament tree nodes (2^NumLevels leaves, binary-tree flattened)
        //   sel_nodes[n]   = 1 if any '1' bit is reachable through this node
        //   index_nodes[n] = lowest index of a '1' bit reachable through this node
        logic [2**NumLevels-1:0]                    sel_nodes;
        logic [2**NumLevels-1:0][NumLevels-1:0]    index_nodes;

        // Optionally bit-reversed input (MODE 1 sees a flipped vector so that
        // leading zeros map to trailing zeros handled by the same tree)
        logic [WIDTH-1:0] in_tmp;

        // ---------------------------------------------------------------------
        // Input conditioning: flip for leading-zero mode
        // ---------------------------------------------------------------------
        if (MODE) begin : gen_flip
            always_comb begin : flip_vector
                for (int unsigned i = 0; i < WIDTH; i++) begin
                    in_tmp[i] = in_i[WIDTH-1-i];
                end
            end
        end else begin : gen_no_flip
            assign in_tmp = in_i;
        end

        // ---------------------------------------------------------------------
        // Index lookup table: constant, index_lut[j] = j
        // ---------------------------------------------------------------------
        for (genvar j = 0; unsigned'(j) < WIDTH; j++) begin : gen_index_lut
            assign index_lut[j] = (NumLevels)'(unsigned'(j));
        end

        // ---------------------------------------------------------------------
        // Tournament tree levels
        //   Level NumLevels-1 (leaf level): pairs of in_tmp bits
        //   Levels NumLevels-2 down to 0:  combine sel/index from children
        // ---------------------------------------------------------------------
        for (genvar level = 0; unsigned'(level) < NumLevels; level++) begin : gen_levels

            if (unsigned'(level) == NumLevels - 1) begin : gen_leaf_level
                // Leaf level: pair up in_tmp bits directly
                for (genvar k = 0; k < 2**level; k++) begin : gen_leaf_nodes

                    if (unsigned'(k) * 2 < WIDTH - 1) begin : gen_pair
                        // Both k*2 and k*2+1 are valid indices
                        assign sel_nodes[2**level - 1 + k] =
                            in_tmp[k*2] | in_tmp[k*2+1];
                        assign index_nodes[2**level - 1 + k] =
                            in_tmp[k*2] ? index_lut[k*2] : index_lut[k*2+1];
                    end

                    if (unsigned'(k) * 2 == WIDTH - 1) begin : gen_single
                        // Only k*2 is a valid index (WIDTH is odd)
                        assign sel_nodes[2**level - 1 + k]   = in_tmp[k*2];
                        assign index_nodes[2**level - 1 + k] = index_lut[k*2];
                    end

                    if (unsigned'(k) * 2 > WIDTH - 1) begin : gen_pad
                        // Padding node beyond input width — always inactive
                        assign sel_nodes[2**level - 1 + k]   = 1'b0;
                        assign index_nodes[2**level - 1 + k] = '0;
                    end

                end
            end else begin : gen_inner_level
                // Inner level: combine two children
                for (genvar l = 0; l < 2**level; l++) begin : gen_inner_nodes
                    assign sel_nodes[2**level - 1 + l] =
                        sel_nodes[2**(level+1) - 1 + l*2] |
                        sel_nodes[2**(level+1) - 1 + l*2 + 1];
                    assign index_nodes[2**level - 1 + l] =
                        sel_nodes[2**(level+1) - 1 + l*2]
                        ? index_nodes[2**(level+1) - 1 + l*2]
                        : index_nodes[2**(level+1) - 1 + l*2 + 1];
                end
            end

        end // gen_levels

        // ---------------------------------------------------------------------
        // Root outputs
        // ---------------------------------------------------------------------
        assign cnt_o   = (NumLevels > 0) ? index_nodes[0] : '0;
        assign empty_o = (NumLevels > 0) ? ~sel_nodes[0]  : ~(|in_i);

    end : gen_lzc

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // All properties are purely combinational (no clocking event needed;
    // use $global_clock or an assumed clock — shown here with an assumed clk).
    // =========================================================================

endmodule : lzc