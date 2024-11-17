// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------
// +FHEADER-------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : aurora_sts
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : File Created
// ---------------------------------------------------------------------------------------
// Synthesizable : Yes
// Clock Domains : clk
// Reset Strategy: sync reset
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module aurora_sts #(
    parameter C_SAME_CLK = "true",       // init_clk 和 clk 是否为同一时钟
    parameter C_CLK_FREQ = 100_000_000,  // 输入时钟频率
    parameter LANE_NUM   = 4             // lane 数量
) (
    input wire clk,
    input wire rstn,
    //
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ext_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire ext_reset,     // 用户控制自动复位
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ext_reset_pb RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire ext_reset_pb,  // 用户控制 phy 复位
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ext_pma_init RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire ext_pma_init,  // 用户控制 pma 复位

    input  wire                  aurora_init_clk,           //
    input  wire                  aurora_user_clk_out,       //
    output wire                  aurora_reset_pb,           // phy 复位
    output wire                  aurora_pma_init,           // pma 复位
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status CHANNEL_UP" *)
    input  wire                  aurora_sts_channel_up,     // CHANNEL_UP
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status HARD_ERR" *)
    input  wire                  aurora_sts_hard_err,       // HARD_ERR
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status LANE_UP" *)
    input  wire [0:(LANE_NUM-1)] aurora_sts_lane_up,        // LANE_UP
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status PLL_NOT_LOCKED_OUT" *)
    input  wire                  aurora_sts_mmcm_not_lock,  // PLL_NOT_LOCKED_OUT
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status SOFT_ERR" *)
    input  wire                  aurora_sts_soft_err,       // SOFT_ERR
    (* X_INTERFACE_INFO = "xilinx.com:display_aurora:core_status_out:1.0 core_status GT_PLL_LOCK" *)
    input  wire                  aurora_sts_gt_pll_lock,    // GT_PLL_LOCK
    output wire [(LANE_NUM+4):0] aurora_sts_cdc
);
    //  自动复位时间
    localparam RESET_TIME = C_CLK_FREQ + 2048 + 2048;

    reg        pma_init_i;
    reg        reset_pb_i;
    reg [31:0] aurora_reset_cnt = 0;

    // user_clk_out 时钟域信号同步
    xpm_cdc_array_single #(
        .DEST_SYNC_FF  (4),
        .INIT_SYNC_FF  (0),
        .SIM_ASSERT_CHK(0),
        .SRC_INPUT_REG (1),
        .WIDTH         (LANE_NUM + 3)
    ) aurora_sts_cdc_inst0 (
        .src_clk (aurora_user_clk_out),
        .src_in  ({aurora_sts_hard_err, aurora_sts_soft_err, aurora_sts_channel_up, aurora_sts_lane_up}),
        .dest_clk(clk),
        .dest_out(aurora_sts_cdc[(LANE_NUM+2):0])
    );

    generate
        if (C_SAME_CLK == "true") begin : g_same_clock
            assign aurora_sts_cdc[(LANE_NUM+4):(LANE_NUM+3)] = {aurora_sts_mmcm_not_lock, aurora_sts_gt_pll_lock};

            assign aurora_reset_pb                           = reset_pb_i;
            assign aurora_pma_init                           = pma_init_i;
        end else begin : g_independent_clock

            // init_clk 时钟域信号同步
            xpm_cdc_array_single #(
                .DEST_SYNC_FF  (4),
                .INIT_SYNC_FF  (0),
                .SIM_ASSERT_CHK(0),
                .SRC_INPUT_REG (1),
                .WIDTH         (2)
            ) aurora_sts_cdc_inst1 (
                .src_clk (aurora_init_clk),
                .src_in  ({aurora_sts_mmcm_not_lock, aurora_sts_gt_pll_lock}),
                .dest_clk(clk),
                .dest_out(aurora_sts_cdc[(LANE_NUM+4):(LANE_NUM+3)])
            );

            // 在 init_clk 时钟域下复位 phy 和 pma
            xpm_cdc_async_rst #(
                .DEST_SYNC_FF   (4),
                .INIT_SYNC_FF   (1),
                .RST_ACTIVE_HIGH(1)
            ) xpm_cdc_async_rst_inst (
                .dest_arst(aurora_reset_pb),
                .dest_clk (aurora_init_clk),
                .src_arst (reset_pb_i)
            );

            xpm_cdc_async_rst #(
                .DEST_SYNC_FF   (4),
                .INIT_SYNC_FF   (1),
                .RST_ACTIVE_HIGH(1)
            ) xpm_cdc_async_rst_inst1 (
                .dest_arst(aurora_pma_init),
                .dest_clk (aurora_init_clk),
                .src_arst (pma_init_i)
            );
        end
    endgenerate

    // 复位时间计数
    always @(posedge clk) begin
        if (!rstn || ext_reset) begin
            aurora_reset_cnt <= 0;
        end else begin
            if (aurora_reset_cnt < RESET_TIME) begin
                aurora_reset_cnt <= aurora_reset_cnt + 1;
            end else begin
                aurora_reset_cnt <= aurora_reset_cnt;
            end
        end
    end

    // phy 全程保持复位
    always @(posedge clk) begin
        if (!rstn) begin
            reset_pb_i <= 1'b1;
        end else begin
            if (aurora_reset_cnt < RESET_TIME) begin
                reset_pb_i <= 1'b1;
            end else begin
                reset_pb_i <= ext_reset_pb;
            end
        end
    end

    // 在 2048 beat 之后（至少128个 user_clk 周期）复位 pma, 持续至少 1s时间, 随后在 phy 复位取消之前取消 pma 复位
    always @(posedge clk) begin
        if (!rstn) begin
            pma_init_i <= 1'b1;
        end else begin
            if (aurora_reset_cnt > 2048 && aurora_reset_cnt < RESET_TIME - 2048) begin
                pma_init_i <= 1'b1;
            end else begin
                pma_init_i <= ext_pma_init;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on