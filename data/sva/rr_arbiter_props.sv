// -------------------------------------------------------------------------
// Helper: count number of set bits in grant (should be 0 or 1)
// -------------------------------------------------------------------------
// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: Grant is always one-hot or zero (never multi-grant)
ast_grant_onehot: assert property (
@(posedge clk) disable iff (reset)
popcount(grant) <= 1
) else $error("FAIL ast_grant_onehot: multiple grants asserted simultaneously");

// AST2: No grant without a request — granted bit must be set in req
ast_grant_implies_req: assert property (
@(posedge clk) disable iff (reset)
(grant != '0) |-> ((grant & req) == grant)
) else $error("FAIL ast_grant_implies_req: grant given with no matching request");

// AST3: No grant when req is zero
ast_no_grant_no_req: assert property (
@(posedge clk) disable iff (reset)
(req == '0) |-> (grant == '0)
) else $error("FAIL ast_no_grant_no_req: grant issued with no requests");

// AST4: If any req is asserted, exactly one grant must be given
ast_req_implies_grant: assert property (
@(posedge clk) disable iff (reset)
(req != '0) |-> (popcount(grant) == 1)
) else $error("FAIL ast_req_implies_grant: request with no grant");

// AST5: Priority pointer stays within valid range [0, N-1]
ast_ptr_range: assert property (
@(posedge clk)
priority_ptr < N[$clog2(N)'(N)]
) else $error("FAIL ast_ptr_range: priority_ptr out of range");

// AST6: After reset, priority pointer is 0
ast_reset_ptr: assert property (
@(posedge clk)
reset |=> (priority_ptr == '0)
) else $error("FAIL ast_reset_ptr: pointer not cleared after reset");

// AST7: After reset, grant is zero
ast_reset_grant: assert property (
@(posedge clk)
reset |=> (grant == '0)
) else $error("FAIL ast_reset_grant: grant not cleared after reset");

// AST8: Grant is stable within the same cycle (purely combinational — no delta hazard)
//       If req doesn't change, grant doesn't change (checked cycle-to-cycle)
ast_grant_stable_req: assert property (
@(posedge clk) disable iff (reset)
(req == $past(req)) && ($past(grant) != '0) |->
(grant == $past(grant))
) else $error("FAIL ast_grant_stable_req: grant changed while req and ptr unchanged");

// AST9: Priority wraps correctly — pointer is always modulo N
//       After granting slot N-1, pointer must become 0 next cycle
ast_ptr_wrap: assert property (
@(posedge clk) disable iff (reset)
(grant[N-1] && (priority_ptr == N[$clog2(N)'(N-1)])) |=>
(priority_ptr == '0)
) else $error("FAIL ast_ptr_wrap: priority pointer did not wrap to 0");

// AST10: Fairness — if a single requester is always active, it must eventually be granted
//        (bounded liveness: within N cycles, it will be granted)
//        Expressed as: if req[0] held for N cycles, grant[0] must have been asserted
// Cover that req[0] is indeed eventually granted
cov_req0_granted: cover property (
@(posedge clk) disable iff (reset)
req[0] ##1 grant[0]
);

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: All requestors granted in sequence (observe round-robin rotation)
cov_rotation: cover property (
@(posedge clk) disable iff (reset)
grant[0] ##1 grant[1]
);

// COV2: Grant switches from one requester to another (not always same)
cov_grant_changes: cover property (
@(posedge clk) disable iff (reset)
(grant != '0) ##1 (grant != $past(grant)) && (grant != '0)
);
