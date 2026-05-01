// =============================================================================
// Module: fsm_controller
// Description: 5-state FSM Controller — Sequenced Operation Engine
//
//   States:
//     IDLE     → Waiting for start signal
//     INIT     → One-cycle initialization phase
//     PROCESS  → Multi-cycle processing loop (counts down from PROC_CYCLES)
//     VERIFY   → One-cycle result verification
//     DONE     → Terminal state; asserts done; held until reset or restart
//
//   Transitions:
//     IDLE    → INIT     (when start asserted)
//     INIT    → PROCESS  (unconditional, next cycle)
//     PROCESS → VERIFY   (when cycle counter reaches 0)
//     PROCESS → PROCESS  (loop: while counter > 0)
//     VERIFY  → DONE     (when verify_ok asserted)
//     VERIFY  → INIT     (when verify_ok not asserted; retry)
//     DONE    → IDLE     (when restart asserted, else stays DONE)
//
//   Outputs:
//     busy     — high in INIT, PROCESS, VERIFY
//     done     — high in DONE state
//     init_en  — high in INIT state
//     proc_en  — high in PROCESS state
//     verify_en— high in VERIFY state
// =============================================================================

module fsm_controller #(
    parameter int PROC_CYCLES = 4   // Number of PROCESS cycles before VERIFY
) (
    input  logic clk,
    input  logic reset,
    input  logic start,       // Pulse to begin operation
    input  logic verify_ok,   // External verification result (used in VERIFY)
    input  logic restart,     // In DONE state: return to IDLE for new operation
    output logic busy,        // Asserted while operation is in progress
    output logic done,        // Asserted when operation completed successfully
    output logic init_en,     // Control signal active during INIT
    output logic proc_en,     // Control signal active during PROCESS
    output logic verify_en    // Control signal active during VERIFY
);

    // State encoding
    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        INIT    = 3'b001,
        PROCESS = 3'b010,
        VERIFY  = 3'b011,
        DONE    = 3'b100
    } state_t;

    state_t state, next_state;

    // Cycle counter for PROCESS loop
    logic [$clog2(PROC_CYCLES+1)-1:0] proc_cnt;

    // --------------------------------------------------------------------
    // State register with synchronous reset
    // --------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            state    <= IDLE;
            proc_cnt <= '0;
        end else begin
            state <= next_state;

            // Counter management
            case (state)
                INIT:    proc_cnt <= PROC_CYCLES[$clog2(PROC_CYCLES+1)'(PROC_CYCLES)];
                PROCESS: proc_cnt <= proc_cnt - 1'b1;
                default: proc_cnt <= proc_cnt;
            endcase
        end
    end

    // --------------------------------------------------------------------
    // Next-state combinational logic
    // --------------------------------------------------------------------
    always_comb begin
        next_state = state; // Default: stay

        case (state)
            IDLE:    next_state = start     ? INIT    : IDLE;
            INIT:    next_state = PROCESS;
            PROCESS: next_state = (proc_cnt == '0) ? VERIFY  : PROCESS;
            VERIFY:  next_state = verify_ok ? DONE    : INIT;   // Retry if not OK
            DONE:    next_state = restart   ? IDLE    : DONE;
            default: next_state = IDLE;
        endcase
    end

    // --------------------------------------------------------------------
    // Output logic (Moore machine)
    // --------------------------------------------------------------------
    always_comb begin
        busy      = (state == INIT) || (state == PROCESS) || (state == VERIFY);
        done      = (state == DONE);
        init_en   = (state == INIT);
        proc_en   = (state == PROCESS);
        verify_en = (state == VERIFY);
    end

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule