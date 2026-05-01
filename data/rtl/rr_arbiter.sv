// =============================================================================
// Module: rr_arbiter
// Description: Parameterized N-way Round-Robin Arbiter
//   - Grants exactly one requester per cycle (or none if no requests)
//   - Uses a rotating priority pointer updated after each grant
//   - One-hot grant output; only active when req != 0
//   - Synchronous active-high reset
// =============================================================================

module rr_arbiter #(
    parameter int N = 4  // Number of requestors
) (
    input  logic         clk,
    input  logic         reset,
    input  logic [N-1:0] req,       // Request vector (active-high)
    output logic [N-1:0] grant      // One-hot grant output
);

    // Priority pointer: index of the next candidate to consider first
    logic [$clog2(N)-1:0] priority_ptr;

    // --------------------------------------------------------------------
    // Combinational grant logic
    //   Rotate through req starting at priority_ptr; grant the first set bit
    // --------------------------------------------------------------------
    always_comb begin
        grant = '0;
        for (int i = 0; i < N; i++) begin
            // Compute rotated index
            automatic int idx = (priority_ptr + i) % N;
            if (req[idx] && (grant == '0)) begin
                grant[idx] = 1'b1;
            end
        end
    end

    // --------------------------------------------------------------------
    // Sequential priority update
    //   Advance pointer past the currently granted slot after each grant
    // --------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            priority_ptr <= '0;
        end else if (grant != '0) begin
            // Find the index of the grant and advance pointer by 1
            for (int i = 0; i < N; i++) begin
                if (grant[i]) begin
                    priority_ptr <= (i + 1) % N;
                end
            end
        end
    end

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule