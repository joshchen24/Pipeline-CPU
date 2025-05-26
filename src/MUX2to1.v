module MUX2to1 (
    input [31:0] a,
    input [31:0] b,
    input signal,
    output [31:0] out
);

assign out = (signal == 1'b0) ? a :
             (signal == 1'b1) ? b :
             0;
             
endmodule