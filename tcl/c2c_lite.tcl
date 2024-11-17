
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
# aurora_packer

# Please add the sources of those modules before sourcing this Tcl script.

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:axi_mm2s_mapper:1.1\
xilinx.com:ip:axis_data_fifo:2.0\
john_tito:ip:util_rst_cdc:1.0\
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
aurora_packer\
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


# Hierarchical cell: c2c_lite_h
proc create_hier_cell_c2c_lite_h { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_c2c_lite_h() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I aurora_ui_clk
  create_bd_pin -dir I aurora_ui_rstn
  create_bd_pin -dir I -type clk clk_100m
  create_bd_pin -dir I -type rst rstn_100m

  # Create instance: aurora_packer, and set properties
  set block_name aurora_packer
  set block_cell_name aurora_packer
  if { [catch {set aurora_packer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $aurora_packer eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.AURORA_AXIS_TBYTE {4} \
   CONFIG.AXIS_TBYTE {3} \
 ] $aurora_packer

  # Create instance: axi_mm2s_mapper, and set properties
  set axi_mm2s_mapper [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mm2s_mapper:1.1 axi_mm2s_mapper ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {13} \
   CONFIG.ID_WIDTH {2} \
   CONFIG.INTERFACES {Both} \
   CONFIG.TDATA_NUM_BYTES {3} \
 ] $axi_mm2s_mapper

  # Create instance: axis_data_fifo_rx, and set properties
  set axis_data_fifo_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_rx ]
  set_property -dict [ list \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_rx

  # Create instance: axis_data_fifo_tx, and set properties
  set axis_data_fifo_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_tx ]
  set_property -dict [ list \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_tx

  # Create instance: util_rst_cdc, and set properties
  set util_rst_cdc [ create_bd_cell -type ip -vlnv john_tito:ip:util_rst_cdc:1.0 util_rst_cdc ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins M_AXI] [get_bd_intf_pins axi_mm2s_mapper/M_AXI]
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins axis_data_fifo_rx/S_AXIS]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_mm2s_mapper/S_AXI]
  connect_bd_intf_net -intf_net aurora_packer_0_M_AXIS [get_bd_intf_pins aurora_packer/M_AXIS] [get_bd_intf_pins axis_data_fifo_tx/S_AXIS]
  connect_bd_intf_net -intf_net aurora_packer_0_user_m [get_bd_intf_pins aurora_packer/user_m] [get_bd_intf_pins axi_mm2s_mapper/S_AXIS]
  connect_bd_intf_net -intf_net axi_mm2s_mapper_0_M_AXIS [get_bd_intf_pins aurora_packer/user_s] [get_bd_intf_pins axi_mm2s_mapper/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_rx_M_AXIS [get_bd_intf_pins aurora_packer/S_AXIS] [get_bd_intf_pins axis_data_fifo_rx/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_tx_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins axis_data_fifo_tx/M_AXIS]

  # Create port connections
  connect_bd_net -net S00_ACLK_1 [get_bd_pins clk_100m] [get_bd_pins aurora_packer/aclk] [get_bd_pins axi_mm2s_mapper/aclk] [get_bd_pins axis_data_fifo_rx/m_axis_aclk] [get_bd_pins axis_data_fifo_tx/s_axis_aclk]
  connect_bd_net -net S00_ARESETN_1 [get_bd_pins rstn_100m] [get_bd_pins aurora_packer/aresetn] [get_bd_pins axi_mm2s_mapper/aresetn] [get_bd_pins axis_data_fifo_tx/s_axis_aresetn]
  connect_bd_net -net aurora_8b10b_0_user_clk_out [get_bd_pins aurora_ui_clk] [get_bd_pins axis_data_fifo_rx/s_axis_aclk] [get_bd_pins axis_data_fifo_tx/m_axis_aclk] [get_bd_pins util_rst_cdc/dest_clk]
  connect_bd_net -net aurora_ui_rstn_1 [get_bd_pins aurora_ui_rstn] [get_bd_pins util_rst_cdc/src_in]
  connect_bd_net -net util_rst_cdc_1_dest_out [get_bd_pins axis_data_fifo_rx/s_axis_aresetn] [get_bd_pins util_rst_cdc/dest_out]

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_c2c_lite_h parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
