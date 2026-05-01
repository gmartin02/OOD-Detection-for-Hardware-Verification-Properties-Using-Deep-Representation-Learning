// =============================================================================
// Module: updown_counter
// Description: Parameterized Up/Down Saturating Counter
//   - WIDTH-bit counter with synchronous active-high reset
//   - Supports increment, decrement, load, and hold operations
//   - Saturates at MAX_VAL (no wrap on increment) and 0 (no wrap on decrement)
//   - op: 2'b00 = hold, 2'b01 = increment, 2'b10 = decrement, 2'b11 = load
// =============================================================================

module updown_counter #(
    parameter int WIDTH   = 8,
    parameter int MAX_VAL = (1 << WIDTH) - 1
) (
    input  logic               clk,
    input  logic               reset,
    input  logic [1:0]         op,
    input  logic [WIDTH-1:0]   load_val,
    output logic [WIDTH-1:0]   count,
    output logic               at_max,
    output logic               at_zero
);

    localparam logic [1:0] OP_HOLD = 2'b00;
    localparam logic [1:0] OP_INC  = 2'b01;
    localparam logic [1:0] OP_DEC  = 2'b10;
    localparam logic [1:0] OP_LOAD = 2'b11;

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= '0;
        end else begin
            case (op)
                OP_HOLD: count <= count;
                OP_INC:  count <= (count < MAX_VAL[WIDTH-1:0]) ? count + 1 : count;
                OP_DEC:  count <= (count > '0) ? count - 1 : count;
                OP_LOAD: count <= load_val;
            endcase
        end
    end

    assign at_max  = (count == MAX_VAL[WIDTH-1:0]);
    assign at_zero = (count == '0);

endmodule : updown_counter
