#!/bin/csh

set disk = `echo $PWD | awk -F \/ '{print $3} '`
set milestone = `echo $PWD | awk -F \/ '{print $4} '`
set HLB = `echo $PWD | awk -F \/ '{print $5} '`
set NET = `echo $PWD | awk -F \/ '{print $6} '`
set Lxx_Jxx_Exx = `echo $PWD | awk -F \/ '{print $7} '`
set Exx = `echo $Lxx_Jxx_Exx | awk -F \_ '{print $3} '`
################################################################################################################

set ICC2_ROOT_DIR = /fs/${disk}/${milestone}/${HLB}

if ($disk == argo_imps10 || $disk == argo_imps26） then
  set disk_post_veri = argo_imps21
  set disk_STA = argo_imps21
endif

if ($disk == argo_imps05 || $disk == argo_imps24） then
  set disk_post_veri = argo_imps14
  set disk_STA = argo_imps14
endif

if ($HLB == L_CP_VDSP || $HLB == L_MP_VCD || $HLB == Xm_ADSP1Xtsubsystem) then
  set disk_post_veri = argo_imps32
  set disk_STA = argo_imps32
endif

if ($HLB == IK_PCIe_G3X1 || $HLB == IK_PCIe_G3X2_0 || $HLB == IK_PCIe_G3X2_1 || $HLB == SNIHSAGECRX || $HLB == SNIHSAGECTX || $HLB == CA53_SS || $HLB == HDMI_WRAP || $HLB == IK_PCIe_G3X4_0 || $HLB == VCD_CORE_HLG_VCD_0 || VCD_CORE_HLG_VCD_1) then
  set disk_STA = argo_imps56
endif

set ROOT_DIR = /fs/${disk_post_veri}/${milestone}/${HLB}
set ROOT_STA_DIR = /fs/${disk_STA}/${milestone}/${HLB}
###############################################################################################################

set ICC2_DIR = ${ICC2_ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/ICC2

if (! -e ${ICC2_DIR} ) then
  echo "Error! ICC2 dir is not found : $ICC2_DIR"
exit
endif

echo "$HLB $Lxx_Jxx_Exx"
echo "ICC2: ${ICC2_DIR}"
echo "STA: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/STA"
echo "Spyglass: $(ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/Spyglass“
echo "FV: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/FV"
echo "PV: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/PV"
echo " "
sleep 5;
##############################################################################################################

###################################
## 1-1. STA/SG/FV/PV preparation ##
###################################
if（！ -d $(ROOT_DIR} ) then
mkdir ${ROOT_DIR}
endif

if （！-d ${ROOT_STA_DIR} ) then
mkdir ${ROOT_STA_DIR}
endif

cd ${ROONT_STA_DIR}
  mkdir -p ${NET}
  mkdir -p ${NET}/${Lxx_Jxx_Exx}
  mkdir -p ${NET}/${Lxx_Jxx_Exx}/STA
cd ${NET}/${Lxx_Jxx_Exx}/STA

if (! -d nonsdf) then
  csh /h/cel/arg_k23/setup_STA_tighten.csh
else
  echo "STA directory existed"
endif

#####################
## 2-0. ECO (ICC2) ##
#####################
cd ${ICC_DIR}
if ( -f write_data ) then
  rm -f write_data
endif
clear

if ($Exx != E00) then
  sed -i 's#set TIMING_ECO_MODE.*#set TIMING_ECO_MODE    "ON"#' rm_setup/design_setup.tcl
endif

echo "pnr/eco_job_launch"
csh ./exe_batch_fc_pnr.csh

sleep 10 ;

echo "$HLB $Lxx_Jxx_Exx"
echo "ICC2: ${ICC2_DIR}"
echo "STA: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/STA"
echo "Spyglass: $(ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/Spyglass“
echo "FV: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/FV"
echo "PV: ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/PV"

#######################
## 3-0. Run SG/FV/PV ##
#######################
set flag = ${ICC2_DIR}/write_data

while ( ! -e $flag )
  echo "Waiting $flag `date`"
  sleep 600
end
clear
echo "Done write_data"

############    
## RUN_FV ##
############
cd ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/FV
echo "Launching FV"
csh ./01_run_fv

############
## RUN_PV ##
############
cd ${ROOT_DIR}/${NET}/${Lxx_Jxx_Exx}/PV
set Lxx_Jxx_Exx_PV = `glob ${Lxx_Jxx_Exx}*`
cd ${Lxx_Jxx_Exx_PV}
echo "Launching PV"
xterm -bg black -fg orange -geometry 140x20 -title PV_run -e "./go_all" &

##################
## RUN SPEF&STA ##
##################
cd ${ROOT_STA_DIR}/${NET}/${Lxx_Jxx_Exx}/STA
echo "Launching STAR & STA"
xterm -bg black -fg orange -geometry 140x20 -title STA_run -e "./Go_star_nonsdf_coredmsa" &

##################
## RUN_SPYGLASS ##
##################
cd ${ROOT_STA_DIR}/${NET}/${Lxx_Jxx_Exx}/Spyglass
echo "Launching Spyglass"
csh ./RUN_SG.csh

cd ${ICC2_DIR}
