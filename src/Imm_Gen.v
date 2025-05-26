module Imm_Gen (
    input [31:0] inst,
    output reg [31:0] imm
);

wire [6:0] opcode = inst[6:0];
wire [2:0] funct3 = inst[14:12];
wire [6:0] funct7 = inst[31:25];

always @(*) begin
    case (opcode)
        7'b0010011: begin // itype
            if (funct3 == 3'b101 && funct7 == 7'b0100000) // srai
                imm = {27'b0, inst[24:20]}; 
            else
                imm = {{20{inst[31]}}, inst[31:20]}; // addi
        end
        7'b0000011: // lw
            imm = {{20{inst[31]}}, inst[31:20]};
        7'b0100011: // sw
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        7'b1100011: // beq
            imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
        default:
            imm = 32'b0;
    endcase
end

endmodule
