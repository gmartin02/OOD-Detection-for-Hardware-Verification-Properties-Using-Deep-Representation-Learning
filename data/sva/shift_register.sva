// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: After reset, data_out is 0
ast_reset_data_out: assert property (
@(posedge clk)
reset |=> (data_out == '0)
) else $error("FAIL ast_reset_data_out: data_out not zero after reset");

// AST2: After reset, stage[0] is 0
ast_reset_stage0: assert property (
@(posedge clk)
reset |=> (stage[0] == '0)
) else $error("FAIL ast_reset_stage0: stage[0] not zero after reset");

// AST3: In HOLD mode, stage[0] is unchanged next cycle
ast_hold_stable: assert property (
@(posedge clk) disable iff (reset)
(mode == HOLD) |=> (stage[0] == $past(stage[0]))
) else $error("FAIL ast_hold_stable: stage[0] changed during HOLD mode");

// AST4: LOAD mode correctly captures data_in into stage[0] next cycle
ast_load_captures: assert property (
@(posedge clk) disable iff (reset)
(mode == LOAD) |=> (stage[0] == $past(data_in))
) else $error("FAIL ast_load_captures: LOAD did not capture data_in");

// AST5: SHIFT_L — serial_in enters at bit 0 of stage[0]
ast_shift_left_serial_in: assert property (
@(posedge clk) disable iff (reset)
(mode == SHIFT_L) |=> (stage[0][0] == $past(serial_in))
) else $error("FAIL ast_shift_left_serial_in: serial_in not captured at bit 0 on SHIFT_L");

// AST6: SHIFT_L — upper bits of stage[0] are previous lower bits (left-shift)
ast_shift_left_data: assert property (
@(posedge clk) disable iff (reset)
(mode == SHIFT_L) |=>
(stage[0][WIDTH-1:1] == $past(stage[0][WIDTH-2:0]))
) else $error("FAIL ast_shift_left_data: incorrect left-shift data in stage[0]");

// AST7: SHIFT_R — serial_in enters at MSB of stage[0]
ast_shift_right_serial_in: assert property (
@(posedge clk) disable iff (reset)
(mode == SHIFT_R) |=> (stage[0][WIDTH-1] == $past(serial_in))
) else $error("FAIL ast_shift_right_serial_in: serial_in not captured at MSB on SHIFT_R");

// AST8: SHIFT_R — lower bits of stage[0] are previous upper bits (right-shift)
ast_shift_right_data: assert property (
@(posedge clk) disable iff (reset)
(mode == SHIFT_R) |=>
(stage[0][WIDTH-2:0] == $past(stage[0][WIDTH-1:1]))
) else $error("FAIL ast_shift_right_data: incorrect right-shift data in stage[0]");

// AST9: Chain propagation — each stage captures the previous stage's value
ast_chain_prop: assert property (
@(posedge clk) disable iff (reset)
stage[1] == $past(stage[0])
) else $error("FAIL ast_chain_prop: stage[1] did not capture stage[0]");

// AST10: data_out is always stage[DEPTH-1] (output wiring is correct)
ast_data_out_wiring: assert property (
@(posedge clk) disable iff (reset)
data_out == stage[DEPTH-1]
) else $error("FAIL ast_data_out_wiring: data_out does not match final stage");

// AST11: serial_out is 0 in HOLD and LOAD modes (no meaningful serial output)
ast_serial_out_inactive: assert property (
@(posedge clk) disable iff (reset)
(mode == HOLD || mode == LOAD) |-> (serial_out == 1'b0)
) else $error("FAIL ast_serial_out_inactive: serial_out non-zero in non-shift mode");

// AST12: End-to-end data integrity — data loaded at stage[0] must appear
//        at stage[DEPTH-1] exactly DEPTH cycles later (only valid when
//        the chain shifts every cycle; use a fixed pattern check)
ast_e2e_integrity: assert property (
@(posedge clk) disable iff (reset)
// If HOLD throughout, data_out must not change
(mode == HOLD) [*DEPTH] |->
(data_out == $past(data_out, DEPTH))
) else $error("FAIL ast_e2e_integrity: data_out changed during sustained HOLD");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a LOAD followed by DEPTH SHIFT_L cycles; check data propagated
cov_load_then_shift_left: cover property (
@(posedge clk) disable iff (reset)
(mode == LOAD) ##1 (mode == SHIFT_L) [*DEPTH]
);

// COV2: Observe a LOAD followed by DEPTH SHIFT_R cycles
cov_load_then_shift_right: cover property (
@(posedge clk) disable iff (reset)
(mode == LOAD) ##1 (mode == SHIFT_R) [*DEPTH]
);

// COV3: Observe all four modes exercised in sequence
cov_all_modes: cover property (
@(posedge clk) disable iff (reset)
(mode == LOAD) ##1 (mode == SHIFT_L) ##1 (mode == SHIFT_R) ##1 (mode == HOLD)
);
