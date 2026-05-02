// AST1: After reset, counter is loaded with TIMEOUT
ast_reset_loads_timeout: assert property (
    @(posedge clk) reset |=> counter == TIMEOUT[WIDTH-1:0]
) else $error("FAIL: counter not loaded after reset");

// AST2: After reset, timeout is cleared
ast_reset_clears_timeout: assert property (
    @(posedge clk) reset |=> !timeout
) else $error("FAIL: timeout not cleared after reset");

// AST3: Kick reloads counter to TIMEOUT
ast_kick_reloads: assert property (
    @(posedge clk) disable iff (reset)
    kick |=> counter == TIMEOUT[WIDTH-1:0]
) else $error("FAIL: kick did not reload counter");

// AST4: Kick clears timeout flag
ast_kick_clears_timeout: assert property (
    @(posedge clk) disable iff (reset)
    kick |=> !timeout
) else $error("FAIL: kick did not clear timeout");

// AST5: Counter decrements by 1 when enabled and not timed out
ast_decrement: assert property (
    @(posedge clk) disable iff (reset)
    (enable && !timeout && !kick && counter > '0) |=> counter == $past(counter) - 1
) else $error("FAIL: counter did not decrement");

// AST6: Counter holds when disabled
ast_hold_disabled: assert property (
    @(posedge clk) disable iff (reset)
    (!enable && !kick) |=> counter == $past(counter)
) else $error("FAIL: counter changed while disabled");

// AST7: Timeout asserts when counter reaches zero
ast_timeout_at_zero: assert property (
    @(posedge clk) disable iff (reset)
    (enable && !kick && counter == '0 && !timeout) |=> timeout
) else $error("FAIL: timeout not asserted at zero");

// AST8: Once timed out, counter stops (holds at zero)
ast_timeout_holds: assert property (
    @(posedge clk) disable iff (reset)
    (timeout && !kick) |=> timeout
) else $error("FAIL: timeout cleared without kick");

// AST9: Running flag reflects correct state
ast_running_correct: assert property (
    @(posedge clk)
    running == (enable && !timeout && counter > '0)
) else $error("FAIL: running flag incorrect");

// AST10: Counter never exceeds TIMEOUT
ast_counter_bounded: assert property (
    @(posedge clk)
    counter <= TIMEOUT[WIDTH-1:0]
) else $error("FAIL: counter exceeded TIMEOUT");

// AST11: Reset takes priority over kick
ast_reset_over_kick: assert property (
    @(posedge clk)
    (reset && kick) |=> !timeout
) else $error("FAIL: reset priority violated");

// COV1: Observe timeout event
cov_timeout: cover property (
    @(posedge clk) disable iff (reset)
    !timeout ##1 timeout
);

// COV2: Observe kick preventing timeout
cov_kick_saves: cover property (
    @(posedge clk) disable iff (reset)
    (counter < 3 && enable && !timeout) ##[1:3] kick
);

// COV3: Observe kick after timeout (recovery)
cov_recovery: cover property (
    @(posedge clk) disable iff (reset)
    timeout ##1 kick
);
