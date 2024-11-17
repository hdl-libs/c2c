
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following
# module references:
# aurora_nfc_ctrl, aurora_packer, axi_aurora_sts

# Please add the sources of those modules before sourcing this Tcl script.

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:aurora_64b66b:11.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axis_data_fifo:2.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\
aurora_nfc_ctrl\
aurora_packer\
axi_aurora_sts\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: c2c_0
proc create_hier_cell_c2c_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_c2c_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 rmgt
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 tmgt
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 user_m
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 user_s

  # Create pins
  create_bd_pin -dir I drp_clk_in
  create_bd_pin -dir I init_clk
  create_bd_pin -dir I -type clk ref_clk
  create_bd_pin -dir I -type clk s_aclk
  create_bd_pin -dir I -type rst s_aresetn

  # Create instance: aurora_64b66b_0, and set properties
  set aurora_64b66b_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:11.2 aurora_64b66b_0 ]
  set_property -dict [ list \
   CONFIG.C_AURORA_LANES {1} \
   CONFIG.C_INIT_CLK {100.0} \
   CONFIG.C_LINE_RATE {6.25} \
   CONFIG.C_REFCLK_FREQUENCY {125.000} \
   CONFIG.C_USER_K {false} \
   CONFIG.C_USE_BYTESWAP {false} \
   CONFIG.DRP_FREQ {100.0000} \
   CONFIG.SINGLEEND_GTREFCLK {true} \
   CONFIG.SINGLEEND_INITCLK {true} \
   CONFIG.SupportLevel {1} \
   CONFIG.TransceiverControl {false} \
   CONFIG.drp_mode {Disabled} \
   CONFIG.flow_mode {Immediate_NFC} \
   CONFIG.interface_mode {Streaming} \
 ] $aurora_64b66b_0

  # Create instance: aurora_nfc_ctrl_0, and set properties
  set block_name aurora_nfc_ctrl
  set block_cell_name aurora_nfc_ctrl_0
  if { [catch {set aurora_nfc_ctrl_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $aurora_nfc_ctrl_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: aurora_packer_0, and set properties
  set block_name aurora_packer
  set block_cell_name aurora_packer_0
  if { [catch {set aurora_packer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $aurora_packer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.AXIS_TBYTE {28} \
 ] $aurora_packer_0

  # Create instance: aurora_user_clk_reset, and set properties
  set aurora_user_clk_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 aurora_user_clk_reset ]

  # Create instance: axi_aurora_sts_0, and set properties
  set block_name axi_aurora_sts
  set block_cell_name axi_aurora_sts_0
  if { [catch {set axi_aurora_sts_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_aurora_sts_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: rx_fifo_1, and set properties
  set rx_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 rx_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
   CONFIG.HAS_AFULL {0} \
   CONFIG.HAS_PROG_FULL {1} \
   CONFIG.IS_ACLK_ASYNC {1} \
   CONFIG.PROG_FULL_THRESH {59} \
 ] $rx_fifo_1

  # Create instance: tx_fifo_1, and set properties
  set tx_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 tx_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $tx_fifo_1

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins user_m] [get_bd_intf_pins aurora_packer_0/user_m]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins user_s] [get_bd_intf_pins aurora_packer_0/user_s]
  connect_bd_intf_net -intf_net aurora_64b66b_0_GT_SERIAL_TX [get_bd_intf_pins tmgt] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net aurora_64b66b_0_USER_DATA_M_AXIS_RX [get_bd_intf_pins aurora_64b66b_0/USER_DATA_M_AXIS_RX] [get_bd_intf_pins rx_fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net aurora_nfc_ctrl_0_m [get_bd_intf_pins aurora_64b66b_0/NFC_S_AXIS_TX] [get_bd_intf_pins aurora_nfc_ctrl_0/m]
  connect_bd_intf_net -intf_net aurora_packer_0_M_AXIS [get_bd_intf_pins aurora_packer_0/M_AXIS] [get_bd_intf_pins tx_fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net aurora_rmgt_1 [get_bd_intf_pins rmgt] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net rx_fifo_1_M_AXIS [get_bd_intf_pins aurora_packer_0/S_AXIS] [get_bd_intf_pins rx_fifo_1/M_AXIS]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins axi_aurora_sts_0/s_axi]
  connect_bd_intf_net -intf_net tx_fifo_1_M_AXIS [get_bd_intf_pins aurora_64b66b_0/USER_DATA_S_AXIS_TX] [get_bd_intf_pins tx_fifo_1/M_AXIS]

  # Create port connections
  connect_bd_net -net aurora_64b66b_0_channel_up [get_bd_pins aurora_64b66b_0/channel_up] [get_bd_pins axi_aurora_sts_0/aurora_sts_channel_up]
  connect_bd_net -net aurora_64b66b_0_gt_pll_lock [get_bd_pins aurora_64b66b_0/gt_pll_lock] [get_bd_pins axi_aurora_sts_0/aurora_sts_gt_pll_lock]
  connect_bd_net -net aurora_64b66b_0_hard_err [get_bd_pins aurora_64b66b_0/hard_err] [get_bd_pins axi_aurora_sts_0/aurora_sts_hard_err]
  connect_bd_net -net aurora_64b66b_0_lane_up [get_bd_pins aurora_64b66b_0/lane_up] [get_bd_pins axi_aurora_sts_0/aurora_sts_lane_up]
  connect_bd_net -net aurora_64b66b_0_mmcm_not_locked_out [get_bd_pins aurora_64b66b_0/mmcm_not_locked_out] [get_bd_pins axi_aurora_sts_0/aurora_sts_mmcm_not_lock]
  connect_bd_net -net aurora_64b66b_0_soft_err [get_bd_pins aurora_64b66b_0/soft_err] [get_bd_pins axi_aurora_sts_0/aurora_sts_soft_err]
  connect_bd_net -net aurora_64b66b_0_sys_reset_out [get_bd_pins aurora_64b66b_0/sys_reset_out] [get_bd_pins aurora_user_clk_reset/ext_reset_in]
  connect_bd_net -net aurora_64b66b_0_user_clk_out [get_bd_pins aurora_64b66b_0/user_clk_out] [get_bd_pins aurora_nfc_ctrl_0/clk] [get_bd_pins aurora_user_clk_reset/slowest_sync_clk] [get_bd_pins axi_aurora_sts_0/aurora_user_clk_out] [get_bd_pins rx_fifo_1/s_axis_aclk] [get_bd_pins tx_fifo_1/m_axis_aclk]
  connect_bd_net -net aurora_user_clk_reset_peripheral_aresetn [get_bd_pins aurora_nfc_ctrl_0/rstn] [get_bd_pins aurora_user_clk_reset/peripheral_aresetn] [get_bd_pins rx_fifo_1/s_axis_aresetn]
  connect_bd_net -net axi_aurora_sts_0_aurora_pma_init [get_bd_pins aurora_64b66b_0/pma_init] [get_bd_pins axi_aurora_sts_0/aurora_pma_init]
  connect_bd_net -net axi_aurora_sts_0_aurora_reset_pb [get_bd_pins aurora_64b66b_0/reset_pb] [get_bd_pins axi_aurora_sts_0/aurora_reset_pb]
  connect_bd_net -net drp_clk_in_1 [get_bd_pins drp_clk_in] [get_bd_pins aurora_64b66b_0/drp_clk_in]
  connect_bd_net -net init_clk_1 [get_bd_pins init_clk] [get_bd_pins aurora_64b66b_0/init_clk] [get_bd_pins axi_aurora_sts_0/aurora_init_clk]
  connect_bd_net -net ref_clk_1 [get_bd_pins ref_clk] [get_bd_pins aurora_64b66b_0/refclk1_in]
  connect_bd_net -net rx_fifo_1_prog_full [get_bd_pins aurora_nfc_ctrl_0/afull] [get_bd_pins rx_fifo_1/prog_full]
  connect_bd_net -net s_aclk_1 [get_bd_pins s_aclk] [get_bd_pins axi_aurora_sts_0/s_axi_aclk] [get_bd_pins rx_fifo_1/m_axis_aclk] [get_bd_pins tx_fifo_1/s_axis_aclk]
  connect_bd_net -net s_aresetn_1 [get_bd_pins s_aresetn] [get_bd_pins axi_aurora_sts_0/s_axi_aresetn] [get_bd_pins tx_fifo_1/s_axis_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_c2c_0 parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
