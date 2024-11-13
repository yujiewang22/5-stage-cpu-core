`include "defines.vh"

`default_nettype none

// RIB SystemBus
// 4 master, 4 slave
module rib (
    output reg  [`BUS_MASTER_NUM-1:0]  o_bus_halt,   
    // master 0 interface
    input  wire                        i_m0_vld, 
    input  wire [`RV32_ADDR_WIDTH-1:0] i_m0_addr,     
    output reg  [`RV32_DATA_WIDTH-1:0] o_m0_rd_data,  
    input  wire                        i_m0_wr_en,   
    input  wire [`RV32_DATA_WIDTH-1:0] i_m0_wr_data,                                          
    // master 1 interface
    input  wire                        i_m1_vld, 
    input  wire [`RV32_ADDR_WIDTH-1:0] i_m1_addr,     
    output reg  [`RV32_DATA_WIDTH-1:0] o_m1_rd_data,  
    input  wire                        i_m1_wr_en,   
    input  wire [`RV32_DATA_WIDTH-1:0] i_m1_wr_data,                    
    // master 2 interface
    input  wire                        i_m2_vld, 
    input  wire [`RV32_ADDR_WIDTH-1:0] i_m2_addr,     
    output reg  [`RV32_DATA_WIDTH-1:0] o_m2_rd_data,  
    input  wire                        i_m2_wr_en,   
    input  wire [`RV32_DATA_WIDTH-1:0] i_m2_wr_data,                     
    // master 3 interface
    input  wire                        i_m3_vld, 
    input  wire [`RV32_ADDR_WIDTH-1:0] i_m3_addr,     
    output reg  [`RV32_DATA_WIDTH-1:0] o_m3_rd_data,  
    input  wire                        i_m3_wr_en,   
    input  wire [`RV32_DATA_WIDTH-1:0] i_m3_wr_data,                      
    // slave 0 interface
    output reg  [`RV32_ADDR_WIDTH-1:0] o_s0_addr,     
    input  wire [`RV32_DATA_WIDTH-1:0] i_s0_rd_data, 
    output reg                         o_s0_wr_en,   
    output reg  [`RV32_DATA_WIDTH-1:0] o_s0_wr_data,                          
    // slave 1 interface
    output reg  [`RV32_ADDR_WIDTH-1:0] o_s1_addr,     
    input  wire [`RV32_DATA_WIDTH-1:0] i_s1_rd_data, 
    output reg                         o_s1_wr_en,   
    output reg  [`RV32_DATA_WIDTH-1:0] o_s1_wr_data,                   
    // slave 2 interface
    output reg  [`RV32_ADDR_WIDTH-1:0] o_s2_addr,     
    input  wire [`RV32_DATA_WIDTH-1:0] i_s2_rd_data, 
    output reg                         o_s2_wr_en,   
    output reg  [`RV32_DATA_WIDTH-1:0] o_s2_wr_data,                     
    // slave 3 interface
    output reg  [`RV32_ADDR_WIDTH-1:0] o_s3_addr,     
    input  wire [`RV32_DATA_WIDTH-1:0] i_s3_rd_data, 
    output reg                         o_s3_wr_en,   
    output reg  [`RV32_DATA_WIDTH-1:0] o_s3_wr_data                            
);

    // 32位地址访问4个从设备
    // 访问地址的最高2位决定要访问的是哪一个从设备
    // 每个从设备的地址空间为30位

    localparam [`BUS_MASTER_WIDTH-1:0] M0_RDY = 2'd0;
    localparam [`BUS_MASTER_WIDTH-1:0] M1_RDY = 2'd1;
    localparam [`BUS_MASTER_WIDTH-1:0] M2_RDY = 2'd2;
    localparam [`BUS_MASTER_WIDTH-1:0] M3_RDY = 2'd3;

    localparam [1:0] S_ADDR_0 = 2'd0;
    localparam [1:0] S_ADDR_1 = 2'd1;
    localparam [1:0] S_ADDR_2 = 2'd2;
    localparam [1:0] S_ADDR_3 = 2'd3;

    wire [`BUS_MASTER_NUM-1:0]   vld;
    reg  [`BUS_MASTER_WIDTH-1:0] rdy;

    wire [1:0] m0_s_addr;
    wire [1:0] m1_s_addr;
    wire [1:0] m2_s_addr;
    wire [1:0] m3_s_addr;

    assign vld = {i_m3_vld, i_m2_vld, i_m1_vld, i_m0_vld};

    assign m0_s_addr = i_m0_addr[`RV32_ADDR_WIDTH-1:30];
    assign m1_s_addr = i_m1_addr[`RV32_ADDR_WIDTH-1:30];
    assign m2_s_addr = i_m2_addr[`RV32_ADDR_WIDTH-1:30];
    assign m3_s_addr = i_m3_addr[`RV32_ADDR_WIDTH-1:30];

    // 固定优先级仲裁
    // 优先级由高到低：m3，m2，m1, m0
    always @ (*) begin
        if (vld[3]) begin
            rdy        = M3_RDY;
            o_bus_halt = vld & 4'b0111;
        end else if (vld[2]) begin
            rdy        = M2_RDY;
            o_bus_halt = vld & 4'b0011;
        end else if (vld[1]) begin
            rdy        = M1_RDY;
            o_bus_halt = vld & 4'b0001;
        end else begin
            // 没有同时访问冲突，则不需要暂停流水线
            rdy        = M0_RDY;
            o_bus_halt = vld & 4'b0000;
        end
    end

    always @ (*) begin

        o_s0_addr    = 'd0;
        o_s1_addr    = 'd0;
        o_s2_addr    = 'd0;
        o_s3_addr    = 'd0;
        o_m0_rd_data = 'd0;
        o_m1_rd_data = 'd0;
        o_m2_rd_data = 'd0;
        o_m3_rd_data = 'd0;
        o_s0_wr_en   = 'd0;
        o_s1_wr_en   = 'd0;
        o_s2_wr_en   = 'd0;
        o_s3_wr_en   = 'd0;
        o_s0_wr_data = 'd0;
        o_s1_wr_data = 'd0;
        o_s2_wr_data = 'd0;
        o_s3_wr_data = 'd0;

        case (rdy)
            M0_RDY: begin
                case (m0_s_addr)
                    S_ADDR_0: begin
                        o_s0_addr    = {2'd0, i_m0_addr[29:0]};
                        o_m0_rd_data = i_s0_rd_data;
                        o_s0_wr_en   = i_m0_wr_en;
                        o_s0_wr_data = i_m0_wr_data;
                    end
                    S_ADDR_1: begin
                        o_s1_addr    = {2'd0, i_m0_addr[29:0]};
                        o_m0_rd_data = i_s1_rd_data;
                        o_s1_wr_en   = i_m0_wr_en;
                        o_s1_wr_data = i_m0_wr_data;
                    end
                    S_ADDR_2: begin
                        o_s2_addr    = {2'd0, i_m0_addr[29:0]};
                        o_m0_rd_data = i_s2_rd_data;
                        o_s2_wr_en   = i_m0_wr_en;
                        o_s2_wr_data = i_m0_wr_data;
                    end
                    S_ADDR_3: begin
                        o_s3_addr    = {2'd0, i_m0_addr[29:0]};
                        o_m0_rd_data = i_s3_rd_data;
                        o_s3_wr_en   = i_m0_wr_en;
                        o_s3_wr_data = i_m0_wr_data;
                    end
                endcase
            end
            M1_RDY: begin
                case (m1_s_addr)
                    S_ADDR_0: begin
                        o_s0_addr    = {2'd0, i_m1_addr[29:0]};
                        o_m1_rd_data = i_s0_rd_data;
                        o_s0_wr_en   = i_m1_wr_en;
                        o_s0_wr_data = i_m1_wr_data;
                    end
                    S_ADDR_1: begin
                        o_s1_addr    = {2'd0, i_m1_addr[29:0]};
                        o_m1_rd_data = i_s1_rd_data;
                        o_s1_wr_en   = i_m1_wr_en;
                        o_s1_wr_data = i_m1_wr_data;
                    end
                    S_ADDR_2: begin
                        o_s2_addr    = {2'd0, i_m1_addr[29:0]};
                        o_m1_rd_data = i_s2_rd_data;
                        o_s2_wr_en   = i_m1_wr_en;
                        o_s2_wr_data = i_m1_wr_data;
                    end
                    S_ADDR_3: begin
                        o_s3_addr    = {2'd0, i_m1_addr[29:0]};
                        o_m1_rd_data = i_s3_rd_data;
                        o_s3_wr_en   = i_m1_wr_en;
                        o_s3_wr_data = i_m1_wr_data;
                    end
                endcase
            end
            M2_RDY: begin
                case (m2_s_addr)
                    S_ADDR_0: begin
                        o_s0_addr    = {2'd0, i_m2_addr[29:0]};
                        o_m2_rd_data = i_s0_rd_data;
                        o_s0_wr_en   = i_m2_wr_en;
                        o_s0_wr_data = i_m2_wr_data;
                    end
                    S_ADDR_1: begin
                        o_s1_addr    = {2'd0, i_m2_addr[29:0]};
                        o_m2_rd_data = i_s1_rd_data;
                        o_s1_wr_en   = i_m2_wr_en;
                        o_s1_wr_data = i_m2_wr_data;
                    end
                    S_ADDR_2: begin
                        o_s2_addr    = {2'd0, i_m2_addr[29:0]};
                        o_m2_rd_data = i_s2_rd_data;
                        o_s2_wr_en   = i_m2_wr_en;
                        o_s2_wr_data = i_m2_wr_data;
                    end
                    S_ADDR_3: begin
                        o_s3_addr    = {2'd0, i_m2_addr[29:0]};
                        o_m2_rd_data = i_s3_rd_data;
                        o_s3_wr_en   = i_m2_wr_en;
                        o_s3_wr_data = i_m2_wr_data;
                    end
                endcase
            end
            M3_RDY: begin
                case (m3_s_addr)
                    S_ADDR_0: begin
                        o_s0_addr    = {2'd0, i_m3_addr[29:0]};
                        o_m3_rd_data = i_s0_rd_data;
                        o_s0_wr_en   = i_m3_wr_en;
                        o_s0_wr_data = i_m3_wr_data;
                    end
                    S_ADDR_1: begin
                        o_s1_addr    = {2'd0, i_m3_addr[29:0]};
                        o_m3_rd_data = i_s1_rd_data;
                        o_s1_wr_en   = i_m3_wr_en;
                        o_s1_wr_data = i_m3_wr_data;
                    end
                    S_ADDR_2: begin
                        o_s2_addr    = {2'd0, i_m3_addr[29:0]};
                        o_m3_rd_data = i_s2_rd_data;
                        o_s2_wr_en   = i_m3_wr_en;
                        o_s2_wr_data = i_m3_wr_data;
                    end
                    S_ADDR_3: begin
                        o_s3_addr    = {2'd0, i_m3_addr[29:0]};
                        o_m3_rd_data = i_s3_rd_data;
                        o_s3_wr_en   = i_m3_wr_en;
                        o_s3_wr_data = i_m3_wr_data;
                    end
                endcase
            end
        endcase
    end

endmodule

`default_nettype wire
