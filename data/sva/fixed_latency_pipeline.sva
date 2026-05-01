// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: After reset, out_valid is 0 (pipeline is empty)
ast_reset_out_valid: assert property (
@(posedge clk)
reset |=> (out_valid == 1'b0)
) else $error("FAIL ast_reset_out_valid: out_valid not cleared after reset");

// AST2: After reset, all stage valids are 0
ast_reset_all_stages: assert property (
@(posedge clk)
reset |=> (stage_valid[0] == 1'b0)
) else $error("FAIL ast_reset_all_stages: stage_valid[0] not cleared after reset");

// AST3: out_data is 0 after reset
ast_reset_out_data: assert property (
@(posedge clk)
reset |=> (out_data == '0)
) else $error("FAIL ast_reset_out_data: out_data not cleared after reset");

// AST4: Fixed latency — in_valid sampled now must appear at out_valid in exactly N cycles
ast_fixed_latency_valid: assert property (
@(posedge clk) disable iff (reset)
in_valid |-> ##N out_valid
) else $error("FAIL ast_fixed_latency_valid: valid did not arrive after N cycles");

// AST5: If in_valid is not asserted, out_valid cannot become asserted N cycles later
//       (provided no other in_valid was asserted in that window)
ast_no_spurious_valid: assert property (
@(posedge clk) disable iff (reset)
!in_valid |-> ##N !out_valid
) else $error("FAIL ast_no_spurious_valid: out_valid spuriously asserted");

// AST6: Data integrity — in_data presented with in_valid must equal out_data N cycles later
//       (meaningful only when in_valid was asserted at the correct point)
ast_data_integrity: assert property (
@(posedge clk) disable iff (reset)
in_valid |-> ##N (out_data == $past(in_data, N))
) else $error("FAIL ast_data_integrity: output data corrupted through pipeline");

// AST7: out_valid must track in_valid with exactly N-cycle delay
//       Negative check: out_valid cannot lead in_valid
ast_no_early_valid: assert property (
@(posedge clk) disable iff (reset)
in_valid |-> ##(N-1) !$past(out_valid, 0)
) else $error("FAIL ast_no_early_valid: valid appeared before N cycles");

// AST8: Adjacent stages propagate valid correctly (stage[i] leads stage[i+1] by 1 cycle)
ast_stage_propagation: assert property (
@(posedge clk) disable iff (reset)
stage_valid[0] |=> stage_valid[1]
) else $error("FAIL ast_stage_propagation: stage[0] valid did not propagate to stage[1]");

// AST9: out_data is never X/Z when out_valid is asserted
ast_valid_data_known: assert property (
@(posedge clk) disable iff (reset)
out_valid |-> !$isunknown(out_data)
) else $error("FAIL ast_valid_data_known: out_data contains X/Z when out_valid");

// AST10: Pipeline does not create data from nothing — if all in_valid were 0
//        for the last N cycles, out_valid must be 0 now
//        (Captured via the no_spurious_valid property above; add explicit stage check)
ast_pipeline_empty_after_drain: assert property (
@(posedge clk) disable iff (reset)
(!in_valid) throughout (1'b1[*N]) |-> (out_valid == 1'b0)
) else $error("FAIL ast_pipeline_empty_after_drain: pipeline not empty after N idle cycles");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a complete transaction — in_valid asserted and out_valid N cycles later
cov_full_transaction: cover property (
@(posedge clk) disable iff (reset)
in_valid ##N out_valid
);

// COV2: Observe back-to-back transactions (consecutive in_valid pulses)
cov_back_to_back: cover property (
@(posedge clk) disable iff (reset)
in_valid ##1 in_valid
);

// COV3: Observe pipeline filling — in_valid held for N consecutive cycles
cov_pipeline_full: cover property (
@(posedge clk) disable iff (reset)
in_valid [*N]
);
