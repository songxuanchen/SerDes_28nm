####################################
#
# set the power analysis mode
#
####################################
#
set power_enable_analysis TRUE

set power_analysis_mode averaged
#set power_analysis_mode  time_based

####################################
#
# read and link the gate level netlist
#
####################################
#
set DesignTopName top;#必改项

set DW_Path /opt/synopsys/syn_2018.06/syn/O-2018.06-SP1/libraries/syn
set Data_Path /home/usergq/IC_prj/SerDes_28nm/MUX_128_70/pwr/data
set StdPath /home/usergq/RFID_SMIC28_lib/SCC28NHKCP_HDC30P140_RVT_V0p2/liberty/0.9v 
set RptFilePath /home/usergq/IC_prj/SerDes_28nm/MUX_128_70/pwr/rpt
set lib_Path /home/usergq/IC_prj/SerDes_28nm/MUX_128_70/pwr/data/lib


set search_path ". \
                $DW_Path \
                $Data_Path\
		        $StdPath \
                $lib_Path"

#set target_library "sc9mc_logic0040ll_base_rvt_c50_tt_typical_max_1p20v_125c.db"

#set link_library "* \ sc9mc_logic0040ll_base_rvt_c50_tt_typical_max_1p20v_125c.db\
               #    rom_1024x32_tt_1p20v_1p20v_125c.db\
		  # sram_2048x32_tt_1p20v_1p20v_125c.db\
               #    dw_foundation.sldb"
               #
#设置工艺角
set corner tt
#set corner ff
#set corner ffg
#set corner ss
#set corner ssg

#设置电压域
set voltage v0p9
#set voltage v0p99
#set voltage v0p81

#设置工作温度
#set temperature 0c
set temperature 25c
#set temperature 85c
#set temperature -40c
#set temperature 125c

#设置线负载模型
set wire_load_model basic
#set wire_load_model ccs
#set wire_load_model ecsm

#打开对应lib文件，检索operating_conditions，（）中即为此处所需--感觉变量可以删除
set OptCond ${corner}_${voltage}_${temperature}

set LibName scc28nhkcp_hdc30p140_rvt_${corner}_${voltage}_${temperature}_${wire_load_model}

set LibDbFile  ${LibName}.db

#set link_path     "* \
#            $LtLibDbFile \
#			$BcLibDbFile \
#			$MlLibDbFile \
# 			$TcLibDbFile \
#			$WcLibDbFile \
#			$WclLibDbFile \
#			"
set link_library "* $LibDbFile"

#set link_library "sc9mc_logic0040ll_base_rvt_c50_tt_typical_max_1p20v_125c.db"

#read_verilog /home/rfid/zilong/power_analyse/data/top_soc_xcs_syn.v

read_verilog $Data_Path/${DesignTopName}_syn.v

current_design $DesignTopName

link
#
####################################
#
# READ SDC and set transition time or annotate parasitics
#
####################################
#
#read_sdc  /home/rfid/zilong/power_analyse/data/top_soc_xcs_SYN.sdc -echo

read_sdc $Data_Path/${DesignTopName}_SYN.sdc -echo

####################################
#
# analysis the toggle rate according to VCD
#
####################################
#
set ClkFrequency 20
set CycleSize [ expr 1000.0/${ClkFrequency} ]

write_activity_waveforms -output ${DesignTopName}.report_ToggleRate -vcd ${Data_Path}/${DesignTopName}.vcd -interval ${CycleSize}

redirect $RptFilePath/${DesignTopName}.report_ToggleRate { report_activity_waveforms }
#
####################################
#
# Check,update,or report timing
#
####################################
#
check_timing

update_timing

#report_timing
redirect $RptFilePath/${DesignTopName}.report_timing { report_timing }

#
####################################
#
# read switching activity file
#
####################################
read_vcd -rtl ./data/${DesignTopName}.vcd  -strip_path  tb/u_${DesignTopName}
#read_fsdb "../../CNN_Tape_out/post_sim_10-16_50MHz/CNN_rcmin125c_ss0p99125c_tb.fsdb" -strip_path  "testbench/the_inst_CNN"
#read_fsdb "./data/Decoder.fsdb" -strip_path "Decoder_tb/u_Decoder"
report_switching_activity -list_not_annotated
#report_annotated_power -list_not_annotated:
#
####################################
#
check_power

update_power

#set_power_analysis_options -waveform_format fsdb -waveform_output ${DesignTopName}_pt

#report_power -hierarchy
redirect $RptFilePath/${DesignTopName}.report_power { report_power -hierarchy }

####################################
#
# exit
#
####################################
#
exit
