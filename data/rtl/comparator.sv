// =============================================================================
// Module: comparator
// Description: Parameterized Magnitude Comparator (purely combinational)
//   - Compares two WIDTH-bit unsigned or signed values
//   - Produces one-hot status flags: equal, less-than, greater-than
//   - SIGNED parameter controls signed vs unsigned comparison
// =============================================================================

module comparator #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1'b0   // 0 = unsigned, 1 = signed
) (
    input  logic [WIDTH-1:0] a_i,
    input  logic [WIDTH-1:0] b_i,
    output logic             eq_o,
    output logic             lt_o,
    output logic             gt_o
);

    generate
        if (SIGNED) begin : gen_signed
            always_comb begin
                eq_o = ($signed(a_i) == $signed(b_i));
                lt_o = ($signed(a_i) <  $signed(b_i));
                gt_o = ($signed(a_i) >  $signed(b_i));
            end
        end else begin : gen_unsigned
            always_comb begin
                eq_o = (a_i == b_i);
                lt_o = (a_i <  b_i);
                gt_o = (a_i >  b_i);
            end
        end
    endgenerate

endmodule : comparator
