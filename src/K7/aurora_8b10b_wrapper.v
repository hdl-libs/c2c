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
// Module Name   : aurora_8b10b_wrapper
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

module aurora_8b10b_wrapper #(
    parameter         C_SAME_CLK       = "true",
    parameter         C_CLK_FREQ       = 100_000_000,
    parameter integer LANE_NUM         = 1,
    parameter integer CORE_NUM         = 2
) (
    input  wire                          clk,
    input  wire                          rstn,

    input  wire [   (CORE_NUM-1):0] user_reset,
    input  wire [   (CORE_NUM-1):0] user_reset_pb,
    input  wire [   (CORE_NUM-1):0] user_pma_init,
    input  wire [   (CORE_NUM-1):0] user_pd,
    output wire [   (CORE_NUM-1):0] aurora_sts,
    output wire [   (LANE_NUM+4):0] aurora_sts_cdc_0,
    output wire [   (LANE_NUM+4):0] aurora_sts_cdc_1,
    output wire [   (LANE_NUM+4):0] aurora_sts_cdc_2,
    output wire [   (LANE_NUM+4):0] aurora_sts_cdc_3,

    input  wire [(32*LANE_NUM-1):0] S00_AXIS_TDATA,
    input  wire                     S00_AXIS_TVALID,
    output wire                     S00_AXIS_TREADY,
    output wire [(32*LANE_NUM-1):0] M00_AXIS_TDATA,
    output wire                     M00_AXIS_TVALID,

    input  wire [(32*LANE_NUM-1):0] S01_AXIS_TDATA,
    input  wire                     S01_AXIS_TVALID,
    output wire                     S01_AXIS_TREADY,
    output wire [(32*LANE_NUM-1):0] M01_AXIS_TDATA,
    output wire                     M01_AXIS_TVALID,

    input  wire [(32*LANE_NUM-1):0] S02_AXIS_TDATA,
    input  wire                     S02_AXIS_TVALID,
    output wire                     S02_AXIS_TREADY,
    output wire [(32*LANE_NUM-1):0] M02_AXIS_TDATA,
    output wire                     M02_AXIS_TVALID,

    input  wire [(32*LANE_NUM-1):0] S03_AXIS_TDATA,
    input  wire                     S03_AXIS_TVALID,
    output wire                     S03_AXIS_TREADY,
    output wire [(32*LANE_NUM-1):0] M03_AXIS_TDATA,
    output wire                     M03_AXIS_TVALID,

    // Clocks
    input  wire                           GT_REFCLK_P,
    input  wire                           GT_REFCLK_N,
    input  wire                           INIT_CLK_IN,
    input  wire                           DRP_CLK_IN,
    output wire [         (CORE_NUM-1):0] USER_CLK_OUT,
    output wire [         (CORE_NUM-1):0] USER_RESETN_OUT,
    // GT Serial I/O
    input  wire [0:(CORE_NUM*LANE_NUM-1)] RXP,
    input  wire [0:(CORE_NUM*LANE_NUM-1)] RXN,
    output wire [0:(CORE_NUM*LANE_NUM-1)] TXP,
    output wire [0:(CORE_NUM*LANE_NUM-1)] TXN
);

    genvar ii;

    wire                     GT_REFCLK_IN;

    // User I/O
    wire [   (CORE_NUM-1):0] HARD_ERR;
    wire [   (CORE_NUM-1):0] SOFT_ERR;
    wire [   0:(LANE_NUM-1)] LANE_UP        [0:CORE_NUM-1];
    wire [   (CORE_NUM-1):0] CHANNEL_UP;
    wire [   (CORE_NUM-1):0] PLL_NOT_LOCKED;
    // Core Control I/O
    wire [   (CORE_NUM-1):0] POWER_DOWN;
    wire [   CORE_NUM*3-1:0] LOOPBACK;
    wire [   (CORE_NUM-1):0] GT_RESET_IN;
    wire [   (CORE_NUM-1):0] PMA_RESET_IN;
    wire [   (CORE_NUM-1):0] SYS_RESET_OUT;
    wire [   (CORE_NUM-1):0] LINK_RESET_OUT;
    //
    wire [   (LANE_NUM+4):0] aurora_sts_cdc [0:CORE_NUM-1];

    wire [(32*LANE_NUM-1):0] S_AXIS_TDATA   [0:CORE_NUM-1];
    wire                     S_AXIS_TVALID  [0:CORE_NUM-1];
    wire                     S_AXIS_TREADY  [0:CORE_NUM-1];
    wire [(32*LANE_NUM-1):0] M_AXIS_TDATA   [0:CORE_NUM-1];
    wire                     M_AXIS_TVALID  [0:CORE_NUM-1];

    wire [   (CORE_NUM-1):0] gt_qpllreset_out;
    wire                     gt_qplllock;
    wire                     gt_qpllrefclklost;
    wire                     gt_qpllclk;
    wire                     gt_qpllrefclk;

    IBUFDS_GTE2 IBUFDS_GTE2_CLK1 (
        .I    (GT_REFCLK_P),
        .IB   (GT_REFCLK_N),
        .CEB  (1'b0),
        .O    (GT_REFCLK_IN),
        .ODIV2()
    );

    aurora_8b10b_0_gt_common_wrapper aurora_8b10b_0_gt_common_wrapper_inst (
        .gt0_gtrefclk0_common_in(GT_REFCLK_IN),       // input  gtx 参考时钟输入
        .gt0_qplllockdetclk_in  (INIT_CLK_IN),        // input  qpll 锁定检测时钟输入
        .gt_qpllclk_quad1_i     (gt_qpllclk),         // output qpll 时钟输出
        .gt_qpllrefclk_quad1_i  (gt_qpllrefclk),      // output qpll 参考时钟输出
        .gt0_qplllock_out       (gt_qplllock),        // output qpll 时钟锁定输出
        .gt0_qpllrefclklost_out (gt_qpllrefclklost),  // output qpll 时钟失锁输出
        .gt0_qpllreset_in       (|gt_qpllreset_out)   // input  qpll 复位
    );

    generate

        if (CORE_NUM >= 1) begin
            assign S_AXIS_TDATA[0]  = S00_AXIS_TDATA;
            assign S_AXIS_TVALID[0] = S00_AXIS_TVALID;
            assign S00_AXIS_TREADY  = S_AXIS_TREADY[0];
            assign M00_AXIS_TDATA   = M_AXIS_TDATA[0];
            assign M00_AXIS_TVALID  = M_AXIS_TVALID[0];
            assign aurora_sts_cdc_0 = aurora_sts_cdc[0];
        end else begin
            assign S00_AXIS_TREADY  = 0;
            assign M00_AXIS_TDATA   = 0;
            assign M00_AXIS_TVALID  = 0;
            assign aurora_sts_cdc_0 = 0;
        end

        if (CORE_NUM >= 2) begin
            assign S_AXIS_TDATA[1]  = S01_AXIS_TDATA;
            assign S_AXIS_TVALID[1] = S01_AXIS_TVALID;
            assign S01_AXIS_TREADY  = S_AXIS_TREADY[1];
            assign M01_AXIS_TDATA   = M_AXIS_TDATA[1];
            assign M01_AXIS_TVALID  = M_AXIS_TVALID[1];
            assign aurora_sts_cdc_1 = aurora_sts_cdc[1];
        end else begin
            assign S01_AXIS_TREADY  = 0;
            assign M01_AXIS_TDATA   = 0;
            assign M01_AXIS_TVALID  = 0;
            assign aurora_sts_cdc_1 = 0;
        end

        if (CORE_NUM >= 3) begin
            assign S_AXIS_TDATA[2]  = S02_AXIS_TDATA;
            assign S_AXIS_TVALID[2] = S02_AXIS_TVALID;
            assign S02_AXIS_TREADY  = S_AXIS_TREADY[2];
            assign M02_AXIS_TDATA   = M_AXIS_TDATA[2];
            assign M02_AXIS_TVALID  = M_AXIS_TVALID[2];
            assign aurora_sts_cdc_2 = aurora_sts_cdc[2];
        end else begin
            assign S02_AXIS_TREADY  = 0;
            assign M02_AXIS_TDATA   = 0;
            assign M02_AXIS_TVALID  = 0;
            assign aurora_sts_cdc_2 = 0;
        end

        if (CORE_NUM >= 4) begin
            assign S_AXIS_TDATA[3]  = S03_AXIS_TDATA;
            assign S_AXIS_TVALID[3] = S03_AXIS_TVALID;
            assign S03_AXIS_TREADY  = S_AXIS_TREADY[3];
            assign M03_AXIS_TDATA   = M_AXIS_TDATA[3];
            assign M03_AXIS_TVALID  = M_AXIS_TVALID[3];
            assign aurora_sts_cdc_3 = aurora_sts_cdc[3];
        end else begin
            assign S03_AXIS_TREADY  = 0;
            assign M03_AXIS_TDATA   = 0;
            assign M03_AXIS_TVALID  = 0;
            assign aurora_sts_cdc_3 = 0;
        end

        for (ii = 0; ii < CORE_NUM; ii = ii + 1) begin : g_aurora_module

            assign LOOPBACK[ii*3+:3]   = 0;
            assign USER_RESETN_OUT[ii] = CHANNEL_UP[ii];

            aurora_sts #(
                .C_SAME_CLK(C_SAME_CLK),
                .C_CLK_FREQ(C_CLK_FREQ),
                .LANE_NUM  (LANE_NUM)
            ) aurora_sts_inst (
                .clk                     (clk),
                .rstn                    (rstn),
                .ext_reset               (user_reset[ii]),
                .ext_reset_pb            (user_reset_pb[ii]),
                .ext_pma_init            (user_pma_init[ii]),
                .ext_pd                  (user_pd[ii]),
                .aurora_init_clk         (INIT_CLK_IN),
                .aurora_user_clk_out     (USER_CLK_OUT[ii]),
                .aurora_reset_pb         (GT_RESET_IN[ii]),
                .aurora_pma_init         (PMA_RESET_IN[ii]),
                .aurora_pd               (POWER_DOWN[ii]),
                .aurora_sts_channel_up   (CHANNEL_UP[ii]),
                .aurora_sts_hard_err     (HARD_ERR[ii]),
                .aurora_sts_lane_up      (LANE_UP[ii]),
                .aurora_sts_mmcm_not_lock(PLL_NOT_LOCKED[ii]),
                .aurora_sts_soft_err     (SOFT_ERR[ii]),
                .aurora_sts_gt_pll_lock  (1'b1),
                .aurora_sts_cdc          (aurora_sts_cdc[ii]),
                .link_state              (aurora_sts[ii])
            );

            aurora_8b10b_0_support #(
                .LANE_NUM(LANE_NUM)
            ) aurora_module_i (
                // AXI TX Interface
                .s_axi_tx_tdata       (S_AXIS_TDATA[ii]),
                .s_axi_tx_tvalid      (S_AXIS_TVALID[ii]),
                .s_axi_tx_tready      (S_AXIS_TREADY[ii]),
                // AXI RX INTERFACE
                .m_axi_rx_tdata       (M_AXIS_TDATA[ii]),
                .m_axi_rx_tvalid      (M_AXIS_TVALID[ii]),
                // V5 Serial I/O
                .rxp                  (RXP[ii*LANE_NUM+:LANE_NUM]),
                .rxn                  (RXN[ii*LANE_NUM+:LANE_NUM]),
                .txp                  (TXP[ii*LANE_NUM+:LANE_NUM]),
                .txn                  (TXN[ii*LANE_NUM+:LANE_NUM]),
                // GT Reference Clock Interface
                .gt_refclk            (GT_REFCLK_IN),
                // Error Detection Interface
                .hard_err             (HARD_ERR[ii]),
                .soft_err             (SOFT_ERR[ii]),
                // Status
                .channel_up           (CHANNEL_UP[ii]),
                .lane_up              (LANE_UP[ii]),
                .pll_not_locked_out   (PLL_NOT_LOCKED[ii]),
                .tx_lock              (),
                .tx_resetdone_out     (),
                .rx_resetdone_out     (),
                // System Interface
                .init_clk             (INIT_CLK_IN),
                .user_clk_out         (USER_CLK_OUT[ii]),
                .reset                (PMA_RESET_IN[ii]),
                .gt_reset             (GT_RESET_IN[ii]),
                .power_down           (POWER_DOWN[ii]),
                .loopback             (LOOPBACK[ii*3+:3]),
                .sys_reset_out        (SYS_RESET_OUT[ii]),
                .link_reset_out       (LINK_RESET_OUT[ii]),
                // GT_COMMON
                .gt_qpllclk_quad1_i   (gt_qpllclk),
                .gt_qpllrefclk_quad1_i(gt_qpllrefclk),
                .gt_qplllock_i        (gt_qplllock),
                .gt_qpllrefclklost_i  (gt_qpllrefclklost),
                .gt_qpllreset_out     (gt_qpllreset_out[ii]),
                // DRP PORT
                .drpclk_in            (DRP_CLK_IN)
            );

        end
    endgenerate

endmodule

// verilog_format: off
`resetall
// verilog_format: on
