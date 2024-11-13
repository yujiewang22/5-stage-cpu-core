// 数据发送端模块
// 跨时钟域传输，全(四次)握手协议
// o_vld      = 1
// rdy(i_rdy) = 1
// o_vld      = 0
// rdy(i_rdy) = 0

// 1、可以发送时信号可以只保留一个周期，握手模块内部会进行拉高锁存
// 2、数据的接收看vld信号，只保留一个周期

`default_nettype none

module full_handshake_tx #(
    parameter DATA_WIDTH = 40
)(            
    input  wire                  clk,                 
    input  wire                  rst_n,   
    // 来自前级tx
    input  wire                  i_vld,        
    input  wire [DATA_WIDTH-1:0] i_data,    
    // handshake信号   
    output reg                   o_vld,              
    output reg  [DATA_WIDTH-1:0] o_data,     
    // 握手返回信号要在内部跨时钟域处理     
    input  wire                  i_rdy
);

    reg rdy_d;
    reg rdy;

    always @ (posedge clk) begin
        if (!rst_n) begin
            rdy_d <= 'd0;
            rdy   <= 'd0;
        end else begin
            rdy_d <= i_rdy;
            rdy   <= rdy_d;
        end
    end

    localparam STATE_WIDTH    = 3;
    localparam STATE_IDLE     = 3'b001;
    localparam STATE_ASSERT   = 3'b010;
    localparam STATE_DEASSERT = 3'b100;

    reg [STATE_WIDTH-1:0] state;
    reg [STATE_WIDTH-1:0] state_nxt;

    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always @ (*) begin
        state_nxt = STATE_IDLE;
        case (state)
            STATE_IDLE: begin
                if (i_vld) begin
                    state_nxt = STATE_ASSERT;
                end else begin
                    state_nxt = STATE_IDLE;
                end
            end
            STATE_ASSERT: begin
                if (rdy) begin
                    state_nxt = STATE_DEASSERT;
                end else begin
                    state_nxt = STATE_ASSERT;
                end
            end
            STATE_DEASSERT: begin
                if (!rdy) begin
                    state_nxt = STATE_IDLE;
                end else begin
                    state_nxt = STATE_DEASSERT;
                end
            end
        endcase
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            o_vld  <= 'd0;
            o_data <= 'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (i_vld) begin
                        o_vld  <= 'd1;
                        o_data <= i_data;
                    end
                end
                STATE_ASSERT: begin
                    if (rdy) begin
                        o_vld  <= 'd0;
                        o_data <= 'd0;
                    end
                end
            endcase
        end
    end

endmodule

`default_nettype wire
