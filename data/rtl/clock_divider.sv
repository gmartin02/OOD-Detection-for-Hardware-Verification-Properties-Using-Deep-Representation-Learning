// =============================================================================
// Module: clock_divider
// Description: Parameterized Programmable Clock Divider
//   - Divides the input clock by a programmable divisor (2 to 2*MAX_DIV)
//   - Produces a 50% duty cycle output when divisor is even
//   - Synchronous active-high reset halts the output low
//   - div_val sets the half-period count (output toggles every div_val+1 cycles)
// =============================================================================

module clock_divider #(
    parameter int DIV_W   = 8,
    parameter int MAX_DIV = (1 << DIV_W) - 1
) (
    input  logic              clk,
    input  logic              reset,
    input  logic              enable,
    input  logic [DIV_W-1:0]  div_val,
    output logic              clk_out,
    output logic              tick         // Single-cycle pulse each toggle
);

    logic [DIV_W-1:0] counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= '0;
            clk_out <= 1'b0;
            tick    <= 1'b0;
        end else if (enable) begin
            if (counter >= div_val) begin
                counter <= '0;
                clk_out <= ~clk_out;
                tick    <= 1'b1;
            end else begin
                counter <= counter + 1;
                tick    <= 1'b0;
            end
        end else begin
            tick <= 1'b0;
        end
    end

endmodule : clock_divider
