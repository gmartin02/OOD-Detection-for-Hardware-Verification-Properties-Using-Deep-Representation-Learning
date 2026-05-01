// AST1: When no request bits are set, valid is deasserted
ast_no_req_no_valid: assert property (
    req_i == '0 |-> valid_o == 1'b0
);

// AST2: When any request bit is set, valid is asserted
ast_req_implies_valid: assert property (
    req_i != '0 |-> valid_o == 1'b1
);

// AST3: Encoded output is within valid range
ast_enc_range: assert property (
    valid_o |-> enc_o < WIDTH[OUT_W-1:0]
);

// AST4: The encoded position actually has a set bit in the request
ast_enc_corresponds_to_set_bit: assert property (
    valid_o |-> req_i[enc_o] == 1'b1
);

// AST5: No lower-index bit is set (priority guarantee)
ast_no_lower_priority: assert property (
    valid_o |-> (req_i & ((1 << enc_o) - 1)) == '0
);

// AST6: Output is zero when input is zero
ast_zero_input_zero_output: assert property (
    req_i == '0 |-> enc_o == '0
);

// AST7: Single bit input produces correct encoding
ast_single_bit_0: assert property (
    req_i == {{(WIDTH-1){1'b0}}, 1'b1} |-> (enc_o == '0 && valid_o)
);

// AST8: All bits set produces index 0 (lowest priority wins)
ast_all_set_gives_zero: assert property (
    req_i == {WIDTH{1'b1}} |-> (enc_o == '0 && valid_o)
);

// COV1: Observe single-bit requests
cov_single_bit: cover property (
    $onehot(req_i)
);

// COV2: Observe all bits set
cov_all_set: cover property (
    req_i == {WIDTH{1'b1}}
);
