///////////////////////////////////////////////////////////////////////////////
// (c) Copyright 1995-2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 10 ps

(* core_generation_info = "aurora_8b10b_0,aurora_8b10b_v11_1_6,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTXQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=62500,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}" *)
module aurora_8b10b_0_support #(
    parameter integer LANE_NUM = 1
) (
    // AXIS slave
    input  [(32*LANE_NUM-1):0] s_axi_tx_tdata,
    input                      s_axi_tx_tvalid,
    output                     s_axi_tx_tready,
    // AXIS master
    output [(32*LANE_NUM-1):0] m_axi_rx_tdata,
    output                     m_axi_rx_tvalid,

    // GT Serial I/O
    input [LANE_NUM-1:0] rxp,
    input [LANE_NUM-1:0] rxn,

    output [LANE_NUM-1:0] txp,
    output [LANE_NUM-1:0] txn,

    // GT Reference Clock Interface
    input                 gt_refclk,
    // Error Detection Interface
    output                hard_err,
    output                soft_err,
    // Status
    output [LANE_NUM-1:0] lane_up,
    output                channel_up,
    // System Interface
    output                user_clk_out,
    input                 gt_reset,
    input                 reset,
    input                 power_down,
    input  [         2:0] loopback,
    output                tx_lock,
    output                pll_not_locked_out,

    input  init_clk,
    output tx_resetdone_out,
    output rx_resetdone_out,
    output link_reset_out,
    output sys_reset_out,

    // GT_COMMON
    input  gt_qpllclk_quad1_i,
    input  gt_qpllrefclk_quad1_i,
    input  gt0_qplllock_i,
    input  gt0_qpllrefclklost_i,
    output gt0_qpllreset_out,

    //
    //DRP Ports
    input  drpclk_in
);

    `define DLY #1

    //*********************************Main Body of Code**********************************

    wire tx_out_clk_i;
    wire user_clk_i;
    wire sync_clk_i;
    wire pll_not_locked_i;
    wire tx_lock_i;

    wire tx_resetdone_i;
    wire rx_resetdone_i;
    wire link_reset_i;
    wire system_reset_i;
    wire gt_reset_i;
    wire drpclk_i;
    wire reset_sync_user_clk;
    wire gt_reset_sync_init_clk;

    assign drpclk_i = drpclk_in;

    // Instantiate a clock module for clock division.
    aurora_8b10b_0_CLOCK_MODULE clock_module_i (
        .GT_CLK        (tx_out_clk_i),
        .GT_CLK_LOCKED (tx_lock_i),
        .USER_CLK      (user_clk_i),
        .SYNC_CLK      (sync_clk_i),
        .PLL_NOT_LOCKED(pll_not_locked_i)
    );

    assign user_clk_out           = user_clk_i;
    assign pll_not_locked_out     = pll_not_locked_i;
    assign tx_lock                = tx_lock_i;
    assign tx_resetdone_out       = tx_resetdone_i;
    assign rx_resetdone_out       = rx_resetdone_i;
    assign link_reset_out         = link_reset_i;

    assign reset_sync_user_clk    = reset;
    assign gt_reset_sync_init_clk = gt_reset;

    aurora_8b10b_0_SUPPORT_RESET_LOGIC support_reset_logic_i (
        .RESET       (reset_sync_user_clk),
        .USER_CLK    (user_clk_i),
        .INIT_CLK_IN (init_clk),
        .GT_RESET_IN (gt_reset_sync_init_clk),
        .SYSTEM_RESET(system_reset_i),
        .GT_RESET_OUT(gt_reset_i)
    );

    //------ instance of _gt_common_wrapper ---}

    //----- Instance of _xci -----[
    aurora_8b10b_0 aurora_8b10b_0_i (
        // AXI TX Interface
        .s_axi_tx_tdata (s_axi_tx_tdata),
        .s_axi_tx_tvalid(s_axi_tx_tvalid),
        .s_axi_tx_tready(s_axi_tx_tready),
        // AXI RX Interface
        .m_axi_rx_tdata (m_axi_rx_tdata),
        .m_axi_rx_tvalid(m_axi_rx_tvalid),
        // GT Serial I/O
        .rxp            (rxp),
        .rxn            (rxn),
        .txp            (txp),
        .txn            (txn),

        .gt_refclk1(gt_refclk),  // GT Reference Clock Interface
        .hard_err  (hard_err),   // Error Detection Interface
        .soft_err  (soft_err),   // Error Detection Interface

        // Status
        .channel_up      (channel_up),
        .lane_up         (lane_up),
        // System Interface
        .user_clk        (user_clk_i),
        .sync_clk        (sync_clk_i),
        .reset           (system_reset_i),
        .power_down      (power_down),
        .loopback        (loopback),
        .gt_reset        (gt_reset_i),
        .tx_lock         (tx_lock_i),
        .init_clk_in     (init_clk),
        .pll_not_locked  (pll_not_locked_i),
        .tx_resetdone_out(tx_resetdone_i),
        .rx_resetdone_out(rx_resetdone_i),
        .link_reset_out  (link_reset_i),
        .drpclk_in       (drpclk_i),
        .drpaddr_in      (0),
        .drpen_in        (0),
        .drpdi_in        (0),
        .drpwe_in        (0),
        .drprdy_out      (),
        .drpdo_out       (),


        .gt0_qplllock_in       (gt0_qplllock_i),
        .gt0_qpllrefclklost_in (gt0_qpllrefclklost_i),
        .gt0_qpllreset_out     (gt0_qpllreset_out),
        .gt_qpllclk_quad1_in   (gt_qpllclk_quad1_i),
        .gt_qpllrefclk_quad1_in(gt_qpllrefclk_quad1_i),

        .sys_reset_out(sys_reset_out),
        .tx_out_clk   (tx_out_clk_i)
    );
    //----- Instance of _xci -----]

endmodule
