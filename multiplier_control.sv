module multiplier_control (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic multiplier_lsb,
    output logic load,
    output logic product_wr,
    output logic shift_en,
    output logic done
);

    typedef enum logic [2:0] {
        IDLE      = 3'b000,
        LOAD      = 3'b001,
        CHECK_BIT = 3'b010,
        ADD       = 3'b011,
        SHIFT     = 3'b100,
        DONE      = 3'b101
    } state_t;

    state_t state, next_state;
    logic [5:0] count;

    // Contador de 32 iterações
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= '0;
        else if (state == LOAD) count <= '0;
        else if (state == SHIFT) count <= count + 1;
    end

    // Transição de Estados
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:      if (start) next_state = LOAD;
            LOAD:      next_state = CHECK_BIT;
            CHECK_BIT: next_state = (multiplier_lsb) ? ADD : SHIFT;
            ADD:       next_state = SHIFT;
            SHIFT:     next_state = (count == 6'd31) ? DONE : CHECK_BIT;
            DONE:      if (!start) next_state = IDLE;
            default:   next_state = IDLE;
        endcase
    end

    // Sinais de Saída
    assign load       = (state == LOAD);
    assign product_wr = (state == ADD);
    assign shift_en   = (state == SHIFT);
    assign done       = (state == DONE);

endmodule
