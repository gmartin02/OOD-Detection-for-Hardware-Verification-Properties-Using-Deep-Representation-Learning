// AST1: After reset, CRC is zero
ast_reset_zero: assert property (
    @(posedge clk) reset |=> crc_o == '0
) else $error("FAIL: CRC not zero after reset");

// AST2: Init loads the specified initial value
ast_init_loads: assert property (
    @(posedge clk) disable iff (reset)
    init |=> crc_o == $past(init_val)
) else $error("FAIL: init did not load correct value");

// AST3: CRC holds when data_valid is deasserted and no init or reset
ast_hold_stable: assert property (
    @(posedge clk) disable iff (reset)
    (!data_valid && !init) |=> crc_o == $past(crc_o)
) else $error("FAIL: CRC changed without data_valid or init");

// AST4: CRC changes when data is shifted in (feedback = 1 case)
ast_shift_xor: assert property (
    @(posedge clk) disable iff (reset)
    (data_valid && !init && (crc_o[CRC_W-1] ^ data_bit)) |=>
    crc_o == ({$past(crc_o[CRC_W-2:0]), 1'b0} ^ POLY)
) else $error("FAIL: CRC XOR computation incorrect");

// AST5: CRC shift without XOR (feedback = 0 case)
ast_shift_no_xor: assert property (
    @(posedge clk) disable iff (reset)
    (data_valid && !init && !(crc_o[CRC_W-1] ^ data_bit)) |=>
    crc_o == {$past(crc_o[CRC_W-2:0]), 1'b0}
) else $error("FAIL: CRC shift-only computation incorrect");

// AST6: Reset takes priority over init
ast_reset_priority_over_init: assert property (
    @(posedge clk)
    (reset && init) |=> crc_o == '0
) else $error("FAIL: reset did not take priority over init");

// AST7: Reset takes priority over data_valid
ast_reset_priority_over_data: assert property (
    @(posedge clk)
    (reset && data_valid) |=> crc_o == '0
) else $error("FAIL: reset did not take priority over data_valid");

// AST8: Init takes priority over data_valid
ast_init_priority_over_data: assert property (
    @(posedge clk) disable iff (reset)
    (init && data_valid) |=> crc_o == $past(init_val)
) else $error("FAIL: init did not take priority over data_valid");

// AST9: CRC from all-zeros initial + zero data bit yields zero
ast_zero_stays_zero: assert property (
    @(posedge clk) disable iff (reset)
    (data_valid && !init && crc_o == '0 && data_bit == 1'b0) |=> crc_o == '0
) else $error("FAIL: zero CRC with zero input should remain zero");

// COV1: Observe feedback XOR active
cov_feedback_active: cover property (
    @(posedge clk) disable iff (reset)
    data_valid && (crc_o[CRC_W-1] ^ data_bit)
);

// COV2: Observe init followed by data processing
cov_init_then_data: cover property (
    @(posedge clk) disable iff (reset)
    init ##1 data_valid
);

// COV3: Observe consecutive data bits
cov_consecutive_data: cover property (
    @(posedge clk) disable iff (reset)
    data_valid ##1 data_valid ##1 data_valid
);
