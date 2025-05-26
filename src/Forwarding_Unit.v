module Forwarding_Unit (
    input  [4:0] ID_EX_Rs1,         
    input  [4:0] ID_EX_Rs2,         
    input  [4:0] EX_MEM_Rd,         
    input        EX_MEM_RegWrite,   
    input        MEM_WB_RegWrite,   
    input  [4:0] MEM_WB_Rd,

    output reg [1:0] ForwardA,      
    output reg [1:0] ForwardB      
);

 always @(*) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard - Forward from EX/MEM stage
        if (EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_Rs1)
            ForwardA = 2'b10;

        if (EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_Rs2)
            ForwardB = 2'b10;

        // MEM hazard - Forward from MEM/WB stage
        if (MEM_WB_RegWrite && MEM_WB_Rd != 0 &&
            !(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_Rs1) &&
            MEM_WB_Rd == ID_EX_Rs1)
            ForwardA = 2'b01;

        if (MEM_WB_RegWrite && MEM_WB_Rd != 0 &&
            !(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_Rs2) &&
            MEM_WB_Rd == ID_EX_Rs2)
            ForwardB = 2'b01;
    end

endmodule 