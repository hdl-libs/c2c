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
// Module Name   : aurora_8b10b_warpper
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

module aurora_8b10b_warpper #(
    parameter integer C_APB_DATA_WIDTH = 32,
    parameter integer C_APB_ADDR_WIDTH = 16,
    parameter integer C_S_BASEADDR     = 0,
    parameter integer C_S_HIGHADDR     = 255,
    parameter         C_SAME_CLK       = "true",
    parameter         C_CLK_FREQ       = 100_000_000,
    parameter integer LANE_NUM         = 1,
    parameter integer CORE_NUM         = 2
) (
    input  wire                          clk,
    input  wire                          rstn,
    input  wire [(C_APB_ADDR_WIDTH-1):0] s00_paddr,
    input  wire                          s00_psel,
    input  wire                          s00_penable,
    input  wire                          s00_pwrite,
    input  wire [(C_APB_DATA_WIDTH-1):0] s00_pwdata,
    output wire                          s00_pready,
    output wire [(C_APB_DATA_WIDTH-1):0] s00_prdata,
    output wire                          s00_pslverr,

    input  wire [(C_APB_ADDR_WIDTH-1):0] s01_paddr,
    input  wire                          s01_psel,
    input  wire                          s01_penable,
    input  wire                          s01_pwrite,
    input  wire [(C_APB_DATA_WIDTH-1):0] s01_pwdata,
    output wire                          s01_pready,
    output wire [(C_APB_DATA_WIDTH-1):0] s01_prdata,
    output wire                          s01_pslverr,

    input  wire [(C_APB_ADDR_WIDTH-1):0] s02_paddr,
    input  wire                          s02_psel,
    input  wire                          s02_penable,
    input  wire                          s02_pwrite,
    input  wire [(C_APB_DATA_WIDTH-1):0] s02_pwdata,
    output wire                          s02_pready,
    output wire [(C_APB_DATA_WIDTH-1):0] s02_prdata,
    output wire                          s02_pslverr,

    input  wire [(C_APB_ADDR_WIDTH-1):0] s03_paddr,
    input  wire                          s03_psel,
    input  wire                          s03_penable,
    input  wire                          s03_pwrite,
    input  wire [(C_APB_DATA_WIDTH-1):0] s03_pwdata,
    output wire                          s03_pready,
    output wire [(C_APB_DATA_WIDTH-1):0] s03_prdata,
    output wire                          s03_pslverr,

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
    input  wire [(CORE_NUM*LANE_NUM-1):0] RXP,
    input  wire [(CORE_NUM*LANE_NUM-1):0] RXN,
    output wire [(CORE_NUM*LANE_NUM-1):0] TXP,
    output wire [(CORE_NUM*LANE_NUM-1):0] TXN
);

    genvar ii;

    wire                          GT_REFCLK_IN;

    // User I/O
    wire [        (CORE_NUM-1):0] HARD_ERR;
    wire [        (CORE_NUM-1):0] SOFT_ERR;
    wire [        (LANE_NUM-1):0] LANE_UP        [0:CORE_NUM-1];
    wire [        (CORE_NUM-1):0] CHANNEL_UP;
    wire [        (CORE_NUM-1):0] PLL_NOT_LOCKED;
    // Core Control I/O
    wire [        (CORE_NUM-1):0] POWER_DOWN;
    wire [        CORE_NUM*2-1:0] LOOPBACK;
    wire [        (CORE_NUM-1):0] GT_RESET_IN;
    wire [        (CORE_NUM-1):0] PMA_RESET_IN;
    wire [        (CORE_NUM-1):0] SYS_RESET_OUT;
    wire [        (CORE_NUM-1):0] LINK_RESET_OUT;
    //
    wire [        (CORE_NUM-1):0] user_reset;
    wire [        (CORE_NUM-1):0] user_reset_pb;
    wire [        (CORE_NUM-1):0] user_pma_init;
    wire [        (LANE_NUM+4):0] aurora_sts_cdc [0:CORE_NUM-1];

    wire [     (32*LANE_NUM-1):0] S_AXIS_TDATA   [0:CORE_NUM-1];
    wire                          S_AXIS_TVALID  [0:CORE_NUM-1];
    wire                          S_AXIS_TREADY  [0:CORE_NUM-1];
    wire [     (32*LANE_NUM-1):0] M_AXIS_TDATA   [0:CORE_NUM-1];
    wire                          M_AXIS_TVALID  [0:CORE_NUM-1];

    wire [(C_APB_ADDR_WIDTH-1):0] paddr          [0:CORE_NUM-1];
    wire [        (CORE_NUM-1):0] psel;
    wire [        (CORE_NUM-1):0] penable;
    wire [        (CORE_NUM-1):0] pwrite;
    wire [(C_APB_DATA_WIDTH-1):0] pwdata         [0:CORE_NUM-1];
    wire [        (CORE_NUM-1):0] pready;
    wire [(C_APB_DATA_WIDTH-1):0] prdata         [0:CORE_NUM-1];
    wire [        (CORE_NUM-1):0] pslverr;

    IBUFDS_GTE2 IBUFDS_GTE2_CLK1 (
        .I    (GT_REFCLK_P),
        .IB   (GT_REFCLK_N),
        .CEB  (1'b0),
        .O    (GT_REFCLK_IN),
        .ODIV2()
    );

    wire [(CORE_NUM-1):0] common_reset_i;
    wire                  gt0_pll0lock_out;
    wire                  gt0_pll1lock_out;
    wire                  gt0_pll0refclklost_out;
    wire                  gt0_pll0outclk_i;
    wire                  gt0_pll1outclk_i;
    wire                  gt0_pll0outrefclk_i;
    wire                  gt0_pll1outrefclk_i;

    //------ instance of _gt_common_wrapper ---{
    aurora_8b10b_0_gt_common_wrapper gt_common_support (
        .gt0_gtrefclk0_in      (GT_REFCLK_IN),            //  input
        .gt0_pll0lockdetclk_in (INIT_CLK_IN),             //  input
        .gt0_pll0lock_out      (gt0_pll0lock_out),        //  output
        .gt0_pll1lock_out      (gt0_pll1lock_out),        //  output
        .gt0_pll0refclklost_out(gt0_pll0refclklost_out),  //  output
        .gt0_pll0outclk_i      (gt0_pll0outclk_i),        //  output
        .gt0_pll1outclk_i      (gt0_pll1outclk_i),        //  output
        .gt0_pll0outrefclk_i   (gt0_pll0outrefclk_i),     //  output
        .gt0_pll1outrefclk_i   (gt0_pll1outrefclk_i),     //  output
        .gt0_pll0reset_in      (|common_reset_i)          //  input
    );

    generate

        if (CORE_NUM >= 1) begin
            assign S_AXIS_TDATA[0]  = S00_AXIS_TDATA;
            assign S_AXIS_TVALID[0] = S00_AXIS_TVALID;
            assign S00_AXIS_TREADY  = S_AXIS_TREADY[0];
            assign M00_AXIS_TDATA   = M_AXIS_TDATA[0];
            assign M00_AXIS_TVALID  = M_AXIS_TVALID[0];

            assign paddr[0]         = s00_paddr;
            assign psel[0]          = s00_psel;
            assign penable[0]       = s00_penable;
            assign pwrite[0]        = s00_pwrite;
            assign pwdata[0]        = s00_pwdata;

            assign s00_pready       = pready[0];
            assign s00_prdata       = prdata[0];
            assign s00_pslverr      = pslverr[0];
        end else begin
            assign S00_AXIS_TREADY = 0;
            assign M00_AXIS_TDATA  = 0;
            assign M00_AXIS_TVALID = 0;

            assign s00_pready      = 0;
            assign s00_prdata      = 0;
            assign s00_pslverr     = 0;
        end

        if (CORE_NUM >= 2) begin
            assign S_AXIS_TDATA[1]  = S01_AXIS_TDATA;
            assign S_AXIS_TVALID[1] = S01_AXIS_TVALID;
            assign S01_AXIS_TREADY  = S_AXIS_TREADY[1];
            assign M01_AXIS_TDATA   = M_AXIS_TDATA[1];
            assign M01_AXIS_TVALID  = M_AXIS_TVALID[1];

            assign paddr[1]         = s01_paddr;
            assign psel[1]          = s01_psel;
            assign penable[1]       = s01_penable;
            assign pwrite[1]        = s01_pwrite;
            assign pwdata[1]        = s01_pwdata;

            assign s01_pready       = pready[1];
            assign s01_prdata       = prdata[1];
            assign s01_pslverr      = pslverr[1];
        end else begin
            assign S01_AXIS_TREADY = 0;
            assign M01_AXIS_TDATA  = 0;
            assign M01_AXIS_TVALID = 0;

            assign s01_pready      = 0;
            assign s01_prdata      = 0;
            assign s01_pslverr     = 0;
        end


        if (CORE_NUM >= 3) begin
            assign S_AXIS_TDATA[2]  = S02_AXIS_TDATA;
            assign S_AXIS_TVALID[2] = S02_AXIS_TVALID;
            assign S02_AXIS_TREADY  = S_AXIS_TREADY[2];
            assign M02_AXIS_TDATA   = M_AXIS_TDATA[2];
            assign M02_AXIS_TVALID  = M_AXIS_TVALID[2];

            assign paddr[2]         = s02_paddr;
            assign psel[2]          = s02_psel;
            assign penable[2]       = s02_penable;
            assign pwrite[2]        = s02_pwrite;
            assign pwdata[2]        = s02_pwdata;

            assign s02_pready       = pready[2];
            assign s02_prdata       = prdata[2];
            assign s02_pslverr      = pslverr[2];
        end else begin
            assign S02_AXIS_TREADY = 0;
            assign M02_AXIS_TDATA  = 0;
            assign M02_AXIS_TVALID = 0;

            assign s02_pready      = 0;
            assign s02_prdata      = 0;
            assign s02_pslverr     = 0;
        end

        if (CORE_NUM >= 4) begin
            assign S_AXIS_TDATA[3]  = S03_AXIS_TDATA;
            assign S_AXIS_TVALID[3] = S03_AXIS_TVALID;
            assign S03_AXIS_TREADY  = S_AXIS_TREADY[3];
            assign M03_AXIS_TDATA   = M_AXIS_TDATA[3];
            assign M03_AXIS_TVALID  = M_AXIS_TVALID[3];

            assign paddr[3]         = s03_paddr;
            assign psel[3]          = s03_psel;
            assign penable[3]       = s03_penable;
            assign pwrite[3]        = s03_pwrite;
            assign pwdata[3]        = s03_pwdata;

            assign s03_pready       = pready[3];
            assign s03_prdata       = prdata[3];
            assign s03_pslverr      = pslverr[3];
        end else begin
            assign S03_AXIS_TREADY = 0;
            assign M03_AXIS_TDATA  = 0;
            assign M03_AXIS_TVALID = 0;

            assign s03_pready      = 0;
            assign s03_prdata      = 0;
            assign s03_pslverr     = 0;
        end

        for (ii = 0; ii < CORE_NUM; ii = ii + 1) begin : g_aurora_module
            assign POWER_DOWN[ii]      = 0;
            assign LOOPBACK[ii*2+:2]   = 0;
            assign USER_RESETN_OUT[ii] = CHANNEL_UP[ii];

            aurora_sts_ui #(
                .C_APB_DATA_WIDTH(C_APB_DATA_WIDTH),
                .C_APB_ADDR_WIDTH(C_APB_ADDR_WIDTH),
                .C_S_BASEADDR    (C_S_BASEADDR),
                .C_S_HIGHADDR    (C_S_HIGHADDR),
                .LANE_NUM        (LANE_NUM)
            ) aurora_sts_ui_inst (
                .clk          (clk),
                .rstn         (rstn),
                .s_paddr      (paddr[ii]),
                .s_psel       (psel[ii]),
                .s_penable    (penable[ii]),
                .s_pwrite     (pwrite[ii]),
                .s_pwdata     (pwdata[ii]),
                .s_pready     (pready[ii]),
                .s_prdata     (prdata[ii]),
                .s_pslverr    (pslverr[ii]),
                .user_reset   (user_reset[ii]),
                .user_reset_pb(user_reset_pb[ii]),
                .user_pma_init(user_pma_init[ii]),
                .aurora_sts   (aurora_sts_cdc[ii])
            );

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
                .aurora_init_clk         (INIT_CLK_IN),
                .aurora_user_clk_out     (USER_CLK_OUT[ii]),
                .aurora_reset_pb         (GT_RESET_IN[ii]),
                .aurora_pma_init         (PMA_RESET_IN[ii]),
                .aurora_sts_channel_up   (CHANNEL_UP[ii]),
                .aurora_sts_hard_err     (HARD_ERR[ii]),
                .aurora_sts_lane_up      (LANE_UP[ii]),
                .aurora_sts_mmcm_not_lock(PLL_NOT_LOCKED[ii]),
                .aurora_sts_soft_err     (SOFT_ERR[ii]),
                .aurora_sts_gt_pll_lock  (1'b1),
                .aurora_sts_cdc          (aurora_sts_cdc[ii])
            );

            aurora_8b10b_0_support aurora_module_i (
                // AXI TX Interface
                .s_axi_tx_tdata        (S_AXIS_TDATA[ii]),
                .s_axi_tx_tvalid       (S_AXIS_TVALID[ii]),
                .s_axi_tx_tready       (S_AXIS_TREADY[ii]),
                // AXI RX INTERFACE
                .m_axi_rx_tdata        (M_AXIS_TDATA[ii]),
                .m_axi_rx_tvalid       (M_AXIS_TVALID[ii]),
                // V5 Serial I/O
                .rxp                   (RXP[ii]),
                .rxn                   (RXN[ii]),
                .txp                   (TXP[ii]),
                .txn                   (TXN[ii]),
                // GT Reference Clock Interface
                .gt_refclk             (GT_REFCLK_IN),
                // Error Detection Interface
                .hard_err              (HARD_ERR[ii]),
                .soft_err              (SOFT_ERR[ii]),
                // Status
                .channel_up            (CHANNEL_UP[ii]),
                .lane_up               (LANE_UP[ii]),
                .pll_not_locked_out    (PLL_NOT_LOCKED[ii]),
                .tx_lock               (),
                .tx_resetdone_out      (),
                .rx_resetdone_out      (),
                // System Interface
                .init_clk              (INIT_CLK_IN),
                .user_clk_out          (USER_CLK_OUT[ii]),
                .reset                 (PMA_RESET_IN[ii]),
                .gt_reset              (GT_RESET_IN[ii]),
                .power_down            (POWER_DOWN[ii]),
                .loopback              (LOOPBACK[ii*2+:2]),
                .sys_reset_out         (SYS_RESET_OUT[ii]),
                .link_reset_out        (LINK_RESET_OUT[ii]),
                // GT_COMMON
                .gt0_pll0lock_out      (gt0_pll0lock_out),
                .gt0_pll1lock_out      (gt0_pll1lock_out),
                .gt0_pll0refclklost_out(gt0_pll0refclklost_out),
                .gt0_pll0outclk_i      (gt0_pll0outclk_i),
                .gt0_pll1outclk_i      (gt0_pll1outclk_i),
                .gt0_pll0outrefclk_i   (gt0_pll0outrefclk_i),
                .gt0_pll1outrefclk_i   (gt0_pll1outrefclk_i),
                .common_reset_i        (common_reset_i[ii]),
                // DRP PORT
                .drpclk_in             (DRP_CLK_IN)
            );
        end
    endgenerate

endmodule

// verilog_format: off
`resetall
// verilog_format: on
