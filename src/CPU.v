module CPU(
    input clk_i,
    input rst_i,
    output wire [31:0] pc_o,
    output wire        stall_o,
    output wire        flush_o
);


    wire [31:0] pc_current;             
    wire [31:0] pc_next_val;            
    wire [31:0] pc_plus_4;              
    wire [31:0] branch_target_address;  
    wire        pc_mux_sel;             
    wire [31:0] instruction;            

    wire [31:0] if_id_pc_out;
    wire [31:0] if_id_instr_out;
    wire        if_id_flush_signal;     

    wire        ID_FlushIF;             
    assign      ID_FlushIF = if_id_flush_signal;

    wire [6:0]  opcode = if_id_instr_out[6:0];
    wire [2:0]  funct3 = if_id_instr_out[14:12];
    wire [6:0]  funct7 = if_id_instr_out[31:25];
    wire [4:0]  rs1_addr = if_id_instr_out[19:15];
    wire [4:0]  rs2_addr = if_id_instr_out[24:20];
    wire [4:0]  id_rd_addr = if_id_instr_out[11:7]; 

    wire [31:0] id_rs1_data;            
    wire [31:0] id_rs2_data;            
    wire [31:0] id_imm_out;             

    wire        ctrl_reg_write;
    wire        ctrl_mem_to_reg;
    wire        ctrl_mem_read;
    wire        ctrl_mem_write;
    wire [1:0]  ctrl_alu_op;
    wire        ctrl_alu_src;
    wire        ctrl_branch; 

    wire        id_registers_equal;
    wire        id_branch_taken_signal;

    wire        hzd_pc_write_enable;    
    wire        hzd_stall_signal;       
    wire        hzd_insert_noop_signal; 

    wire [31:0] id_ex_rs1_data_out;
    wire [31:0] id_ex_rs2_data_out;
    wire [31:0] id_ex_imm_out;
    wire [2:0]  id_ex_funct3_out;
    wire [6:0]  id_ex_funct7_out;
    wire [4:0]  id_ex_rs1_addr_out;
    wire [4:0]  id_ex_rs2_addr_out;
    wire [4:0]  id_ex_rd_addr_out;
    wire        id_ex_reg_write_out;
    wire        id_ex_mem_to_reg_out;
    wire        id_ex_mem_read_out;
    wire        id_ex_mem_write_out;
    wire [1:0]  id_ex_alu_op_out;
    wire        id_ex_alu_src_out;

    wire [1:0]  fwd_a_sel;              
    wire [1:0]  fwd_b_sel;              
    wire [31:0] ex_alu_operand_a;       
    wire [31:0] ex_alu_operand_b_src;   
    wire [31:0] ex_alu_operand_b;       
    wire [3:0]  ex_alu_control_out;     
    wire [31:0] ex_alu_result;          
    wire [31:0] ex_store_data_forwarded; 

    wire [31:0] ex_mem_alu_result_out;
    wire [31:0] ex_mem_rs2_data_out;    
    wire [4:0]  ex_mem_rd_addr_out;
    wire        ex_mem_reg_write_out;
    wire        ex_mem_mem_to_reg_out;
    wire        ex_mem_mem_read_out;
    wire        ex_mem_mem_write_out;

    wire [31:0] mem_data_memory_read_data; 

    wire [31:0] mem_wb_read_data_out;
    wire [31:0] mem_wb_alu_result_out;
    wire [4:0]  mem_wb_rd_addr_out;
    wire        mem_wb_reg_write_out;
    wire        mem_wb_mem_to_reg_out;

    wire [31:0] wb_write_back_data; 

    assign id_registers_equal = (id_rs1_data == id_rs2_data);
    assign id_branch_taken_signal = id_registers_equal && ctrl_branch;

    assign pc_mux_sel = id_branch_taken_signal;
    assign if_id_flush_signal = id_branch_taken_signal;

    PC PC ( 
        .rst_i     (rst_i),
        .clk_i     (clk_i),
        .PCWrite_i (hzd_pc_write_enable),
        .pc_i      (pc_next_val),
        .pc_o      (pc_current) 
    );

    Instruction_Memory Instruction_Memory (
        .addr_i  (pc_current),
        .instr_o (instruction)
    );

    Adder pc_plus_4_adder (
        .a   (pc_current),
        .b   (32'b100),
        .c   (pc_plus_4)
    );

    Adder branch_target_adder (
        .a   (if_id_pc_out),
        .b   (id_imm_out),
        .c   (branch_target_address)
    );

    MUX2to1 pc_select_mux (
        .a     (pc_plus_4),
        .b     (branch_target_address),
        .signal(pc_mux_sel),
        .out   (pc_next_val)
    );

    IF_ID if_id_reg (
        .clk       (clk_i),
        .rst       (rst_i),
        .stall     (hzd_stall_signal), 
        .flush     (if_id_flush_signal),
        .instr_in  (instruction),
        .pc_in     (pc_current), 
        .instr_out (if_id_instr_out),
        .pc_out    (if_id_pc_out)
    );

    Control Control (
        .opcode    (opcode),
        .noop_in   (hzd_insert_noop_signal),
        .RegWrite  (ctrl_reg_write),
        .MemtoReg  (ctrl_mem_to_reg),
        .MemRead   (ctrl_mem_read),
        .MemWrite  (ctrl_mem_write),
        .ALUOp     (ctrl_alu_op),
        .ALUSrc    (ctrl_alu_src),
        .Branch_o  (ctrl_branch) 
    );

    Registers Registers (
        .rst_i      (rst_i), 
        .clk_i      (clk_i),
        .RS1addr_i (rs1_addr),
        .RS2addr_i (rs2_addr),
        .RDaddr_i  (mem_wb_rd_addr_out),       
        .RDdata_i  (wb_write_back_data),       
        .RegWrite_i(mem_wb_reg_write_out),    
        .RS1data_o (id_rs1_data),
        .RS2data_o (id_rs2_data)
    );

    Imm_Gen imm_gen_unit (
        .inst (if_id_instr_out),
        .imm  (id_imm_out)
    );

    Hazard_Detection_Unit Hazard_Detection ( 
        .ID_EX_MemRead (id_ex_mem_read_out),    
        .ID_EX_Rd      (id_ex_rd_addr_out),   
        .IF_ID_Rs1     (rs1_addr),            
        .IF_ID_Rs2     (rs2_addr),            
        .PCWrite       (hzd_pc_write_enable),
        .Stall_o       (hzd_stall_signal), // Connect to Stall_o port of Hazard_Detection_Unit module
        .InsertNoOp    (hzd_insert_noop_signal)
    );

    ID_EX id_ex_reg (
        .clk        (clk_i),
        .rst        (rst_i),
        
        .RegWrite_in(ctrl_reg_write),
        .MemtoReg_in(ctrl_mem_to_reg),
        .MemRead_in (ctrl_mem_read),
        .MemWrite_in(ctrl_mem_write),
        .ALUOp_in   (ctrl_alu_op),
        .ALUSrc_in  (ctrl_alu_src),

        .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data),
        .imm_in     (id_imm_out),
        .funct3_in  (funct3),
        .funct7_in  (funct7),
        .rs1_in     (rs1_addr),
        .rs2_in     (rs2_addr),
        .rd_in      (id_rd_addr),

        .RegWrite_out (id_ex_reg_write_out),
        .MemtoReg_out (id_ex_mem_to_reg_out),
        .MemRead_out  (id_ex_mem_read_out),
        .MemWrite_out (id_ex_mem_write_out),
        .ALUOp_out    (id_ex_alu_op_out),
        .ALUSrc_out   (id_ex_alu_src_out),
        .rs1_data_out (id_ex_rs1_data_out),
        .rs2_data_out (id_ex_rs2_data_out),
        .imm_out      (id_ex_imm_out),
        .funct3_out   (id_ex_funct3_out),
        .funct7_out   (id_ex_funct7_out),
        .rs1_out      (id_ex_rs1_addr_out),
        .rs2_out      (id_ex_rs2_addr_out),
        .rd_out       (id_ex_rd_addr_out)
    );

    Forwarding_Unit forwarding_unit (
        .ID_EX_Rs1       (id_ex_rs1_addr_out), 
        .ID_EX_Rs2       (id_ex_rs2_addr_out), 
        .EX_MEM_Rd       (ex_mem_rd_addr_out),   
        .EX_MEM_RegWrite (ex_mem_reg_write_out),
        .MEM_WB_Rd       (mem_wb_rd_addr_out),   
        .MEM_WB_RegWrite (mem_wb_reg_write_out),
        .ForwardA        (fwd_a_sel),
        .ForwardB        (fwd_b_sel)
    );

    MUX4to1 alu_mux_a (
        .a     (id_ex_rs1_data_out),        
        .b     (wb_write_back_data),        
        .c     (ex_mem_alu_result_out),     
        .signal(fwd_a_sel),
        .out   (ex_alu_operand_a)
    );

    MUX2to1 alu_operand_b_source_mux (
        .a     (ex_alu_operand_b_src),//ex_alu_operand_b_src
        .b     (id_ex_imm_out),
        .signal(id_ex_alu_src_out),
        .out   (ex_alu_operand_b)//ex_alu_operand_b
    );

    MUX4to1 alu_mux_b (
        .a     (id_ex_rs2_data_out),  //id_ex_rs2_data_out
        .b     (wb_write_back_data),        
        .c     (ex_mem_alu_result_out),     
        .signal(fwd_b_sel),
        .out   (ex_alu_operand_b_src) //ex_alu_operand_b_src
    );

    MUX4to1 store_data_mux (
        .a     (id_ex_rs2_data_out),      
        .b     (wb_write_back_data),      
        .c     (ex_mem_alu_result_out),   
        .signal(fwd_b_sel),
        .out   (ex_store_data_forwarded)
    );

    ALU_Control alu_control_unit (
        .ALUOp  (id_ex_alu_op_out),
        .funct3 (id_ex_funct3_out),
        .funct7 (id_ex_funct7_out),
        .out    (ex_alu_control_out)
    );

    ALU main_alu (
        .a        (ex_alu_operand_a),
        .b        (ex_alu_operand_b),
        .control  (ex_alu_control_out),
        .result   (ex_alu_result)
    );

    EX_MEM ex_mem_reg (
        .clk             (clk_i),
        .rst             (rst_i),
        .RegWrite_in     (id_ex_reg_write_out),
        .MemtoReg_in     (id_ex_mem_to_reg_out),
        .MemRead_in      (id_ex_mem_read_out),
        .MemWrite_in     (id_ex_mem_write_out),
        .alu_result_in   (ex_alu_result),
        .rs2_data_in     (ex_store_data_forwarded),   
        .rd_in           (id_ex_rd_addr_out),

        .RegWrite_out    (ex_mem_reg_write_out),
        .MemtoReg_out    (ex_mem_mem_to_reg_out),
        .MemRead_out     (ex_mem_mem_read_out),
        .MemWrite_out    (ex_mem_mem_write_out),
        .alu_result_out  (ex_mem_alu_result_out),
        .rs2_data_out    (ex_mem_rs2_data_out),
        .rd_out          (ex_mem_rd_addr_out)
    );

    Data_Memory Data_Memory (
        .clk_i      (clk_i),
        .addr_i     (ex_mem_alu_result_out),
        .MemRead_i  (ex_mem_mem_read_out),
        .MemWrite_i (ex_mem_mem_write_out),
        .data_i     (ex_mem_rs2_data_out),       
        .data_o     (mem_data_memory_read_data) 
    );

    MEM_WB mem_wb_reg (
        .clk            (clk_i),
        .rst            (rst_i),
        .RegWrite_in    (ex_mem_reg_write_out),
        .MemtoReg_in    (ex_mem_mem_to_reg_out),
        .read_data_in   (mem_data_memory_read_data),
        .alu_result_in  (ex_mem_alu_result_out),
        .rd_in          (ex_mem_rd_addr_out),

        .RegWrite_out   (mem_wb_reg_write_out),
        .MemtoReg_out   (mem_wb_mem_to_reg_out),
        .read_data_out  (mem_wb_read_data_out),
        .alu_result_out (mem_wb_alu_result_out),
        .rd_out         (mem_wb_rd_addr_out)
    );

    MUX2to1 write_back_data_mux (
        .a     (mem_wb_alu_result_out),
        .b     (mem_wb_read_data_out),
        .signal(mem_wb_mem_to_reg_out),
        .out   (wb_write_back_data)
    );

    assign pc_o = pc_current;
    assign stall_o = hzd_stall_signal; 
    assign flush_o = if_id_flush_signal;

endmodule
