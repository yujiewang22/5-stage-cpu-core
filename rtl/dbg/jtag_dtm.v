`include "defines.vh"

`default_nettype none

module jtag_dtm (
    // 非标准复位信号，高电平有效
    input  wire                  i_jtag_rst,
    // jtag四线                 
    input  wire                  jtag_TCK,
    input  wire                  jtag_TMS,
    input  wire                  jtag_TDI,
    output reg                   jtag_TDO,
    // 发送握手
    output wire                  o_dtm_req_vld,
    output wire [`DMI_WIDTH-1:0] o_dtm_req_data,
    input  wire                  i_dtm_req_rdy,
    // 反馈握手
    input  wire                  i_dtm_resp_vld,
    input  wire [`DMI_WIDTH-1:0] i_dtm_resp_data,
    output wire                  o_dtm_resp_rdy
);

    localparam IR_WIDTH                = 5;
    localparam DR_WIDTH                = 32;
    localparam SHIFT_REG_WIDTH         = `DMI_WIDTH;

    localparam TAP_STATE_WIDTH         = 4; 
    localparam STATE_TEST_LOGIC_RESET  = 4'h0;
    localparam STATE_RUN_TEST_IDLE     = 4'h1;
    localparam STATE_SELECT_DR_SCAN    = 4'h2;
    localparam STATE_CAPTURE_DR        = 4'h3;
    localparam STATE_SHIFT_DR          = 4'h4;
    localparam STATE_EXIT1_DR          = 4'h5;
    localparam STATE_PAUSE_DR          = 4'h6;
    localparam STATE_EXIT2_DR          = 4'h7;
    localparam STATE_UPDATE_DR         = 4'h8;
    localparam STATE_SELECT_IR_SCAN    = 4'h9;
    localparam STATE_CAPTURE_IR        = 4'hA;
    localparam STATE_SHIFT_IR          = 4'hB;
    localparam STATE_EXIT1_IR          = 4'hC;
    localparam STATE_PAUSE_IR          = 4'hD;
    localparam STATE_EXIT2_IR          = 4'hE;
    localparam STATE_UPDATE_IR         = 4'hF;

    localparam IDCODE_ADDR             = 5'b00001;
    localparam DTMCS_ADDR              = 5'b10000;
    localparam DMI_ADDR                = 5'b10001;
    localparam BYPASS_ADDR             = 5'b11111;

    localparam IDCODE_VERSION          = 4'd1;
    localparam IDCODE_PART_NUMBER      = 16'd1;
    localparam IDCODE_MANUFLD          = 11'd1;

    localparam DTMCS_ABITS             = 6'd6;
    localparam DTMCS_VERSION           = 4'd1;

    localparam DMI_OP_READ             = 2'd1;
    localparam DMI_OP_WRITE            = 2'd2;

    reg  [TAP_STATE_WIDTH-1:0] tap_state;
    reg  [IR_WIDTH-1:0]        ir;
    wire [DR_WIDTH-1:0]        idcode;
    wire [DR_WIDTH-1:0]        dtmcs;
    reg  [SHIFT_REG_WIDTH-1:0] shift_reg;

    reg                        dtmcs_dmihardreset;
    wire                       dtmcs_dmireset;
    wire [2:0]                 dtmcs_idle;
    wire [1:0]                 dtmcs_dmistat;

    reg                        dtm_req_vld;
    reg  [`DMI_WIDTH-1:0]      dtm_req_data;
    wire                       dtm_resp_vld;
    wire [`DMI_WIDTH-1:0]      dtm_resp_data;
    reg  [`DMI_WIDTH-1:0]      dtm_resq_data_reg;

    wire                       busy;
    reg                        trans_busy;
    reg                        sticky_busy;

    wire [`DMI_WIDTH-1:0]      busy_resp;
    wire [`DMI_WIDTH-1:0]      none_busy_resp;

    wire [`DMI_OP_WIDTH-1:0]   dmi_op;

    assign idcode         = {IDCODE_VERSION, IDCODE_PART_NUMBER, IDCODE_MANUFLD, 1'b1};

    assign dtmcs          = {14'd0, 1'b0, 1'b0, 1'b0, dtmcs_idle, dtmcs_dmistat, DTMCS_ABITS, DTMCS_VERSION};
    assign dtmcs_dmireset = shift_reg[16];  // 只是一个信号，不改变dtmcs内的数值
    assign dtmcs_idle     = 3'd5;
    assign dtmcs_dmistat  = sticky_busy ? 2'd3 : 2'd0;

    // 每次传输均需1、传输完成 2、没有超前访问或出错清除才可下一次传输
    assign busy           = trans_busy || sticky_busy;

    assign busy_resp      = 'd3;
    assign none_busy_resp = dtm_resq_data_reg;

    assign dmi_op         = shift_reg[`DMI_OP_WIDTH-1:0];

    // TAP控制器状态机可用五次TMS复位
    always @(posedge jtag_TCK) begin
        if (i_jtag_rst) begin
            tap_state <= STATE_TEST_LOGIC_RESET;
        end else begin
            case (tap_state)
                STATE_TEST_LOGIC_RESET  : tap_state <= jtag_TMS ? STATE_TEST_LOGIC_RESET : STATE_RUN_TEST_IDLE; 
                STATE_RUN_TEST_IDLE     : tap_state <= jtag_TMS ? STATE_SELECT_DR_SCAN   : STATE_RUN_TEST_IDLE; 
                STATE_SELECT_DR_SCAN    : tap_state <= jtag_TMS ? STATE_SELECT_IR_SCAN   : STATE_CAPTURE_DR;    
                STATE_CAPTURE_DR        : tap_state <= jtag_TMS ? STATE_EXIT1_DR         : STATE_SHIFT_DR;      
                STATE_SHIFT_DR          : tap_state <= jtag_TMS ? STATE_EXIT1_DR         : STATE_SHIFT_DR;      
                STATE_EXIT1_DR          : tap_state <= jtag_TMS ? STATE_UPDATE_DR        : STATE_PAUSE_DR;      
                STATE_PAUSE_DR          : tap_state <= jtag_TMS ? STATE_EXIT2_DR         : STATE_PAUSE_DR;      
                STATE_EXIT2_DR          : tap_state <= jtag_TMS ? STATE_UPDATE_DR        : STATE_SHIFT_DR;      
                STATE_UPDATE_DR         : tap_state <= jtag_TMS ? STATE_SELECT_DR_SCAN   : STATE_RUN_TEST_IDLE; 
                STATE_SELECT_IR_SCAN    : tap_state <= jtag_TMS ? STATE_TEST_LOGIC_RESET : STATE_CAPTURE_IR;    
                STATE_CAPTURE_IR        : tap_state <= jtag_TMS ? STATE_EXIT1_IR         : STATE_SHIFT_IR;      
                STATE_SHIFT_IR          : tap_state <= jtag_TMS ? STATE_EXIT1_IR         : STATE_SHIFT_IR;      
                STATE_EXIT1_IR          : tap_state <= jtag_TMS ? STATE_UPDATE_IR        : STATE_PAUSE_IR;      
                STATE_PAUSE_IR          : tap_state <= jtag_TMS ? STATE_EXIT2_IR         : STATE_PAUSE_IR;      
                STATE_EXIT2_IR          : tap_state <= jtag_TMS ? STATE_UPDATE_IR        : STATE_SHIFT_IR;      
                STATE_UPDATE_IR         : tap_state <= jtag_TMS ? STATE_SELECT_DR_SCAN   : STATE_RUN_TEST_IDLE; 
            endcase 
        end
    end

    always @(posedge jtag_TCK) begin
        case (tap_state)
            STATE_TEST_LOGIC_RESET : ir <= IDCODE_ADDR;
            STATE_UPDATE_IR        : ir <= shift_reg[IR_WIDTH-1:0];
        endcase
    end

    always @(posedge jtag_TCK) begin
        case (tap_state) 
            STATE_TEST_LOGIC_RESET : shift_reg <= 'd0;
            // IR
            STATE_CAPTURE_IR       : shift_reg <= {{{SHIFT_REG_WIDTH-IR_WIDTH}{1'b0}}, IDCODE_ADDR};
            STATE_SHIFT_IR         : shift_reg <= {{{SHIFT_REG_WIDTH-IR_WIDTH}{1'b0}}, jtag_TDI, shift_reg[IR_WIDTH-1:1]};
            // DR
            STATE_CAPTURE_DR: begin
                case (ir)
                    IDCODE_ADDR    : shift_reg <= {{{SHIFT_REG_WIDTH-DR_WIDTH}{1'b0}}, idcode};
                    DTMCS_ADDR     : shift_reg <= {{{SHIFT_REG_WIDTH-DR_WIDTH}{1'b0}}, dtmcs};
                    DMI_ADDR       : shift_reg <= busy ? busy_resp : none_busy_resp;
                    BYPASS_ADDR    : shift_reg <= 'd0;
                    default        : shift_reg <= 'd0;
                endcase
            end
            STATE_SHIFT_DR: begin
                case (ir)
                    IDCODE_ADDR    : shift_reg <= {{{SHIFT_REG_WIDTH-DR_WIDTH}{1'b0}}, jtag_TDI, shift_reg[SHIFT_REG_WIDTH-1:1]};
                    DTMCS_ADDR     : shift_reg <= {{{SHIFT_REG_WIDTH-DR_WIDTH}{1'b0}}, jtag_TDI, shift_reg[SHIFT_REG_WIDTH-1:1]};
                    DMI_ADDR       : shift_reg <= {jtag_TDI, shift_reg[SHIFT_REG_WIDTH-1:1]};
                    BYPASS_ADDR    : shift_reg <= {{{SHIFT_REG_WIDTH-1}{1'b0}}, jtag_TDI};
                    default        : shift_reg <= {{{SHIFT_REG_WIDTH-1}{1'b0}}, jtag_TDI};
                endcase
            end   
        endcase
    end

    always @(posedge jtag_TCK) begin
        dtm_req_vld  <= 'd0;
        dtm_req_data <= 'd0; 
        case (tap_state) 
            STATE_TEST_LOGIC_RESET: begin
                dtm_req_vld  <= 'd0;
                dtm_req_data <= 'd0;
            end
            STATE_UPDATE_DR: begin
                if (ir == DMI_ADDR) begin
                    if (!busy) begin
                        if ((dmi_op == DMI_OP_READ) || (dmi_op == DMI_OP_WRITE))
                        dtm_req_vld  <= 'd1;
                        dtm_req_data <= shift_reg; 
                    end
                end
            end
        endcase
    end

    // 保持接收到的信号
    always @(posedge jtag_TCK) begin
        if (tap_state == STATE_TEST_LOGIC_RESET) begin
            dtm_resq_data_reg <= 'd0;
        end else if (dtm_resp_vld) begin
            dtm_resq_data_reg <= dtm_resp_data;
        end
    end

    always @(negedge jtag_TCK) begin
        jtag_TDO <= 'd0;
        case (tap_state)
            STATE_TEST_LOGIC_RESET         : jtag_TDO <= 'd0;
            STATE_SHIFT_IR, STATE_SHIFT_DR : jtag_TDO <= shift_reg[0];
        endcase
    end

    // 传输并接受反馈busy状态
    always @(posedge jtag_TCK) begin
        if (tap_state == STATE_TEST_LOGIC_RESET) begin
            trans_busy <= 'd0;
        end else if (dtm_req_vld) begin
            trans_busy <= 'd1;
        end else if (dtm_resp_vld) begin
            trans_busy <= 'd0;
        end
    end

    // 传输并接受反馈busy状态
    always @(posedge jtag_TCK) begin
        case (tap_state)
            STATE_TEST_LOGIC_RESET: begin
                sticky_busy <= 'd0;
            end
            STATE_CAPTURE_DR: begin
                if (ir == DMI_ADDR) begin
                    sticky_busy <= busy; 
                end
            end
            STATE_UPDATE_DR: begin
                if ((ir == DTMCS_ADDR) && dtmcs_dmireset) begin
                    sticky_busy <= 'd0;
                end 
            end
        endcase
    end

    full_handshake_tx #(
        .DATA_WIDTH(`DMI_WIDTH)
    ) u_dtm_req_handshake_tx (            
        .clk(jtag_TCK),                 
        .rst_n(!i_jtag_rst),   
        .i_vld(dtm_req_vld),        
        .i_data(dtm_req_data),    
        .o_vld(o_dtm_req_vld),              
        .o_data(o_dtm_req_data),         
        .i_rdy(i_dtm_req_rdy)
    );

    full_handshake_rx #(
        .DATA_WIDTH(`DMI_WIDTH)
    ) u_dtm_resp_handshake_rx (            
        .clk(jtag_TCK),                 
        .rst_n(!i_jtag_rst),   
        .i_vld(i_dtm_resp_vld),        
        .i_data(i_dtm_resp_data),    
        .o_vld(dtm_resp_vld),              
        .o_data(dtm_resp_data),         
        .o_rdy(o_dtm_resp_rdy)
    );

endmodule

`default_nettype wire
