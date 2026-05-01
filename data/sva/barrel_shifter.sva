// AST1: Left shift by zero is identity
ast_sll_zero: assert property (
    (mode_i == 2'b00 && shamt_i == '0) |-> result_o == data_i
);

// AST2: Right logical shift by zero is identity
ast_srl_zero: assert property (
    (mode_i == 2'b01 && shamt_i == '0) |-> result_o == data_i
);

// AST3: Right arithmetic shift by zero is identity
ast_sra_zero: assert property (
    (mode_i == 2'b10 && shamt_i == '0) |-> result_o == data_i
);

// AST4: Left shift of zero is always zero
ast_sll_zero_data: assert property (
    (mode_i == 2'b00 && data_i == '0) |-> result_o == '0
);

// AST5: Right logical shift of zero is always zero
ast_srl_zero_data: assert property (
    (mode_i == 2'b01 && data_i == '0) |-> result_o == '0
);

// AST6: Left shift by 1 doubles the value (if no overflow)
ast_sll_one: assert property (
    (mode_i == 2'b00 && shamt_i == 1) |-> result_o == (data_i << 1)
);

// AST7: Right logical shift by 1 halves the value
ast_srl_one: assert property (
    (mode_i == 2'b01 && shamt_i == 1) |-> result_o == (data_i >> 1)
);

// AST8: Right logical shift MSB is always zero
ast_srl_msb_zero: assert property (
    (mode_i == 2'b01 && shamt_i > 0) |-> result_o[WIDTH-1] == 1'b0
);

// AST9: Right arithmetic shift preserves sign bit
ast_sra_sign_preserve: assert property (
    (mode_i == 2'b10 && shamt_i > 0) |-> result_o[WIDTH-1] == data_i[WIDTH-1]
);

// AST10: Default mode returns data unchanged
ast_default_passthrough: assert property (
    mode_i == 2'b11 |-> result_o == data_i
);

// COV1: Observe maximum left shift
cov_max_sll: cover property (
    mode_i == 2'b00 && shamt_i == {SHIFT_W{1'b1}}
);

// COV2: Observe arithmetic right shift of negative number
cov_sra_negative: cover property (
    mode_i == 2'b10 && data_i[WIDTH-1] == 1'b1 && shamt_i > 0
);
