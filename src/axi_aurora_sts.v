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
// Module Name   : axi_aurora_sts
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

module axi_aurora_sts #(
    parameter  integer C_AXI_ADDR_WIDTH = 16,
    localparam integer C_AXI_DATA_WIDTH = 32,
    parameter  integer C_TIMEROUT_CYCLE = 32,
    parameter          C_SAME_CLK       = "true",
    parameter  integer C_CLK_FREQ       = 100_000_000,
    parameter          LANE_NUM         = 4
) (
    input wire s_axi_aclk,
    input wire s_axi_aresetn,

    input  wire [    C_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [                     2:0] s_axi_arprot,
    input  wire                            s_axi_arvalid,
    output wire                            s_axi_arready,
    output wire [    C_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [                     1:0] s_axi_rresp,
    output wire                            s_axi_rvalid,
    input  wire                            s_axi_rready,
    input  wire [    C_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [                     2:0] s_axi_awprot,
    input  wire                            s_axi_awvalid,
    output wire                            s_axi_awready,
    input  wire [    C_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [(C_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                            s_axi_wvalid,
    output wire                            s_axi_wready,
    output wire [                     1:0] s_axi_bresp,
    output wire                            s_axi_bvalid,
    input  wire                            s_axi_bready,
    //
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_pb RST" *)
    // Supported parameter: POLARITY {ACTIVE_LOW, ACTIVE_HIGH}
    // Normally active low is assumed.  Use this parameter to force the level
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire                            aurora_reset_pb,           //
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 pma_init RST" *)
    // Supported parameter: POLARITY {ACTIVE_LOW, ACTIVE_HIGH}
    // Normally active low is assumed.  Use this parameter to force the level
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire                            aurora_pma_init,           //
    //
    input  wire                            aurora_init_clk,
    input  wire                            aurora_user_clk_out,
    input  wire                            aurora_sts_channel_up,     // 1
    input  wire                            aurora_sts_gt_pll_lock,    // 1
    input  wire                            aurora_sts_hard_err,       // 0
    input  wire [          0:(LANE_NUM-1)] aurora_sts_lane_up,        // 1111
    input  wire                            aurora_sts_mmcm_not_lock,  // 0
    input  wire                            aurora_sts_soft_err,       // 0
    output wire                            aurora_state               //
);

    wire                          user_reg_rreq;
    wire                          user_reg_rack;
    wire [  C_AXI_ADDR_WIDTH-1:0] user_reg_raddr;
    wire [  C_AXI_DATA_WIDTH-1:0] user_reg_rdata;
    wire                          user_reg_wreq;
    wire                          user_reg_wack;
    wire [  C_AXI_ADDR_WIDTH-1:0] user_reg_waddr;
    wire [  C_AXI_DATA_WIDTH-1:0] user_reg_wdata;
    wire [C_AXI_DATA_WIDTH/8-1:0] user_reg_wstrb;

    wire                          user_reset;
    wire                          user_pma_init;
    wire                          user_reset_pb;
    wire [          LANE_NUM+4:0] aurora_sts_cdc;  //

    axi_lite_slave #(
        .TIMEROUT_CYCLE  (C_TIMEROUT_CYCLE),
        .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
        .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH)
    ) inst_util_axi_lite_s (
        .s_axi_aclk    (s_axi_aclk),
        .s_axi_aresetn (s_axi_aresetn),
        .s_axi_araddr  (s_axi_araddr),
        .s_axi_arprot  (s_axi_arprot),
        .s_axi_arvalid (s_axi_arvalid),
        .s_axi_arready (s_axi_arready),
        .s_axi_rdata   (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_rready  (s_axi_rready),
        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awprot  (s_axi_awprot),
        .s_axi_awvalid (s_axi_awvalid),
        .s_axi_awready (s_axi_awready),
        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),
        .s_axi_wready  (s_axi_wready),
        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),
        .s_axi_bready  (s_axi_bready),
        .user_reg_rreq (user_reg_rreq),
        .user_reg_rack (user_reg_rack),
        .user_reg_raddr(user_reg_raddr),
        .user_reg_rdata(user_reg_rdata),
        .user_reg_wreq (user_reg_wreq),
        .user_reg_wack (user_reg_wack),
        .user_reg_waddr(user_reg_waddr),
        .user_reg_wdata(user_reg_wdata),
        .user_reg_wstrb(user_reg_wstrb)
    );

    aurora_sts_ui #(
        .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
        .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
        .LANE_NUM        (LANE_NUM)
    ) aurora_sts_ui_inst (
        .clk           (s_axi_aclk),
        .rstn          (s_axi_aresetn),
        .user_reg_rreq (user_reg_rreq),
        .user_reg_rack (user_reg_rack),
        .user_reg_raddr(user_reg_raddr),
        .user_reg_rdata(user_reg_rdata),
        .user_reg_wreq (user_reg_wreq),
        .user_reg_wack (user_reg_wack),
        .user_reg_waddr(user_reg_waddr),
        .user_reg_wdata(user_reg_wdata),
        .user_reg_wstrb(user_reg_wstrb),
        .aurora_sts    (aurora_sts_cdc),
        .user_reset    (user_reset),
        .user_reset_pb (user_reset_pb),
        .user_pma_init (user_pma_init)
    );

    aurora_sts #(
        .C_SAME_CLK(C_SAME_CLK),
        .C_CLK_FREQ(C_CLK_FREQ),
        .LANE_NUM  (LANE_NUM)
    ) aurora_sts_inst (
        .clk                     (s_axi_aclk),
        .rstn                    (s_axi_aresetn),
        .ext_reset               (user_reset),
        .ext_reset_pb            (user_reset_pb),
        .ext_pma_init            (user_pma_init),
        .aurora_init_clk         (aurora_init_clk),
        .aurora_user_clk_out     (aurora_user_clk_out),
        .aurora_sts_channel_up   (aurora_sts_channel_up),
        .aurora_sts_gt_pll_lock  (aurora_sts_gt_pll_lock),
        .aurora_sts_hard_err     (aurora_sts_hard_err),
        .aurora_sts_lane_up      (aurora_sts_lane_up),
        .aurora_sts_mmcm_not_lock(aurora_sts_mmcm_not_lock),
        .aurora_sts_soft_err     (aurora_sts_soft_err),
        .aurora_sts_cdc          (aurora_sts_cdc),
        .aurora_reset_pb         (aurora_reset_pb),
        .aurora_pma_init         (aurora_pma_init),
        .aurora_state            (aurora_state)
    );

endmodule

// verilog_format: off
`resetall
// verilog_format: on