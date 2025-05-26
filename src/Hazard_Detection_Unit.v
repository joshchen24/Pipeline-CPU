module Hazard_Detection_Unit (
    input        ID_EX_MemRead, 
    input  [4:0] ID_EX_Rd,      
    input  [4:0] IF_ID_Rs1,     
    input  [4:0] IF_ID_Rs2,     

    output reg PCWrite,         
    output reg Stall_o,         
    output reg InsertNoOp       
);

always @(*) begin
    if (ID_EX_MemRead == 1'b1 && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin //hazard
        PCWrite    = 1'b0; 
        Stall_o    = 1'b1; 
        InsertNoOp = 1'b1; 
    end else begin // No hazard 
        PCWrite    = 1'b1; 
        Stall_o    = 1'b0; 
        InsertNoOp = 1'b0; 
    end
end

endmodule
