// 数据接收端模块
// 跨时钟域传输，全(四次)握手协议
// vld(i_vld) = 1
// o_rdy      = 1
// vld(i_vld) = 0
// o_rdy      = 0

`default_nettype none

module full_handshake_rx #(
    parameter DATA_WIDTH = 40
)(             
    input  wire                  clk,              
    input  wire                  rst_n,         
    input  wire                  i_vld,       
    input  wire [DATA_WIDTH-1:0] i_data,   
    output reg                   o_vld,           
    output reg  [DATA_WIDTH-1:0] o_data,
    output reg                   o_rdy       
);

    reg vld_d;
    reg vld;

    // 注意只对单比特的控制信号跨时钟域，数据一直保持即可
    always @ (posedge clk) begin
        if (!rst_n) begin
            vld_d <= 'd0;
            vld   <= 'd0;
        end else begin
            vld_d <= i_vld;
            vld   <= vld_d;
        end
    end

    localparam STATE_WIDTH    = 2;
    localparam STATE_IDLE     = 2'b01;
    localparam STATE_DEASSERT = 2'b10;

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
                if (vld) begin
                    state_nxt = STATE_DEASSERT;
                end else begin
                    state_nxt = STATE_IDLE;
                end
            end
            STATE_DEASSERT: begin
                if (!vld) begin
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
            o_rdy  <= 'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (vld) begin
                        o_vld  <= 'd1;          
                        o_data <= i_data;    
                        o_rdy  <= 'd1;
                    end
                end
                STATE_DEASSERT: begin
                    o_vld  <= 'd0;
                    o_data <= 'd0;
                    if (!vld) begin
                        o_rdy <= 'd0;
                    end
                end
            endcase
        end
    end

endmodule

`default_nettype wire
