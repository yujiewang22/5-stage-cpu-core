`include "defines.vh"

`default_nettype none

module exu_mul (
    input  wire signed [`RV32_DATA_WIDTH-1:0] i_src1,
    input  wire signed [`RV32_DATA_WIDTH-1:0] i_src2,
    input  wire 			                  i_src1_signed,
    input  wire 			                  i_src2_signed,
    input  wire 			                  i_sel_high,
    output wire        [`RV32_DATA_WIDTH-1:0] o_mul_dout
);

    // 通过在无符号数最高位添加一个0，从而共用有符号数乘法器
    wire signed [`RV32_DATA_WIDTH-1:0] src1        = i_src1;
    wire signed [`RV32_DATA_WIDTH-1:0] src2        = i_src2;
    wire signed [`RV32_DATA_WIDTH:0]   src1_unsign = {1'b0, i_src1};
    wire signed [`RV32_DATA_WIDTH:0]   src2_unsign = {1'b0, i_src2};

    // 由于位宽不匹配的问题不适合用同一个乘号，有很大优化的空间
    // 可以考虑用取反再符号选择等复杂方式实现优化
    reg  signed [`RV32_DOUBLE_DATA_WIDTH-1:0] res;
    wire signed [`RV32_DOUBLE_DATA_WIDTH-1:0] res_ss = i_src1 * i_src2;
    wire signed [`RV32_DOUBLE_DATA_WIDTH-1:0] res_su = i_src1 * src2_unsign;
    wire signed [`RV32_DOUBLE_DATA_WIDTH-1:0] res_us = src1_unsign * i_src2;
    wire signed [`RV32_DOUBLE_DATA_WIDTH-1:0] res_uu = src1_unsign * src2_unsign;

   assign o_mul_dout = i_sel_high ? res[`RV32_DATA_WIDTH+:`RV32_DATA_WIDTH] : res[`RV32_DATA_WIDTH-1:0];

    always @(*) begin
        case ({i_src1_signed, i_src2_signed})
            'd0: begin
                res = res_uu;
            end 
            'd1: begin
                res = res_us;                
            end 
            'd2: begin
                res = res_su;                
            end 
            'd3: begin
                res = res_ss;              
            end 
        endcase
    end
   
endmodule 

`default_nettype wire
