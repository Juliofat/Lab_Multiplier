module multiplier_datapath (
    input  logic        clk, rst_n,
    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,
    input  logic        load, product_wr, shift_en,
    output logic        multiplier_lsb,
    output logic [63:0] product
);
    logic [31:0] multiplicand_reg;
    logic [63:0] product_reg;
    logic [31:0] alu_sum;
    logic        carry;

    alu_32 alu (
        .a   (product_reg[63:32]),
        .b   (multiplicand_reg),
        .sum (alu_sum),
        .carry_out (carry)
    );

    assign multiplier_lsb = product_reg[0];
    assign product        = product_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product_reg <= '0;
            multiplicand_reg <= '0;
        end else if (load) begin
            multiplicand_reg <= multiplicand_in;
            product_reg      <= {32'b0, multiplier_in}; // Multiplicador na metade de baixo
        end else begin
            if (product_wr)
                product_reg[63:32] <= alu_sum; // Note: carregar carry se necessário
            
            if (shift_en)
                product_reg <= {carry, product_reg[63:1]}; // Shift Right Unificado
        end
    end
endmodule
