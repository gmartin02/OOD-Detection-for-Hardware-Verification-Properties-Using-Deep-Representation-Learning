// AST1: Zero input gives zero count
ast_zero_input: assert property (
    data_i == '0 |-> count_o == '0
);

// AST2: All-ones input gives WIDTH count
ast_all_ones: assert property (
    data_i == {WIDTH{1'b1}} |-> count_o == WIDTH[OUT_W-1:0]
);

// AST3: Count is bounded by WIDTH
ast_count_bounded: assert property (
    count_o <= WIDTH[OUT_W-1:0]
);

// AST4: Single bit set gives count of 1
ast_single_bit: assert property (
    $onehot(data_i) |-> count_o == 1
);

// AST5: all_set flag matches count
ast_all_set_correct: assert property (
    all_set == (count_o == WIDTH[OUT_W-1:0])
);

// AST6: none_set flag matches count
ast_none_set_correct: assert property (
    none_set == (count_o == '0)
);

// AST7: all_set and none_set are mutually exclusive (for WIDTH > 0)
ast_flags_mutex: assert property (
    !(all_set && none_set)
);

// AST8: none_set matches zero input
ast_none_set_zero: assert property (
    none_set == (data_i == '0)
);

// AST9: all_set matches all-ones input
ast_all_set_all_ones: assert property (
    all_set == (data_i == {WIDTH{1'b1}})
);

// AST10: Flipping one bit from zero gives count 1
ast_one_hot_count: assert property (
    data_i == {{(WIDTH-1){1'b0}}, 1'b1} |-> count_o == 1
);

// COV1: Observe zero count
cov_zero: cover property (
    none_set
);

// COV2: Observe all bits set
cov_all: cover property (
    all_set
);

// COV3: Observe count equal to half of WIDTH
cov_half: cover property (
    count_o == (WIDTH / 2)
);
