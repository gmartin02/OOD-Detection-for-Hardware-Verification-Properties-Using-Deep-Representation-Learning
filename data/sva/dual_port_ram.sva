// AST1: Write stores data correctly — one cycle after write, memory holds the data
ast_write_integrity: assert property (
    @(posedge clk)
    wr_en |=> mem[$past(wr_addr)] == $past(wr_data)
) else $error("FAIL: write data not stored correctly");

// AST2: Read returns stored data — one cycle after read enable, rd_data reflects memory
ast_read_correct: assert property (
    @(posedge clk)
    (rd_en && !(wr_en && wr_addr == rd_addr)) |=> rd_data == $past(mem[rd_addr])
) else $error("FAIL: read data incorrect");

// AST3: Read data holds when rd_en is deasserted
ast_read_data_holds: assert property (
    @(posedge clk)
    !rd_en |=> rd_data == $past(rd_data)
) else $error("FAIL: rd_data changed without rd_en");

// AST4: Write address must be in range
ast_wr_addr_range: assert property (
    @(posedge clk)
    wr_en |-> wr_addr < DEPTH[ADDR_W-1:0]
) else $error("FAIL: write address out of range");

// AST5: Read address must be in range
ast_rd_addr_range: assert property (
    @(posedge clk)
    rd_en |-> rd_addr < DEPTH[ADDR_W-1:0]
) else $error("FAIL: read address out of range");

// AST6: Memory not written preserves its value
ast_no_write_preserves: assert property (
    @(posedge clk)
    !wr_en |=> mem == $past(mem)
) else $error("FAIL: memory changed without write enable");

// AST7: Consecutive writes to same address — last write wins
ast_last_write_wins: assert property (
    @(posedge clk)
    (wr_en && $past(wr_en) && wr_addr == $past(wr_addr)) |->
    mem[wr_addr] == wr_data
);

// AST8: Write does not affect other addresses
ast_write_no_aliasing: assert property (
    @(posedge clk)
    wr_en |=> (mem[$past(wr_addr)] == $past(wr_data))
) else $error("FAIL: write affected wrong address");

// AST9: Read and write to different addresses — read returns old value
ast_rw_different_addr: assert property (
    @(posedge clk)
    (rd_en && wr_en && rd_addr != wr_addr) |=> rd_data == $past(mem[rd_addr])
) else $error("FAIL: read corrupted by write to different address");

// COV1: Observe simultaneous read and write to same address
cov_rw_same_addr: cover property (
    @(posedge clk)
    rd_en && wr_en && rd_addr == wr_addr
);

// COV2: Observe write to address 0
cov_write_addr0: cover property (
    @(posedge clk)
    wr_en && wr_addr == '0
);

// COV3: Observe back-to-back writes to different addresses
cov_back2back_writes: cover property (
    @(posedge clk)
    wr_en ##1 (wr_en && wr_addr != $past(wr_addr))
);
