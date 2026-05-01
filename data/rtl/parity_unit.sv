// =============================================================================
// Module: parity_unit
// Description: Parameterized Parity Generator / Checker (purely combinational)
//   - Generates even or odd parity bit for WIDTH-bit input
//   - Also checks incoming data+parity and flags errors
//   - MODE: 0 = even parity, 1 = odd parity
// =============================================================================

module parity_unit #(
    parameter int WIDTH = 8,
    parameter bit MODE  = 1'b0   // 0 = even parity, 1 = odd parity
) (
    input  logic [WIDTH-1:0]  data_i,
    input  logic              parity_in,
    output logic              parity_gen,
    output logic              error_o
);

    logic raw_parity;

    assign raw_parity = ^data_i;  // XOR reduction = even parity

    generate
        if (MODE == 1'b0) begin : gen_even
            assign parity_gen = raw_parity;
            assign error_o    = raw_parity ^ parity_in;
        end else begin : gen_odd
            assign parity_gen = ~raw_parity;
            assign error_o    = ~(raw_parity ^ parity_in);
        end
    endgenerate

endmodule : parity_unit
