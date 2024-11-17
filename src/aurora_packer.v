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
// Module Name   : aurora_packer
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

module aurora_packer #(
    parameter integer AURORA_AXIS_TBYTE = 32,
    parameter integer AXIS_TBYTE        = 16
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXIS:S_AXIS:user_m:user_s, ASSOCIATED_RESET aresetn" *)
    input wire aclk,  //

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input wire aresetn,  //

    // to aurora
    output wire [(AURORA_AXIS_TBYTE*8-1):0] M_AXIS_tdata,
    input  wire                             M_AXIS_tready,
    output wire                             M_AXIS_tvalid,

    // from aurora
    input  wire [(AURORA_AXIS_TBYTE*8-1):0] S_AXIS_tdata,
    output wire                             S_AXIS_tready,
    input  wire                             S_AXIS_tvalid,

    // to user
    output wire [( AXIS_TBYTE*8-1):0] user_m_tdata,
    output wire [                2:0] user_m_tid,
    output wire [ ( AXIS_TBYTE -1):0] user_m_tkeep,
    output wire                       user_m_tlast,
    input  wire                       user_m_tready,
    output wire                       user_m_tvalid,

    // from user
    input  wire [( AXIS_TBYTE*8-1):0] user_s_tdata,
    input  wire [                2:0] user_s_tid,
    input  wire [ ( AXIS_TBYTE -1):0] user_s_tkeep,
    input  wire                       user_s_tlast,
    output wire                       user_s_tready,
    input  wire                       user_s_tvalid
);

    // user stream data tx , data from user to aurora
    assign M_AXIS_tdata = {256'b0, user_s_tlast, user_s_tkeep, user_s_tid, user_s_tdata};
    assign user_s_tready = M_AXIS_tready;
    assign M_AXIS_tvalid = user_s_tvalid;

    // user stream data rx, data from aurora to user
    assign {user_m_tlast, user_m_tkeep, user_m_tid, user_m_tdata} = S_AXIS_tdata;
    assign S_AXIS_tready = user_m_tready;
    assign user_m_tvalid = S_AXIS_tvalid;

endmodule

// verilog_format: off
`resetall
// verilog_format: on