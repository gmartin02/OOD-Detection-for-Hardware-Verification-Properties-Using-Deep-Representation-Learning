// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: After reset, no downstream valid and no skid occupancy
ast_reset_clean: assert property (
@(posedge clk)
reset |=> (!dn_valid && !skid_valid && !main_valid)
) else $error("FAIL ast_reset_clean: pipeline not empty after reset");

// AST2: dn_valid is asserted iff main_valid is set (output wiring check)
ast_dn_valid_eq_main: assert property (
@(posedge clk) disable iff (reset)
dn_valid == main_valid
) else $error("FAIL ast_dn_valid_eq_main: dn_valid/main_valid mismatch");

// AST3: up_ready de-asserted iff skid is full (ready/skid relationship)
ast_up_ready_eq_not_skid: assert property (
@(posedge clk) disable iff (reset)
up_ready == !skid_valid
) else $error("FAIL ast_up_ready_eq_not_skid: up_ready/skid_valid mismatch");

// AST4: Once dn_valid is asserted, it must stay asserted until dn_ready
//       (downstream valid stability — no dropping valid without handshake)
ast_dn_valid_stable: assert property (
@(posedge clk) disable iff (reset)
(dn_valid && !dn_ready) |=> dn_valid
) else $error("FAIL ast_dn_valid_stable: dn_valid dropped without dn_ready");

// AST5: dn_data is stable while dn_valid is asserted and dn_ready is low
ast_dn_data_stable: assert property (
@(posedge clk) disable iff (reset)
(dn_valid && !dn_ready) |=> (dn_data == $past(dn_data))
) else $error("FAIL ast_dn_data_stable: dn_data changed while dn_valid without dn_ready");

// AST6: Skid cannot be valid when main register is empty
//       (main is always filled before the skid overflows)
ast_skid_implies_main: assert property (
@(posedge clk) disable iff (reset)
skid_valid |-> main_valid
) else $error("FAIL ast_skid_implies_main: skid occupied but main register empty");

// AST7: Data integrity — if an upstream transfer occurs when main is empty,
//       dn_data must reflect up_data exactly one cycle later
ast_data_passthrough: assert property (
@(posedge clk) disable iff (reset)
(up_xfer && !main_valid) |=> (dn_data == $past(up_data))
) else $error("FAIL ast_data_passthrough: up_data not propagated to dn_data");

// AST8: Skid data integrity — data captured in skid register is preserved
ast_skid_data_preserved: assert property (
@(posedge clk) disable iff (reset)
(skid_valid && !dn_xfer) |=> (skid_data == $past(skid_data) && skid_valid)
) else $error("FAIL ast_skid_data_preserved: skid data changed or lost while stalled");

// AST9: Upstream cannot transfer when skid is full (up_ready is de-asserted)
ast_no_up_xfer_skid_full: assert property (
@(posedge clk) disable iff (reset)
skid_valid |-> !up_xfer
) else $error("FAIL ast_no_up_xfer_skid_full: upstream transfer occurred with full skid");

// AST10: After a downstream transfer with no skid data, dn_valid de-asserts
//        next cycle (if no new upstream data arrives)
ast_dn_deasserts_after_xfer: assert property (
@(posedge clk) disable iff (reset)
(dn_xfer && !skid_valid && !up_xfer) |=> !dn_valid
) else $error("FAIL ast_dn_deasserts_after_xfer: dn_valid stayed asserted spuriously");

// AST11: Skid drains after downstream transfer — skid_valid must be 0 next cycle
ast_skid_drains: assert property (
@(posedge clk) disable iff (reset)
(dn_xfer && skid_valid) |=> !skid_valid
) else $error("FAIL ast_skid_drains: skid_valid not cleared after downstream transfer");

// AST12: No data created from nothing — dn_valid can only be set if an
//        upstream transfer has occurred (eventually)
//        (Structural: main_valid is only set when up_xfer occurred or skid drained)
ast_no_phantom_data: assert property (
@(posedge clk) disable iff (reset)
$rose(main_valid) |->
($past(up_xfer) || $past(skid_valid && dn_xfer))
) else $error("FAIL ast_no_phantom_data: main_valid set without a source transfer");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a skid buffer fill — upstream fires while main is occupied
//       and downstream is stalled
cov_skid_fill: cover property (
@(posedge clk) disable iff (reset)
up_xfer && main_valid && !dn_xfer ##1 skid_valid
);

// COV2: Observe full skid cycle: skid fills, then drains
cov_skid_fill_drain: cover property (
@(posedge clk) disable iff (reset)
$rose(skid_valid) ##[1:$] $fell(skid_valid)
);

// COV3: Observe simultaneous upstream and downstream transfers (cut-through)
cov_simultaneous_xfer: cover property (
@(posedge clk) disable iff (reset)
up_xfer && dn_xfer
);
