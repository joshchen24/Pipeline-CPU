module MUX4to1 (
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    input [1:0] signal,
    output [31:0] out
); 

assign out = (signal == 2'b00) ? a :
             (signal == 2'b01) ? b :
             (signal == 2'b10) ? c :
             (signal == 2'b11) ? d :
             0;
             
endmodule