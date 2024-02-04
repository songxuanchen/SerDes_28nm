#######################################################
# FileName : ComEnvSetup.tcl                          #
# Project  : self_sync_scrambler                      #
# Tech Lib : SMIC 28nm                                #
# Syntax   : Tcl language                             #
# Author   : Song Xuanchen                            #
# Date     : 1-FEB-2024                               #
# Description:                                        #
# set variables used in the whole design flow         #
#######################################################

#######################################################
# Define global path variables
#######################################################
set DesignTopName top;#�ظ���
set ProjPath /home/ICer/IC_prj/SerDes_28nm/MUX_128_70;#�ظ���
set StdPath /home/ic_libs/SMIC_28/SCC28NHKCP_HDC30P140_RVT_V0p2/liberty/0.9v 
set LibTemp $ProjPath/syn/LibTemp	;#�Ǳ��������Ϊ�������ļ�ʱ��ı�ѡ·��
set SrcPath $ProjPath/src
set SdcPath $ProjPath/sdc
set PnrPath $ProjPath/pnr

#######################################################
# DesignWare directory
#######################################################
#set DWPath /edatools/snps/syn10.03-SP5/libraries/syn
#set DWROOT /edatools/snps/syn10.03-SP5
set DWPath /home/synopsys/syn/O-2018.06-SP1/libraries/syn
#set current_dc_shell_path [exec which dc_shell-t]
#set DWROOT [string range $current_dc_shell_path 0 [expr [string first "/${sh_arch}" $current_dc_shell_path] - 1]]
#set DWPath ${DWROOT}/libraries/syn

set search_path ". \
                $SrcPath \
                $StdPath \
                $LibTemp \
		        $DWPath \
    "
#######################################################
# Define library variables
#######################################################
# WLM declaration
#set WireLoadModelName ZeroWireload
#set WireLoadModeName segmented

#���ù��ս�
set corner tt
#set corner ff
#set corner ffg
#set corner ss
#set corner ssg

#���õ�ѹ��
set voltage v0p9
#set voltage v0p99
#set voltage v0p81

#���ù����¶�
#set temperature 0c
set temperature 25c
#set temperature 85c
#set temperature -40c
#set temperature 125c

#�����߸���ģ��
set wire_load_model basic
#set wire_load_model ccs
#set wire_load_model ecsm

#�򿪶�Ӧlib�ļ�������operating_conditions�������м�Ϊ�˴�����--�о���������ɾ��
set OptCond ${corner}_${voltage}_${temperature}

set LibName scc28nhkcp_hdc30p140_rvt_${corner}_${voltage}_${temperature}_${wire_load_model}

set LibDbFile  ${LibName}.db

set LibList [list \
    $LibDbFile\
    ]    

#dw_foundation.sldb��Synopsys�ṩ����ΪDesignWare���ۺϿ⣬
#�������˻��������������߼��������߼������ۺϴ洢����IP��
#���ۺ��ǵ�����ЩIP��������ߵ�·���ܺͼ����ۺ�ʱ��
set DwLibList [list \
    dw_foundation.sldb \
]
#######################################################
# Define operating envirement variables
#######################################################
#set PortDriveCell PCI6BSW INV0_8TR40
#set PortDrivePin PAD
#set PortLoad PCI6BSW

set PortDriveCell BUFV12_140P7T30R 
set PortDrivePin I
set PortLoad BUFV12_140P7T30R

#######################################################
# Clock gating varailbes define
#######################################################
set ClockGatingFanout 16
set ClockGatingSetup  0.1
set ClockGatingHold   0.1
set ClockGatingMinNum 4
#######################################################
# Variables about EDA tools
#######################################################
set sh_enable_page_mode true	;#��ҳ��ʾ
set designer {STLE:Song Xuanchen}
set company "WXT"

alias h history
alias page_on {set sh_enable_page_mode true}
alias page_off {set sh_enable_page_mode false}
alias all_gone {remove_design -all}
history keep 100
set collection_result_display_limit 500
page_off

#######################################################
# File End
#######################################################
