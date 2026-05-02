// AST1: After reset, output is low
ast_reset_low: assert property (
    @(posedge clk) reset |=> !stretched_o
) else $error("FAIL: output not low after reset");

// AST2: After reset, counter is zero
ast_reset_counter: assert property (
    @(posedge clk) reset |=> counter == '0
) else $error("FAIL: counter not zero after reset");

// AST3: Pulse input triggers the output high
ast_pulse_triggers: assert property (
    @(posedge clk) disable iff (reset)
    pulse_i |=> stretched_o
) else $error("FAIL: pulse did not trigger output");

// AST4: Pulse loads counter to DURATION
ast_pulse_loads_counter: assert property (
    @(posedge clk) disable iff (reset)
    pulse_i |=> counter == DURATION[CNT_W-1:0]
) else $error("FAIL: counter not loaded on pulse");

// AST5: Counter decrements by 1 each cycle when active
ast_counter_decrement: assert property (
    @(posedge clk) disable iff (reset)
    (!pulse_i && counter > '0) |=> counter == $past(counter) - 1
) else $error("FAIL: counter did not decrement");

// AST6: Output goes low when counter reaches zero
ast_output_follows_counter: assert property (
    @(posedge clk)
    stretched_o == (counter > '0)
) else $error("FAIL: output does not follow counter");

// AST7: busy_o mirrors stretched_o
ast_busy_mirrors_stretched: assert property (
    @(posedge clk)
    busy_o == stretched_o
) else $error("FAIL: busy does not mirror stretched");

// AST8: Counter is zero when output is low
ast_zero_counter_low_output: assert property (
    @(posedge clk)
    counter == '0 |-> !stretched_o
) else $error("FAIL: output high with zero counter");

// AST9: Retrigger resets counter to DURATION
ast_retrigger: assert property (
    @(posedge clk) disable iff (reset)
    (pulse_i && counter > '0) |=> counter == DURATION[CNT_W-1:0]
) else $error("FAIL: retrigger did not reset counter");

// AST10: Counter never exceeds DURATION
ast_counter_bounded: assert property (
    @(posedge clk)
    counter <= DURATION[CNT_W-1:0]
) else $error("FAIL: counter exceeded DURATION");

// AST11: No pulse and no counter means output stays low
ast_idle_stays_low: assert property (
    @(posedge clk) disable iff (reset)
    (!pulse_i && counter == '0) |=> !stretched_o
) else $error("FAIL: output went high without pulse");

// COV1: Observe full stretch cycle (pulse to output falling)
cov_full_stretch: cover property (
    @(posedge clk) disable iff (reset)
    pulse_i ##1 stretched_o[*DURATION] ##1 !stretched_o
);

// COV2: Observe retrigger during active stretch
cov_retrigger: cover property (
    @(posedge clk) disable iff (reset)
    stretched_o && pulse_i
);

// COV3: Observe idle state
cov_idle: cover property (
    @(posedge clk) disable iff (reset)
    !stretched_o && !pulse_i
);
