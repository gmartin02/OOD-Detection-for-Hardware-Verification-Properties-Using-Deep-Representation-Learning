// -------------------------------------------------------------------------
// Occupancy counter (ghost variable for formal use only)
//   Tracks the true number of entries in the FIFO.
// -------------------------------------------------------------------------
// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: full and empty are mutually exclusive — never both asserted
ast_full_empty_mutex: assert property (
@(posedge clk) disable iff (reset)
!(full && empty)
) else $error("FAIL ast_full_empty_mutex: full and empty both asserted");

// AST2: After reset, FIFO is empty and not full
ast_reset_empty: assert property (
@(posedge clk)
reset |=> (empty && !full)
) else $error("FAIL ast_reset_empty: FIFO not empty after reset");

// AST3: After reset, both pointers are 0
ast_reset_ptrs: assert property (
@(posedge clk)
reset |=> (wptr == '0 && rptr == '0)
) else $error("FAIL ast_reset_ptrs: pointers not cleared after reset");

// AST4: Write pointer does not advance when FIFO is full
ast_no_write_when_full: assert property (
@(posedge clk) disable iff (reset)
full |=> (wptr == $past(wptr))
) else $error("FAIL ast_no_write_when_full: wptr advanced while full");

// AST5: Read pointer does not advance when FIFO is empty
ast_no_read_when_empty: assert property (
@(posedge clk) disable iff (reset)
empty |=> (rptr == $past(rptr))
) else $error("FAIL ast_no_read_when_empty: rptr advanced while empty");

// AST6: Occupancy never exceeds DEPTH
ast_occupancy_max: assert property (
@(posedge clk) disable iff (reset)
occupancy <= DEPTH[ADDR_W:0]
) else $error("FAIL ast_occupancy_max: occupancy exceeded DEPTH");

// AST7: full is asserted when and only when occupancy equals DEPTH
ast_full_iff_max_occupancy: assert property (
@(posedge clk) disable iff (reset)
full == (occupancy == DEPTH[ADDR_W:0])
) else $error("FAIL ast_full_iff_max_occupancy: full/occupancy mismatch");

// AST8: empty is asserted when and only when occupancy is 0
ast_empty_iff_zero_occupancy: assert property (
@(posedge clk) disable iff (reset)
empty == (occupancy == '0)
) else $error("FAIL ast_empty_iff_zero_occupancy: empty/occupancy mismatch");

// AST9: Pointers stay within [0, DEPTH-1] at all times
ast_wptr_range: assert property (
@(posedge clk)
wptr < DEPTH[ADDR_W-1:0]
) else $error("FAIL ast_wptr_range: write pointer out of range");

ast_rptr_range: assert property (
@(posedge clk)
rptr < DEPTH[ADDR_W-1:0]
) else $error("FAIL ast_rptr_range: read pointer out of range");

// AST10: Data integrity — data written is correctly stored
//        One cycle after a write, mem at the written address holds wr_data
ast_write_integrity: assert property (
@(posedge clk) disable iff (reset)
(wr_en && !full_int) |=>
(mem[$past(wptr)] == $past(wr_data))
) else $error("FAIL ast_write_integrity: written data not stored correctly");

// AST11: last_op correctly tracks direction
//        After a write-only cycle, last_op must be LAST_WRITE
ast_last_op_write: assert property (
@(posedge clk) disable iff (reset)
(wr_en && !full_int && !(rd_en && !empty_int)) |=>
(last_op == LAST_WRITE)
) else $error("FAIL ast_last_op_write: last_op not set to WRITE after write");

// AST12: After a read-only cycle, last_op must be LAST_READ
ast_last_op_read: assert property (
@(posedge clk) disable iff (reset)
(rd_en && !empty_int && !(wr_en && !full_int)) |=>
(last_op == LAST_READ)
) else $error("FAIL ast_last_op_read: last_op not set to READ after read");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe FIFO reaching full
cov_fifo_full: cover property (
@(posedge clk) disable iff (reset)
full
);

// COV2: Observe FIFO draining from full back to empty
cov_full_to_empty: cover property (
@(posedge clk) disable iff (reset)
full ##[1:$] empty
);

// COV3: Observe simultaneous read and write (steady-state throughput)
cov_simultaneous_rw: cover property (
@(posedge clk) disable iff (reset)
wr_en && !full && rd_en && !empty
);
