// =============================================================================
// Module: pulse_stretcher
// Description: Parameterized Pulse Stretcher
//   - Extends a single-cycle input pulse to DURATION cycles on the output
//   - If a new pulse arrives while stretching, the counter resets (retriggerable)
//   - Synchronous active-high reset clears output immediately
//   - busy_o indicates the stretcher is actively holding the output high
// =============================================================================

module pulse_stretcher #(
    parameter int DURATION = 8,
    parameter int CNT_W    = $clog2(DURATION + 1)
) (
    input  logic  clk,
    input  logic  reset,
    input  logic  pulse_i,
    output logic  stretched_o,
    output logic  busy_o
);

    logic [CNT_W-1:0] counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= '0;
        end else if (pulse_i) begin
            counter <= DURATION[CNT_W-1:0];
        end else if (counter > '0) begin
            counter <= counter - 1;
        end
    end

    assign stretched_o = (counter > '0);
    assign busy_o      = (counter > '0);

endmodule : pulse_stretcher
