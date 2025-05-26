module IF_ID(
    input clk,
    input rst,
    input stall,
    input flush,
    input [31:0] instr_in,
    input [31:0] pc_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
);

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        instr_out <= 32'b0;
        pc_out    <= 32'b0;
    end else if (flush) begin
        instr_out <= 32'b0;
        pc_out    <= 32'b0;
    end else if (!stall) begin
        instr_out <= instr_in;
        pc_out    <= pc_in;
    end else begin
        //do nothing -> stall
    end
end

endmodule