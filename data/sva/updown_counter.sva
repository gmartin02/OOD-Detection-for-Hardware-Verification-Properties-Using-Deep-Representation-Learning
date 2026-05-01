// AST1: After reset, counter is zero
ast_reset_zero: assert property (
    @(posedge clk) reset |=> count == '0
) else $error("FAIL: counter not zero after reset");

// AST2: After reset, at_zero is asserted
ast_reset_at_zero: assert property (
    @(posedge clk) reset |=> at_zero
) else $error("FAIL: at_zero not set after reset");

// AST3: After reset, at_max is deasserted (assuming MAX_VAL > 0)
ast_reset_not_max: assert property (
    @(posedge clk) reset |=> !at_max
) else $error("FAIL: at_max set after reset");

// AST4: Hold operation does not change count
ast_hold_stable: assert property (
    @(posedge clk) disable iff (reset)
    op == 2'b00 |=> count == $past(count)
) else $error("FAIL: count changed during hold");

// AST5: Increment increases count by 1 when not at max
ast_inc_normal: assert property (
    @(posedge clk) disable iff (reset)
    (op == 2'b01 && !at_max) |=> count == $past(count) + 1
) else $error("FAIL: increment did not add 1");

// AST6: Increment saturates at max
ast_inc_saturate: assert property (
    @(posedge clk) disable iff (reset)
    (op == 2'b01 && at_max) |=> count == $past(count)
) else $error("FAIL: counter overflowed past max");

// AST7: Decrement decreases count by 1 when not at zero
ast_dec_normal: assert property (
    @(posedge clk) disable iff (reset)
    (op == 2'b10 && !at_zero) |=> count == $past(count) - 1
) else $error("FAIL: decrement did not subtract 1");

// AST8: Decrement saturates at zero
ast_dec_saturate: assert property (
    @(posedge clk) disable iff (reset)
    (op == 2'b10 && at_zero) |=> count == '0
) else $error("FAIL: counter underflowed below zero");

// AST9: Load sets count to load_val
ast_load_correct: assert property (
    @(posedge clk) disable iff (reset)
    op == 2'b11 |=> count == $past(load_val)
) else $error("FAIL: load did not set correct value");

// AST10: at_max is correctly derived
ast_at_max_correct: assert property (
    @(posedge clk)
    at_max == (count == MAX_VAL[WIDTH-1:0])
) else $error("FAIL: at_max flag incorrect");

// AST11: at_zero is correctly derived
ast_at_zero_correct: assert property (
    @(posedge clk)
    at_zero == (count == '0)
) else $error("FAIL: at_zero flag incorrect");

// AST12: Counter value never exceeds MAX_VAL
ast_count_bounded: assert property (
    @(posedge clk)
    count <= MAX_VAL[WIDTH-1:0]
) else $error("FAIL: count exceeded MAX_VAL");

// COV1: Observe counter reaching max from increment
cov_reach_max: cover property (
    @(posedge clk) disable iff (reset)
    !at_max ##1 at_max
);

// COV2: Observe counter reaching zero from decrement
cov_reach_zero: cover property (
    @(posedge clk) disable iff (reset)
    !at_zero ##1 at_zero
);

// COV3: Observe load followed by increment
cov_load_then_inc: cover property (
    @(posedge clk) disable iff (reset)
    op == 2'b11 ##1 op == 2'b01
);
