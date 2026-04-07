module alu_32 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum,
    output logic        carry_out
);
    // Na versão refinada, somamos apenas 32 bits por vez
    assign {carry_out, sum} = a + b;
endmodule
