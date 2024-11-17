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
// Module Name   : aurora_nfc_ctrl
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

module aurora_nfc_ctrl (
    input wire clk,   //
    input wire rstn,  //
    input wire afull,

    input  wire        m_tready,  //
    output reg         m_tvalid,  //
    output reg  [15:0] m_tdata    //
);

    wire edge_event;
    wire f_edge;

    util_metastable #(
        .C_EDGE_TYPE   ("both"),
        .MAINTAIN_CYCLE(1)
    ) full_monitor (
        .clk   (clk),
        .rstn  (rstn),
        .din   (afull),
        .dout  (edge_event),
        .dout_f(f_edge)
    );

    always @(posedge clk) begin
        if (!rstn) begin
            m_tdata <= 0;
        end else begin
            if (edge_event) begin
                m_tdata <= (f_edge == 1'b1) ? 16'h0000 : 16'hffff;
            end else if (m_tvalid & m_tready) begin
                m_tdata <= 16'h0000;
            end else begin
                m_tdata <= m_tdata;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            m_tvalid <= 1'b0;
        end else begin
            if (edge_event) begin
                m_tvalid <= 1'b1;
            end else if (m_tvalid & m_tready) begin
                m_tvalid <= 1'b0;
            end else begin
                m_tvalid <= m_tvalid;
            end
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on