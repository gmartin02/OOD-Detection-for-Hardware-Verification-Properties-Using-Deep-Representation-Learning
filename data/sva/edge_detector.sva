// AST1: After reset, previous value is cleared so rise detects all current highs
ast_reset_prev_zero: assert property (
    @(posedge clk) reset |=> sig_prev == '0
) else $error("FAIL: sig_prev not zero after reset");

// AST2: Rising edge detected correctly (was 0, now 1)
ast_rise_correct: assert property (
    @(posedge clk) disable iff (reset)
    rise_o == (sig_i & ~sig_prev)
) else $error("FAIL: rise detection incorrect");

// AST3: Falling edge detected correctly (was 1, now 0)
ast_fall_correct: assert property (
    @(posedge clk) disable iff (reset)
    fall_o == (~sig_i & sig_prev)
) else $error("FAIL: fall detection incorrect");

// AST4: Toggle is the XOR of current and previous
ast_toggle_correct: assert property (
    @(posedge clk) disable iff (reset)
    toggle_o == (sig_i ^ sig_prev)
) else $error("FAIL: toggle detection incorrect");

// AST5: Rise and fall are mutually exclusive per bit
ast_rise_fall_mutex: assert property (
    @(posedge clk)
    (rise_o & fall_o) == '0
) else $error("FAIL: rise and fall on same bit simultaneously");

// AST6: Toggle is the union of rise and fall
ast_toggle_is_union: assert property (
    @(posedge clk)
    toggle_o == (rise_o | fall_o)
) else $error("FAIL: toggle is not union of rise and fall");

// AST7: No edges when signal is stable
ast_stable_no_edges: assert property (
    @(posedge clk) disable iff (reset)
    sig_i == sig_prev |-> toggle_o == '0
) else $error("FAIL: edges detected on stable signal");

// AST8: sig_prev tracks the previous value of sig_i
ast_prev_tracks: assert property (
    @(posedge clk) disable iff (reset)
    sig_prev == $past(sig_i)
) else $error("FAIL: sig_prev not tracking sig_i");

// AST9: All zeros input after reset produces no fall edges
ast_no_fall_after_reset: assert property (
    @(posedge clk)
    reset |=> fall_o == '0
) else $error("FAIL: fall edges after reset");

// AST10: Constant high signal has rise only on first cycle after change
ast_constant_no_toggle: assert property (
    @(posedge clk) disable iff (reset)
    (sig_i == $past(sig_i)) |-> toggle_o == '0
) else $error("FAIL: toggle on constant signal");

// COV1: Observe rising edge on at least one channel
cov_rising: cover property (
    @(posedge clk) disable iff (reset)
    rise_o != '0
);

// COV2: Observe falling edge on at least one channel
cov_falling: cover property (
    @(posedge clk) disable iff (reset)
    fall_o != '0
);

// COV3: Observe simultaneous rise and fall on different channels
cov_rise_and_fall: cover property (
    @(posedge clk) disable iff (reset)
    rise_o != '0 && fall_o != '0
);
