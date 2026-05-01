// =============================================================================
// Module: watchdog_timer
// Description: Parameterized Watchdog Timer
//   - Counts down from a configurable timeout value
//   - Must be periodically "kicked" (pet) to reset the counter
//   - If counter reaches zero without a kick, timeout flag is asserted
//   - Synchronous active-high reset clears the counter and loads timeout
//   - Once timed out, stays asserted until reset or kick
// =============================================================================

module watchdog_timer #(
    parameter int WIDTH   = 16,
    parameter int TIMEOUT = (1 << WIDTH) - 1
) (
    input  logic              clk,
    input  logic              reset,
    input  logic              kick,        // Reset counter to TIMEOUT
    input  logic              enable,      // Counter only decrements when enabled
    output logic [WIDTH-1:0]  counter,
    output logic              timeout,
    output logic              running
);

    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= TIMEOUT[WIDTH-1:0];
            timeout <= 1'b0;
        end else if (kick) begin
            counter <= TIMEOUT[WIDTH-1:0];
            timeout <= 1'b0;
        end else if (enable && !timeout) begin
            if (counter == '0) begin
                timeout <= 1'b1;
            end else begin
                counter <= counter - 1;
            end
        end
    end

    assign running = enable && !timeout && (counter > '0);

endmodule : watchdog_timer
