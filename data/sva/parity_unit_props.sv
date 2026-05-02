// AST1: Zero input has even parity of 0
ast_zero_even_parity: assert property (
    data_i == '0 |-> raw_parity == 1'b0
);

// AST2: All-ones input parity depends on width
ast_all_ones_parity: assert property (
    data_i == {WIDTH{1'b1}} |-> raw_parity == (WIDTH % 2)
);

// AST3: Flipping one bit flips parity
ast_single_flip: assert property (
    data_i == {{(WIDTH-1){1'b0}}, 1'b1} |-> raw_parity == 1'b1
);

// AST4: No error when parity_in matches generated parity
ast_no_error_correct: assert property (
    parity_in == parity_gen |-> error_o == 1'b0
);

// AST5: Error when parity_in mismatches generated parity
ast_error_mismatch: assert property (
    parity_in != parity_gen |-> error_o == 1'b1
);

// AST6: Parity generation is deterministic (same input = same output)
ast_deterministic: assert property (
    data_i == data_i |-> parity_gen == parity_gen
);

// AST7: Even parity — parity_gen equals XOR of all data bits
ast_even_parity_def: assert property (
    parity_gen == (MODE ? ~raw_parity : raw_parity)
);

// AST8: Error flag is combinational — changes immediately with inputs
ast_error_combinational: assert property (
    error_o == (parity_in != parity_gen)
);

// AST9: Two-bit data — both zeros gives parity 0 for even mode
ast_two_zeros: assert property (
    (WIDTH >= 2 && data_i[1:0] == 2'b00 && data_i[WIDTH-1:2] == '0) |-> raw_parity == 1'b0
);

// COV1: Observe error detected
cov_error: cover property (
    error_o
);

// COV2: Observe no error
cov_no_error: cover property (
    !error_o
);

// COV3: Observe odd number of set bits in data
cov_odd_popcount: cover property (
    raw_parity == 1'b1
);
