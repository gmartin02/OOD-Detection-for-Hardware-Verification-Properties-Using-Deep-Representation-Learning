// Bind a copy of rd_addr and wr_data for use in past-cycle checks
// --- SAFETY PROPERTIES ---------------------------------------------------
// AST1: After reset, all readable locations return 0
//       Check rd_data is 0 immediately after reset regardless of rd_addr
ast_reset_reads_zero: assert property (
@(posedge clk)
$rose(reset) |=> (rd_data == '0)
) else $error("FAIL ast_reset_reads_zero: non-zero read after reset");

// AST2: Write enable low → no register changes (mem is stable)
//       Sample a specific address and verify no write occurs without wr_en
ast_no_write_without_en: assert property (
@(posedge clk) disable iff (reset)
(!wr_en) |=> (mem[wr_addr_d1] == $past(mem[wr_addr_d1]))
) else $error("FAIL ast_no_write_without_en: memory changed without write enable");

// AST3: Write data is correctly stored — one cycle after a write, reading
//       the same address should return the written data (no intervening write)
ast_write_then_read: assert property (
@(posedge clk) disable iff (reset)
(wr_en && !$past(reset)) |=>
(mem[wr_addr_d1] == wr_data_d1)
) else $error("FAIL ast_write_then_read: written data not stored correctly");

// AST4: Read address within range (no out-of-bounds access)
ast_rd_addr_range: assert property (
@(posedge clk)
rd_addr < DEPTH[$clog2(DEPTH)'(DEPTH)]
) else $error("FAIL ast_rd_addr_range: read address out of range");

// AST5: Write address within range
ast_wr_addr_range: assert property (
@(posedge clk)
wr_addr < DEPTH[$clog2(DEPTH)'(DEPTH)]
) else $error("FAIL ast_wr_addr_range: write address out of range");

// AST6: rd_data is always a valid DW-bit value (no X/Z propagation in simulation)
ast_rd_data_known: assert property (
@(posedge clk) disable iff (reset)
!$isunknown(rd_data)
) else $error("FAIL ast_rd_data_known: rd_data contains X or Z");

// AST7: After reset de-assertion, mem[0] must be 0 on the very next cycle
ast_mem0_reset: assert property (
@(posedge clk)
reset |=> (mem[0] == '0)
) else $error("FAIL ast_mem0_reset: mem[0] not zero after reset");

// AST8: Combinational read is immediately consistent with last write
//       If no write occurred this cycle, rd_data reflects mem[rd_addr]
ast_read_consistency: assert property (
@(posedge clk) disable iff (reset)
(!wr_en || (wr_addr != rd_addr)) |->
(rd_data == mem[rd_addr])
) else $error("FAIL ast_read_consistency: rd_data inconsistent with memory");

// AST9: Consecutive writes to the same address — second write wins
ast_write_overwrites: assert property (
@(posedge clk) disable iff (reset)
(wr_en && $past(wr_en) && (wr_addr == $past(wr_addr))) |->
(mem[wr_addr] == $past(wr_data))  // previous write was stored
) else $error("FAIL ast_write_overwrites: overwrite did not take effect");

// AST10: Memory stability — unwritten locations remain unchanged
ast_unwritten_stable: assert property (
@(posedge clk) disable iff (reset)
(wr_en && !reset) |=>
// All other locations except the written one are unchanged
// (Check a fixed location 0 as a representative spot)
(($past(wr_addr_d1) != '0) |->
(mem[0] == $past(mem[0])))
) else $error("FAIL ast_unwritten_stable: unwritten location changed");

// --- COVER PROPERTIES ----------------------------------------------------
// COV1: Observe a successful write followed by a read of same address
cov_write_read_same_addr: cover property (
@(posedge clk) disable iff (reset)
wr_en ##1 (!wr_en && (rd_addr == $past(wr_addr)))
);

// COV2: Observe back-to-back writes to different addresses
cov_back_to_back_writes: cover property (
@(posedge clk) disable iff (reset)
(wr_en) ##1 (wr_en && (wr_addr != $past(wr_addr)))
);
