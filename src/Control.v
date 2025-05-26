// Control Unit for RISC-V CPU
module Control(
    input  [6:0] opcode,
    input        noop_in,    // results in nop
    output reg   RegWrite,   
    output reg   MemtoReg,   // sent to mux, decides to send either alu result or data memory output
    output reg   MemRead,    
    output reg   MemWrite,  
    output reg [1:0] ALUOp,  //gives alu control signal based on opcode, type of instruction
    output reg   ALUSrc,     // chooses between i and r alu source
    output reg   Branch_o    // branch or nah
);

always @(*) begin
    if (noop_in) begin
        RegWrite = 1'b0;
        MemtoReg = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUOp    = 2'b00; 
        ALUSrc   = 1'b0;
        Branch_o = 1'b0; 
    end else begin
        case (opcode)
            7'b0110011: begin // rtype
                RegWrite = 1'b1; 
                MemtoReg = 1'b0; 
                MemRead  = 1'b0; 
                MemWrite = 1'b0; 
                ALUOp    = 2'b10; 
                ALUSrc   = 1'b0; 
                Branch_o = 1'b0; 
            end
            7'b0010011: begin //itype
                RegWrite = 1'b1; 
                MemtoReg = 1'b0; 
                MemRead  = 1'b0; 
                MemWrite = 1'b0; 
                ALUOp    = 2'b10; 
                ALUSrc   = 1'b1; 
                Branch_o = 1'b0; 
            end
            7'b0000011: begin //lw
                RegWrite = 1'b1; 
                MemtoReg = 1'b1; 
                MemRead  = 1'b1; 
                MemWrite = 1'b0; 
                ALUOp    = 2'b00; 
                ALUSrc   = 1'b1; 
                Branch_o = 1'b0; 
            end
            7'b0100011: begin // sw
                RegWrite = 1'b0; 
                MemtoReg = 1'b0; 
                MemRead  = 1'b0; 
                MemWrite = 1'b1; 
                ALUOp    = 2'b00; 
                ALUSrc   = 1'b1; 
                Branch_o = 1'b0; 
            end
            7'b1100011: begin //beq
                RegWrite = 1'b0; 
                MemtoReg = 1'b0; 
                MemRead  = 1'b0; 
                MemWrite = 1'b0; 
                ALUOp    = 2'b01; 
                ALUSrc   = 1'b0; 
                Branch_o = 1'b1; 
            end
            default: begin    
                RegWrite = 1'b0;
                MemtoReg = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUOp    = 2'b00;
                ALUSrc   = 1'b0;
                Branch_o = 1'b0;
            end
        endcase
    end
end

endmodule
