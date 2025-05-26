module ALU(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  control,
    output reg [31:0] result
);


always @(*) begin
    case (control)
        4'b0000: result = a & b; // and
        4'b0001: result = a ^ b; // xor
        4'b0010: result = a << b; // sll 
        4'b0011: result = a + b; // add/addi/lw/sw
        4'b0100: result = a - b; // sub/beq
        4'b0101: result = a * b; // mul
        4'b0110: result = a >>> b; // srai
        default: result = 32'b0;
    endcase
end

endmodule