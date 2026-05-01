// =============================================================================
// Module: barrel_shifter
// Description: Parameterized Barrel Shifter (purely combinational)
//   - WIDTH-bit data, $clog2(WIDTH)-bit shift amount
//   - Supports left shift, right logical shift, and right arithmetic shift
//   - mode: 2'b00 = left, 2'b01 = right logical, 2'b10 = right arithmetic
//   - Shift amount wraps modulo WIDTH
// =============================================================================

module barrel_shifter #(
    parameter int WIDTH   = 32,
    parameter int SHIFT_W = $clog2(WIDTH)
) (
    input  logic [WIDTH-1:0]   data_i,
    input  logic [SHIFT_W-1:0] shamt_i,
    input  logic [1:0]         mode_i,
    output logic [WIDTH-1:0]   result_o
);

    localparam logic [1:0] MODE_SLL = 2'b00;  // Shift Left Logical
    localparam logic [1:0] MODE_SRL = 2'b01;  // Shift Right Logical
    localparam logic [1:0] MODE_SRA = 2'b10;  // Shift Right Arithmetic

    always_comb begin
        case (mode_i)
            MODE_SLL: result_o = data_i << shamt_i;
            MODE_SRL: result_o = data_i >> shamt_i;
            MODE_SRA: result_o = $signed(data_i) >>> shamt_i;
            default:  result_o = data_i;
        endcase
    end

endmodule : barrel_shifter
