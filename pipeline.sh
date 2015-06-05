#! /bin/bash

# Automatic Tractography-based Parcellation Pipeline (ATPP)
# pipeline file
# 2014.7.13 by Hai Li

PIPELINE=$1
WD=$2 
DATA_DIR=$3
PREFIX=$4
PART=$5
SUB_LIST=$6
MAX_CL_NUM=$7
CL_NUM=$8

# fetch the variables
source ${PIPELINE}/config.sh

# show the host
echo "!!! ${PART}@$(hostname)__$(date +%F_%T) !!!" |tee -a ${WD}/log/progress_check.txt


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
${PIPELINE}/1_ROI_registration_spm.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${POOLSIZE} ${SPM} ${TEMPLATE}  ${LEFT} ${ROI_L} ${RIGHT} ${ROI_R}
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
${PIPELINE}/5_ROI_parcellation.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${POOLSIZE} ${METHOD} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 5_ROI_parcellation done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 6) transform parcellated ROI from DTI space to MNI space
if [[ ${SWITCH[@]/_6_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 6_ROI_toMNI_spm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/6_ROI_toMNI_spm.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${SPM} ${POOLSIZE} ${TEMPLATE} ${VOX_SIZE} ${METHOD} ${LEFT} ${RIGHT}
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
${PIPELINE}/7_ROI_group_refer.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${NIFTI} ${METHOD} ${VOX_SIZE} ${GROUP_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 7_ROI_group_refer done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 8) cluster relabeling according to the group reference image
if [[ ${SWITCH[@]/_8_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 8_cluster_relabel start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/8_cluster_relabel.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${NIFTI} ${POOLSIZE} ${GROUP_THRES} ${METHOD} ${VOX_SIZE} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 8_cluster_relabel done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 9) generate maximum probability map for ROI and probabilistic maps for each subregion
#    default threshold at 0.5
if [[ ${SWITCH[@]/_9_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 9_calc_mpm start! ==="  |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/9_calc_mpm.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${NIFTI} ${METHOD} ${MPM_THRES} ${VOX_SIZE} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 9_calc_mpm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 10) smooth the mpm image
if [[ ${SWITCH[@]/_10_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 10_postprocess_mpm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/10_postprocess_mpm.sh ${PIPELINE} ${WD} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${NIFTI} ${MPM_THRES} ${VOX_SIZE} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 10_postprocess_mpm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 11) validation
if [[ ${SWITCH[@]/_11_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 11_validation start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/11_validation.sh ${PIPELINE} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${METHOD} ${VOX_SIZE} ${MAX_CL_NUM} ${N_ITER} ${MPM_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 11_validation done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 12) plot indice
if [[ ${SWITCH[@]/_12_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 12_indice_plot start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/12_indice_plot.sh ${PIPELINE} ${WD} ${PART} ${SUB_LIST} ${VOX_SIZE} ${MAX_CL_NUM} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 12_indice_plot done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 13) transform subregions from MNI space to DTI space
if [[ ${SWITCH[@]/_13_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 13_subregion_toDTI_spm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/13_subregion_toDTI_spm.sh ${PIPELINE} ${WD} ${PART} ${SUB_LIST} ${CL_NUM} ${TEMPLATE} ${VOX_SIZE} ${MPM_THRES} ${POOLSIZE} ${SPM} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 13_subregion_toDTI_spm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 14) generate probabilistic tractography for each subregion
#    default 5000 samples for each voxel, WITHOUT distance correction
if [[ ${SWITCH[@]/_14_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 14_subregion_probtrack start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/14_subregion_probtrackx.sh ${WD} ${DATA_DIR} ${PART} ${SUB_LIST} ${CL_NUM} ${VOX_SIZE} ${MPM_THRES} ${N_SAMPLES} ${DIS_COR} ${LEN_STEP} ${N_STEPS} ${CUR_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 14_subregion_probtrackx done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 15) transform probtrackxs from DTI space to MNI space
if [[ ${SWITCH[@]/_15_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 15_probtrackx_toMNI_spm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/13_probtrackx_toMNI_spm.sh ${PIPELINE} ${WD} ${PART} ${SUB_LIST} ${CL_NUM} ${TEMPLATE} ${VOX_SIZE} ${MPM_THRES} ${N_SAMPLES} ${P} ${POOLSIZE} ${SPM} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 15_probtrackx_toMNI_spm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

# 16) generate the probabilistic maps of probtrackxs
if [[ ${SWITCH[@]/_16_/} != ${SWITCH[@]} ]]; then
echo "$(date +%T)  === 16_probtrackx_pm start! ===" |tee -a ${WD}/log/progress_check.txt
T="$(date +%s)"
${PIPELINE}/16_probtrackx_pm.sh ${WD} ${PART} ${SUB_LIST} ${CL_NUM} ${PM_THRES} ${LEFT} ${RIGHT}
T="$(($(date +%s)-T))"
echo "$(date +%T)  === 16_probtrackx_pm done! ===" |tee -a ${WD}/log/progress_check.txt
printf "Time elapsed: %02d:%02d:%02d:%02d\n\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" |tee -a ${WD}/log/progress_check.txt
fi

echo "-------------------------------------------------------------------------"
echo "----------------All Done!! Please check the result images----------------"
echo "-------------------------------------------------------------------------"
