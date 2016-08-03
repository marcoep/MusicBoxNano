# Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus Prime License Agreement,
# the Altera MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Altera and sold by Altera or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: create_Quartus_project.tcl
# Generated on: Wed Aug 03 22:06:48 2016

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "MusicBoxNano"]} {
		puts "Project MusicBoxNano is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists MusicBoxNano]} {
		project_open -revision MusicBoxNano MusicBoxNano
	} else {
		project_new -revision MusicBoxNano MusicBoxNano
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE22F17C6
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 16.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "23:11:43  JULY 25, 2016"
	set_global_assignment -name LAST_QUARTUS_VERSION 16.0.0
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 6
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "NO HEAT SINK WITH STILL AIR"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name TIMEQUEST_DO_REPORT_TIMING ON
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name USE_SIGNALTAP_FILE output_files/stp1.stp
	set_global_assignment -name SDC_FILE ./constraints/MusicBoxNano.sdc
	set_global_assignment -name QIP_FILE ./ip/WaveformROM.qip -library work
	set_global_assignment -name QIP_FILE ./ip/WaveAddrMux.qip -library work
	set_global_assignment -name QIP_FILE ./ip/SongROM.qip -library work
	set_global_assignment -name QIP_FILE ./ip/KeyToFreqROM.qip -library work
	set_global_assignment -name QIP_FILE ./ip/EnvelopeROM.qip -library work
	set_global_assignment -name QIP_FILE ./ip/EnvAddrMux.qip -library work
	set_global_assignment -name QIP_FILE ./ip/ClocksPLL.qip -library work
	set_global_assignment -name VHDL_FILE ./hdl/SongDB.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/ResetSync.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/PWMGenerator.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/MusicBoxNano.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/MusicBoxDDS.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/MusicBoxClocking.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/Helpers_Pkg.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/DDSAddressGenerator.vhd -library work
	set_global_assignment -name VHDL_FILE ./hdl/CrossClockDomain.vhd -library work
	set_location_assignment PIN_E1 -to Button_DI[1]
	set_location_assignment PIN_J15 -to Button_DI[0]
	set_location_assignment PIN_R8 -to CLOCK_50
	set_location_assignment PIN_L3 -to Led_DO[7]
	set_location_assignment PIN_B1 -to Led_DO[6]
	set_location_assignment PIN_F3 -to Led_DO[5]
	set_location_assignment PIN_D1 -to Led_DO[4]
	set_location_assignment PIN_A11 -to Led_DO[3]
	set_location_assignment PIN_B13 -to Led_DO[2]
	set_location_assignment PIN_A13 -to Led_DO[1]
	set_location_assignment PIN_A15 -to Led_DO[0]
	set_location_assignment PIN_A14 -to PWMOut_DO
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
