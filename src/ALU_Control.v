module ALU_Control(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] out 
);

always @(*) begin
    case (ALUOp)
        2'b00: out = 4'b0011; // lw, sw: add
        2'b01: out = 4'b0100; // beq: sub
        2'b10: begin 
            if      (funct3 == 3'b111 && funct7 == 7'b0000000) out = 4'b0000; // and
            else if (funct3 == 3'b100 && funct7 == 7'b0000000) out = 4'b0001; // xor
            else if (funct3 == 3'b001 && funct7 == 7'b0000000) out = 4'b0010; // sll
            else if (funct3 == 3'b000 && funct7 == 7'b0000000) out = 4'b0011; // add
            else if (funct3 == 3'b000 && funct7 == 7'b0100000) out = 4'b0100; // sub
            else if (funct3 == 3'b000 && funct7 == 7'b0000001) out = 4'b0101; // mul
            else if (funct3 == 3'b000) out = 4'b0011; // addi 
            else if (funct3 == 3'b101) out = 4'b0110; // srai
            else out = 4'b1111; 
        end
        default: out = 4'b1111; 
    endcase
end

endmodule 