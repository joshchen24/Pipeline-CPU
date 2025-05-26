// Empty module for ID/EX pipeline register 

module ID_EX(
    input         clk,
    input         rst,
    
    input         RegWrite_in,
    input         MemtoReg_in,
    input         MemRead_in,
    input         MemWrite_in,
    input  [1:0]  ALUOp_in,
    input         ALUSrc_in,

    input  [31:0] rs1_data_in,
    input  [31:0] rs2_data_in,
    input  [31:0] imm_in,
    input  [2:0]  funct3_in,
    input  [6:0]  funct7_in,
    input  [4:0]  rs1_in, //address of rs1
    input  [4:0]  rs2_in, //address of rs2  
    input  [4:0]  rd_in, //address of rd (for forwarding)
    // Outputs
    output reg        RegWrite_out,
    output reg        MemtoReg_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg [1:0]  ALUOp_out,
    output reg        ALUSrc_out,

    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [2:0]  funct3_out,
    output reg [6:0]  funct7_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out
);

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        RegWrite_out <= 0;
        MemtoReg_out <= 0;
        MemRead_out  <= 0;
        MemWrite_out <= 0;
        ALUOp_out    <= 0;
        ALUSrc_out   <= 0;
        rs1_data_out <= 0;
        rs2_data_out <= 0;
        imm_out      <= 0;
        funct3_out   <= 0;
        funct7_out   <= 0;
        rs1_out      <= 0;
        rs2_out      <= 0;
        rd_out       <= 0;
    end else begin
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
        MemRead_out  <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        ALUOp_out    <= ALUOp_in;
        ALUSrc_out   <= ALUSrc_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        imm_out      <= imm_in;
        funct3_out   <= funct3_in;
        funct7_out   <= funct7_in;
        rs1_out      <= rs1_in;
        rs2_out      <= rs2_in;
        rd_out       <= rd_in;
    end
end

endmodule 