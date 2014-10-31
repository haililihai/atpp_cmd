#! /bin/bash

# Automatic Tractography-based Parcellation Pipeline (ATPP)
# pipeline file
# 2014.7.13 by Hai Li

PIPELINE=$1
shift
WD=$1
shift
DATA_DIR=$1
shift
PREFIX=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
MAX_CL_NUM=$1
shift
CL_NUM=$1

# fetch the variables
source ${PIPELINE}/config.sh

# show the host
echo "!!! ${PART}_${CL_NUM}@$(hostname)__$(date +%F_%T) !!!" |tee -a ${WD}/log/progress_check.txt


#===============================================================================
#--------------------------------Pipeline---------------------------------------
#------------NO EDITING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING----------------
#===============================================================================

#in case of errors 
SWITCH=(${SWITCH[@]/#/_}) #add a _ before step
SWITCH=(${SWITCH[@]/%/_}) #add a _ after step

# 0) generate the working directory
if [[ ${SWITCH[@]/_0_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 0_gen_WD start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/0_gen_WD.sh ${WD} ${DATA_DIR} ${PART} ${SUB_LIST} ${ROI_DIR}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 0_gen_WD done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 1) ROI registration, from MNI space to DTI space, using spm batch
if [[ ${SWITCH[@]/_1_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 1_ROI_registration_spm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/1_ROI_registration_spm.sh ${PIPELINE} ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${POOLSIZE} ${SPM} ${TEMPLATE}  ${LEFT} ${ROI_L} ${RIGHT} ${ROI_R}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 1_ROI_registration_spm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 2) calculate ROI coordinates in DTI space
if [[ ${SWITCH[@]/_2_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 2_ROI_calc_coord start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/2_ROI_calc_coord.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${POOLSIZE} ${NIFTI} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 2_ROI_calc_coord done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 3) generate probabilistic tractography for each voxel in ROI
#    default 5000 samples for each voxel, with distance correction
if [[ ${SWITCH[@]/_3_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 3_ROI_probtrack start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/3_ROI_probtrackx.sh ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${N_SAMPLES} ${DIS_COR} ${LEN_STEP} ${N_STEPS} ${CUR_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 3_ROI_probtrackx done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 4) calculate connectivity matrix between each voxel in ROI and the remain voxels of whole brain 
#	 and correlation matrix among voxels in ROI
#    downsample to 5mm isotropic voxels
if [[ ${SWITCH[@]/_4_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 4_ROI_calc_matrix start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/4_ROI_calc_matrix.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${POOLSIZE} ${NIFTI} ${VAL_THRES} ${DOWN_SIZE} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 4_ROI_calc_matrix done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 5) ROI parcellation using spectral clustering, to generate 2 to max cluster number subregions
if [[ ${SWITCH[@]/_5_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 5_ROI_parcellation start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/5_ROI_parcellation.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${NIFTI} ${POOLSIZE} ${METHOD} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 5_ROI_parcellation done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 6) transform parcellated ROI from DTI space to MNI space
if [[ ${SWITCH[@]/_6_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 6_ROI_toMNI_spm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/6_ROI_toMNI_spm.sh ${PIPELINE} ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${SPM} ${POOLSIZE} ${TEMPLATE} ${VOX_SIZE} ${METHOD} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 6_ROI_toMNI_spm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 7) calculate group reference image to prepare for the relabel step
#	 !!the cluster number CL_NUM you want to parcellate should be set!!
#    threshold at 0.5
if [[ ${SWITCH[@]/_7_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 7_ROI_group_refer start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/7_ROI_group_refer.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${NIFTI} ${METHOD} ${GROUP_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 7_ROI_group_refer done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 8) cluster relabeling according to the group reference image
if [[ ${SWITCH[@]/_8_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 8_cluster_relabel start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/8_cluster_relabel.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${NIFTI} ${POOLSIZE} ${GROUP_THRES} ${METHOD} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 8_cluster_relabel done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 9) generate maximum probability map for ROI and probabilistic maps for each subregion
#    default threshold at 0.5
if [[ ${SWITCH[@]/_9_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 9_calc_mpm start! ==="  |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/9_calc_mpm.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${NIFTI} ${METHOD} ${MPM_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 9_calc_mpm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 10) smooth the mpm image
if [[ ${SWITCH[@]/_10_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 10_postprocess_mpm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/10_postprocess_mpm.sh ${PIPELINE} ${WD} ${PART} ${CL_NUM} ${NIFTI} ${MPM_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 10_postprocess_mpm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 16) cross validation
if [[ ${SWITCH[@]/_16_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 16_cross_validation start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/16_cross_validation.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${N_ITER} ${GROUP_THRES} ${MPM_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 16_cross_validation done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 17) plot indice
if [[ ${SWITCH[@]/_17_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 17_indice_plot start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/17_indice_plot.sh ${PIPELINE} ${WD} ${PART} ${MAX_CL_NUM}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 17_indice_plot done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

echo "-------------------------------------------------------------------------"
echo "----------------All Done!! Please check the result images----------------"
echo "-------------------------------------------------------------------------"
