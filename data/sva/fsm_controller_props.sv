// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: State encoding is always a valid state (no invalid encodings)
ast_valid_state: assert property (
@(posedge clk)
state inside {IDLE, INIT, PROCESS, VERIFY, DONE}
) else $error("FAIL ast_valid_state: FSM entered illegal state");

// AST2: done and busy are mutually exclusive
ast_done_not_busy: assert property (
@(posedge clk) disable iff (reset)
!(done && busy)
) else $error("FAIL ast_done_not_busy: done and busy both asserted");

// AST3: After reset, FSM is in IDLE and outputs are de-asserted
ast_reset_state: assert property (
@(posedge clk)
reset |=> (state == IDLE) && !done && !busy
) else $error("FAIL ast_reset_state: bad state or outputs after reset");

// AST4: done is asserted if and only if state == DONE
ast_done_iff_done_state: assert property (
@(posedge clk) disable iff (reset)
done == (state == DONE)
) else $error("FAIL ast_done_iff_done_state: done/state mismatch");

// AST5: busy is asserted iff in INIT, PROCESS, or VERIFY
ast_busy_correct: assert property (
@(posedge clk) disable iff (reset)
busy == ((state == INIT) || (state == PROCESS) || (state == VERIFY))
) else $error("FAIL ast_busy_correct: busy signal incorrect");

// AST6: FSM never goes from IDLE to PROCESS directly (must pass through INIT)
ast_no_idle_to_process: assert property (
@(posedge clk) disable iff (reset)
(state == IDLE) |=> (state != PROCESS)
) else $error("FAIL ast_no_idle_to_process: illegal IDLE→PROCESS transition");

// AST7: INIT is always exactly one cycle (next state after INIT is PROCESS)
ast_init_one_cycle: assert property (
@(posedge clk) disable iff (reset)
(state == INIT) |=> (state == PROCESS)
) else $error("FAIL ast_init_one_cycle: INIT lasted more than one cycle");

// AST8: Proc counter loads correctly when entering PROCESS from INIT
ast_proc_cnt_loads: assert property (
@(posedge clk) disable iff (reset)
(state == INIT) |=>
(proc_cnt == PROC_CYCLES[$clog2(PROC_CYCLES+1)'(PROC_CYCLES)])
) else $error("FAIL ast_proc_cnt_loads: process counter loaded wrong value");

// AST9: In PROCESS, proc_cnt decrements every cycle until 0
ast_proc_cnt_decrements: assert property (
@(posedge clk) disable iff (reset)
(state == PROCESS) && (proc_cnt > '0) |=>
(proc_cnt == $past(proc_cnt) - 1)
) else $error("FAIL ast_proc_cnt_decrements: counter did not decrement");

// AST10: PROCESS exits to VERIFY only when counter reaches 0
ast_process_exit_on_zero: assert property (
@(posedge clk) disable iff (reset)
(state == PROCESS) && (next_state == VERIFY) |->
(proc_cnt == '0)
) else $error("FAIL ast_process_exit_on_zero: exited PROCESS before counter zeroed");

// AST11: DONE is a sticky state — stays until restart
ast_done_sticky: assert property (
@(posedge clk) disable iff (reset)
(state == DONE) && !restart |=> (state == DONE)
) else $error("FAIL ast_done_sticky: DONE state exited without restart");

// AST12: Output signals are mutually exclusive (only one active at a time)
ast_outputs_mutex: assert property (
@(posedge clk) disable iff (reset)
$onehot0({init_en, proc_en, verify_en})
) else $error("FAIL ast_outputs_mutex: multiple control outputs active simultaneously");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a full successful run: IDLE → INIT → PROCESS → VERIFY → DONE
cov_full_success: cover property (
@(posedge clk) disable iff (reset)
(state == IDLE) ##1 (state == INIT) ##1 (state == PROCESS) [*1:$]
##1 (state == VERIFY) ##1 (state == DONE)
);

// COV2: Observe a retry (VERIFY → INIT) then eventually reaching DONE
cov_retry_then_done: cover property (
@(posedge clk) disable iff (reset)
(state == VERIFY) && !verify_ok ##1 (state == INIT) ##[1:$] (state == DONE)
);
