// AST1: Exactly one flag is asserted at all times (mutual exclusivity)
ast_onehot_flags: assert property (
    (eq_o + lt_o + gt_o) == 1
);

// AST2: Equal inputs produce eq flag
ast_equal_inputs: assert property (
    a_i == b_i |-> eq_o
);

// AST3: Equal flag means inputs match
ast_eq_implies_match: assert property (
    eq_o |-> a_i == b_i
);

// AST4: Less-than flag is mutually exclusive with equal
ast_lt_not_eq: assert property (
    lt_o |-> !eq_o
);

// AST5: Greater-than flag is mutually exclusive with equal
ast_gt_not_eq: assert property (
    gt_o |-> !eq_o
);

// AST6: Less-than and greater-than are mutually exclusive
ast_lt_gt_mutex: assert property (
    !(lt_o && gt_o)
);

// AST7: Reflexive — comparing a value with itself gives equal
ast_reflexive: assert property (
    a_i == b_i |-> (eq_o && !lt_o && !gt_o)
);

// AST8: Anti-symmetry — if a < b then b > a (by flag inversion)
ast_lt_antisymmetric: assert property (
    lt_o |-> !gt_o
);

// AST9: Zero compared with zero is equal
ast_zero_zero_eq: assert property (
    (a_i == '0 && b_i == '0) |-> eq_o
);

// AST10: Max value is not less than anything
ast_max_not_lt: assert property (
    a_i == {WIDTH{1'b1}} |-> !lt_o
);

// COV1: Observe equal comparison
cov_equal: cover property (
    eq_o
);

// COV2: Observe less-than comparison
cov_less_than: cover property (
    lt_o
);

// COV3: Observe greater-than comparison
cov_greater_than: cover property (
    gt_o
);
