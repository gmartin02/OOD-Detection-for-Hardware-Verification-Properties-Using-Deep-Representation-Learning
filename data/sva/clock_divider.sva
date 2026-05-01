// AST1: After reset, clk_out is low
ast_reset_clk_low: assert property (
    @(posedge clk) reset |=> clk_out == 1'b0
) else $error("FAIL: clk_out not low after reset");

// AST2: After reset, counter is zero
ast_reset_counter: assert property (
    @(posedge clk) reset |=> counter == '0
) else $error("FAIL: counter not zero after reset");

// AST3: After reset, tick is deasserted
ast_reset_tick: assert property (
    @(posedge clk) reset |=> !tick
) else $error("FAIL: tick asserted after reset");

// AST4: Counter increments when enabled and below div_val
ast_counter_inc: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter < div_val) |=> counter == $past(counter) + 1
) else $error("FAIL: counter did not increment");

// AST5: Counter resets to zero when reaching div_val
ast_counter_reset: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter >= div_val) |=> counter == '0
) else $error("FAIL: counter did not reset at div_val");

// AST6: clk_out toggles when counter reaches div_val
ast_clk_toggles: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter >= div_val) |=> clk_out == ~$past(clk_out)
) else $error("FAIL: clk_out did not toggle");

// AST7: clk_out holds when counter has not reached div_val
ast_clk_holds: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter < div_val) |=> clk_out == $past(clk_out)
) else $error("FAIL: clk_out changed prematurely");

// AST8: Tick is asserted exactly when counter reaches div_val
ast_tick_at_toggle: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter >= div_val) |=> tick
) else $error("FAIL: tick not asserted at toggle");

// AST9: Tick is single-cycle (deasserted when not at toggle)
ast_tick_single_cycle: assert property (
    @(posedge clk) disable iff (reset)
    (enable && counter < div_val) |=> !tick
) else $error("FAIL: tick asserted when not at toggle");

// AST10: Counter holds when not enabled
ast_counter_hold_disabled: assert property (
    @(posedge clk) disable iff (reset)
    !enable |=> counter == $past(counter)
) else $error("FAIL: counter changed while disabled");

// AST11: Tick is low when disabled
ast_tick_disabled: assert property (
    @(posedge clk) disable iff (reset)
    !enable |=> !tick
) else $error("FAIL: tick asserted while disabled");

// AST12: Counter never exceeds div_val
ast_counter_bounded: assert property (
    @(posedge clk) disable iff (reset)
    counter <= div_val
) else $error("FAIL: counter exceeded div_val");

// COV1: Observe clk_out toggle
cov_toggle: cover property (
    @(posedge clk) disable iff (reset)
    clk_out != $past(clk_out)
);

// COV2: Observe tick pulse
cov_tick: cover property (
    @(posedge clk) disable iff (reset)
    tick
);

// COV3: Observe full period (two toggles)
cov_full_period: cover property (
    @(posedge clk) disable iff (reset)
    tick ##[1:$] tick
);
