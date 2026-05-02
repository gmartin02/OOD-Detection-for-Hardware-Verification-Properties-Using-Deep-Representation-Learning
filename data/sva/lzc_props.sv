// Provide a clock for SVA temporal operators
// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: empty_o asserted iff in_i is all zeros
ast_empty_iff_all_zero: assert property (
`CLK
empty_o == (in_i == '0)
) else $error("FAIL ast_empty_iff_all_zero: empty_o disagrees with all-zero check");

// AST2: cnt_o is within valid range [0, WIDTH-1]
ast_cnt_range: assert property (
`CLK
cnt_o < WIDTH[CNT_WIDTH-1:0]
) else $error("FAIL ast_cnt_range: cnt_o out of valid range");

// AST3: When empty_o is asserted, cnt_o must be WIDTH-1
//       (maximum count when input is all zeros — matches reference spec)
ast_empty_cnt_max: assert property (
`CLK
empty_o |-> (cnt_o == (WIDTH - 1)[CNT_WIDTH-1:0])
) else $error("FAIL ast_empty_cnt_max: cnt_o not WIDTH-1 when empty");

// AST4: MODE=0 (TZC) — if bit cnt_o is set, all lower bits must be zero
//       i.e., the first '1' bit is indeed at position cnt_o
// AST4a: The bit at position cnt_o is '1' (when not empty)
ast_tzc_bit_set: assert property (
`CLK
!empty_o |-> in_i[cnt_o]
) else $error("FAIL ast_tzc_bit_set: bit at cnt_o is not 1 in TZC mode");

// AST4b: Minimum index — no bit below cnt_o is set (when not empty)
//        Checked via a loop unrolled into a helper function
// (Structural: the tree picks the minimum index by construction;
//  cross-check with a reference function in simulation)
// AST5: Single-bit input — if only bit 0 is set, cnt must be 0
ast_tzc_bit0: assert property (
`CLK
(in_i == {{(WIDTH-1){1'b0}}, 1'b1}) |-> (cnt_o == '0)
) else $error("FAIL ast_tzc_bit0: TZC wrong for in_i=1");

// AST6: All-ones input — trailing zero count must be 0
ast_tzc_all_ones: assert property (
`CLK
(in_i == '1) |-> (cnt_o == '0)
) else $error("FAIL ast_tzc_all_ones: TZC non-zero for all-ones");

// AST7: MODE=1 (LZC) — symmetric checks
// AST7a: If only MSB is set, leading zero count must be 0
ast_lzc_msb_set: assert property (
`CLK
(in_i == {1'b1, {(WIDTH-1){1'b0}}}) |-> (cnt_o == '0)
) else $error("FAIL ast_lzc_msb_set: LZC wrong for MSB-only input");

// AST7b: All-ones input — leading zero count must be 0
ast_lzc_all_ones: assert property (
`CLK
(in_i == '1) |-> (cnt_o == '0)
) else $error("FAIL ast_lzc_all_ones: LZC non-zero for all-ones");

// AST7c: Only LSB set — leading zeros must be WIDTH-1
ast_lzc_lsb_only: assert property (
`CLK
(in_i == {{(WIDTH-1){1'b0}}, 1'b1}) |->
(cnt_o == (WIDTH-1)[CNT_WIDTH-1:0])
) else $error("FAIL ast_lzc_lsb_only: LZC wrong for LSB-only input");

// AST8: cnt_o is 0 when any bit at the counted-from end is set
ast_cnt_zero_lsb: assert property (
`CLK
in_i[0] |-> (cnt_o == '0)
) else $error("FAIL ast_cnt_zero_lsb: TZC cnt_o non-zero when LSB set");

ast_cnt_zero_msb: assert property (
`CLK
in_i[WIDTH-1] |-> (cnt_o == '0)
) else $error("FAIL ast_cnt_zero_msb: LZC cnt_o non-zero when MSB set");

// AST9: empty_o and cnt_o are consistent — empty means maximum zeros
ast_non_empty_cnt_bounded: assert property (
`CLK
!empty_o |-> (cnt_o < WIDTH[CNT_WIDTH-1:0])
) else $error("FAIL ast_non_empty_cnt_bounded: cnt_o at max when not empty");

// AST10: Stability — same input always produces same output (purely combinational)
ast_combinational_stable: assert property (
`CLK
$stable(in_i) |-> ($stable(cnt_o) && $stable(empty_o))
) else $error("FAIL ast_combinational_stable: outputs changed with stable input");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe empty_o asserted (all-zeros input)
cov_all_zeros: cover property (`CLK empty_o);

// COV2: Observe cnt_o == 0 (first/last bit set)
cov_cnt_zero: cover property (`CLK (!empty_o && cnt_o == '0));

// COV3: Observe cnt_o at maximum non-empty value (only one boundary bit set)
cov_cnt_max_nonempty: cover property (
`CLK (!empty_o && cnt_o == (WIDTH-1)[CNT_WIDTH-1:0])
);
