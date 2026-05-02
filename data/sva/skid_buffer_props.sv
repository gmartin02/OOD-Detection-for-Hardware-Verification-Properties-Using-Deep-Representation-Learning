// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: After reset, module is in bypass mode with ready asserted
ast_reset_bypass: assert property (
@(posedge clk)
reset |=> (bypass_rg && out_ready && !$past(bypass_rg, 1, , reset))
// Simplification: just check bypass_rg and out_ready are set post-reset
) else $error("FAIL ast_reset_bypass: not in bypass mode after reset");

// Cleaner reset check:
ast_reset_ready: assert property (
@(posedge clk)
reset |=> out_ready
) else $error("FAIL ast_reset_ready: out_ready not asserted after reset");

ast_reset_data_rg: assert property (
@(posedge clk)
reset |=> (data_rg == '0)
) else $error("FAIL ast_reset_data_rg: data_rg not cleared after reset");

// AST2: out_ready equals bypass_rg (output wiring correctness)
ast_ready_eq_bypass: assert property (
@(posedge clk) disable iff (reset)
out_ready == bypass_rg
) else $error("FAIL ast_ready_eq_bypass: out_ready / bypass_rg mismatch");

// AST3: In bypass mode, out_valid reflects in_valid
ast_bypass_valid_passthrough: assert property (
@(posedge clk) disable iff (reset)
bypass_rg |-> (out_valid == in_valid)
) else $error("FAIL ast_bypass_valid_passthrough: out_valid not tracking in_valid in bypass");

// AST4: In skid mode, out_valid is always 1 (buffered data pending)
ast_skid_valid_asserted: assert property (
@(posedge clk) disable iff (reset)
!bypass_rg |-> out_valid
) else $error("FAIL ast_skid_valid_asserted: out_valid not 1 in skid mode");

// AST5: In bypass mode, out_data equals in_data (direct pass-through)
ast_bypass_data_passthrough: assert property (
@(posedge clk) disable iff (reset)
bypass_rg |-> (out_data == in_data)
) else $error("FAIL ast_bypass_data_passthrough: out_data not in_data in bypass mode");

// AST6: In skid mode, out_data equals data_rg (buffered data presented)
ast_skid_data_from_rg: assert property (
@(posedge clk) disable iff (reset)
!bypass_rg |-> (out_data == data_rg)
) else $error("FAIL ast_skid_data_from_rg: out_data not data_rg in skid mode");

// AST7: Skid entry condition — transition from bypass to skid happens only
//       when downstream is stalled and upstream presents valid data
ast_bypass_to_skid_condition: assert property (
@(posedge clk) disable iff (reset)
$fell(bypass_rg) |-> ($past(!in_ready) && $past(in_valid))
) else $error("FAIL ast_bypass_to_skid_condition: entered skid without stall+valid");

// AST8: Data captured correctly — data_rg holds in_data from the cycle of skid entry
ast_skid_captures_data: assert property (
@(posedge clk) disable iff (reset)
$fell(bypass_rg) |=> (data_rg == $past(in_data))
) else $error("FAIL ast_skid_captures_data: data_rg does not match captured in_data");

// AST9: Skid exit condition — bypass_rg rises only when in_ready is asserted
ast_skid_to_bypass_condition: assert property (
@(posedge clk) disable iff (reset)
$rose(bypass_rg) && !reset |-> $past(in_ready)
) else $error("FAIL ast_skid_to_bypass_condition: exited skid without in_ready");

// AST10: data_rg is stable while in skid mode and downstream is not ready
ast_skid_data_stable: assert property (
@(posedge clk) disable iff (reset)
(!bypass_rg && !in_ready) |=> (data_rg == $past(data_rg) && !bypass_rg)
) else $error("FAIL ast_skid_data_stable: data_rg changed while stalled in skid mode");

// AST11: out_ready (bypass_rg) cannot de-assert unless a valid data transfer
//        was in flight (in_valid must have been 1 at the entry cycle)
ast_no_spurious_stall: assert property (
@(posedge clk) disable iff (reset)
$fell(out_ready) |-> $past(in_valid)
) else $error("FAIL ast_no_spurious_stall: out_ready fell without in_valid");

// AST12: No data created from nothing — out_valid in bypass mode requires in_valid
ast_no_phantom_valid: assert property (
@(posedge clk) disable iff (reset)
(bypass_rg && out_valid) |-> in_valid
) else $error("FAIL ast_no_phantom_valid: out_valid in bypass without in_valid");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a skid event — module enters skid mode
cov_skid_entry: cover property (
@(posedge clk) disable iff (reset)
$fell(bypass_rg)
);

// COV2: Observe a complete skid cycle: bypass → skid → bypass
cov_full_skid_cycle: cover property (
@(posedge clk) disable iff (reset)
bypass_rg ##1 !bypass_rg ##[1:$] bypass_rg
);

// COV3: Observe sustained throughput — transfers in two consecutive cycles
cov_sustained_throughput: cover property (
@(posedge clk) disable iff (reset)
(out_valid && in_ready) ##1 (out_valid && in_ready)
);
