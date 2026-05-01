// =============================================================================
// Module: shift_register
// Description: Parameterized Multi-Mode Shift Register
//   - WIDTH bits wide, DEPTH stages deep
//   - Four operating modes (mode[1:0]):
//       2'b00  HOLD     — retain current value, no shift
//       2'b01  SHIFT_L  — shift left  (toward MSB); serial_in enters at bit 0
//       2'b10  SHIFT_R  — shift right (toward LSB); serial_in enters at MSB
//       2'b11  LOAD     — parallel load of data_in
//   - serial_out: the bit shifted out (MSB on left-shift, LSB on right-shift)
//   - Synchronous active-high reset clears all stages to 0
//   - Each "stage" is WIDTH bits; the chain is DEPTH stages long.
//     data_out reflects the final stage (oldest data after DEPTH shifts).
// =============================================================================

module shift_register #(
    parameter int WIDTH = 8,    // Bit width of each stage
    parameter int DEPTH = 4     // Number of pipeline stages
) (
    input  logic                clk,
    input  logic                reset,
    input  logic [1:0]          mode,        // Operating mode (see above)
    input  logic                serial_in,   // Serial input bit
    input  logic [WIDTH-1:0]    data_in,     // Parallel load data
    output logic [WIDTH-1:0]    data_out,    // Output of final stage
    output logic                serial_out   // Bit shifted out of final stage
);

    // Mode encoding
    localparam logic [1:0] HOLD    = 2'b00;
    localparam logic [1:0] SHIFT_L = 2'b01;
    localparam logic [1:0] SHIFT_R = 2'b10;
    localparam logic [1:0] LOAD    = 2'b11;

    // Stage array: stage[0] is the input end, stage[DEPTH-1] is the output end
    logic [WIDTH-1:0] stage [0:DEPTH-1];

    // --------------------------------------------------------------------
    // Stage 0: directly controlled by mode and inputs
    // --------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            stage[0] <= '0;
        end else begin
            case (mode)
                HOLD:    stage[0] <= stage[0];
                SHIFT_L: stage[0] <= {stage[0][WIDTH-2:0], serial_in};
                SHIFT_R: stage[0] <= {serial_in, stage[0][WIDTH-1:1]};
                LOAD:    stage[0] <= data_in;
                default: stage[0] <= stage[0];
            endcase
        end
    end

    // --------------------------------------------------------------------
    // Stages 1 through DEPTH-1: shift chain
    //   Each stage captures the previous stage's value on every clock,
    //   regardless of mode (the chain always flows; stage[0] is the source)
    // --------------------------------------------------------------------
    generate
        for (genvar i = 1; i < DEPTH; i++) begin : gen_chain
            always_ff @(posedge clk) begin
                if (reset) begin
                    stage[i] <= '0;
                end else begin
                    stage[i] <= stage[i-1];
                end
            end
        end
    endgenerate

    // --------------------------------------------------------------------
    // Outputs
    // --------------------------------------------------------------------
    assign data_out   = stage[DEPTH-1];

    // serial_out: the bit that "falls off" the end of the final stage
    //   On SHIFT_L: MSB of the last stage is shifted out
    //   On SHIFT_R: LSB of the last stage is shifted out
    //   Otherwise:  defined as 0 (no meaningful serial output)
    always_comb begin
        case (mode)
            SHIFT_L: serial_out = stage[DEPTH-1][WIDTH-1];
            SHIFT_R: serial_out = stage[DEPTH-1][0];
            default: serial_out = 1'b0;
        endcase
    end

    // =========================================================================
    // Formal Verification: SystemVerilog Assertions (SVA)
    // =========================================================================

endmodule