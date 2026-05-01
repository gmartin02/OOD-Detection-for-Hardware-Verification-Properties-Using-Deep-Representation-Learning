// AST1: Output matches the selected input when select is in range
ast_output_matches_input: assert property (
    sel_i < N_INPUTS[SEL_W-1:0] |-> data_o == data_i[sel_i]
);

// AST2: Valid is asserted when select is in range
ast_valid_in_range: assert property (
    sel_i < N_INPUTS[SEL_W-1:0] |-> valid_o == 1'b1
);

// AST3: Valid is deasserted when select is out of range
ast_invalid_out_of_range: assert property (
    sel_i >= N_INPUTS[SEL_W-1:0] |-> valid_o == 1'b0
);

// AST4: Output is zero when select is out of range
ast_zero_out_of_range: assert property (
    sel_i >= N_INPUTS[SEL_W-1:0] |-> data_o == '0
);

// AST5: Select 0 picks the first input
ast_sel_zero: assert property (
    sel_i == '0 |-> data_o == data_i[0]
);

// AST6: Select N_INPUTS-1 picks the last valid input
ast_sel_last: assert property (
    sel_i == (N_INPUTS - 1) |-> data_o == data_i[N_INPUTS-1]
);

// AST7: If all inputs are zero, output is zero regardless of select
ast_all_zero_input: assert property (
    data_i[0] == '0 && data_i[1] == '0 |-> (sel_i <= 1 |-> data_o == '0)
);

// AST8: Changing select changes output (when inputs differ)
ast_select_matters: assert property (
    (data_i[0] != data_i[1] && sel_i == '0) |-> data_o == data_i[0]
);

// COV1: Observe valid selection
cov_valid_sel: cover property (
    valid_o
);

// COV2: Observe invalid selection
cov_invalid_sel: cover property (
    !valid_o
);

// COV3: Observe output matching a non-zero input
cov_nonzero_output: cover property (
    valid_o && data_o != '0
);
