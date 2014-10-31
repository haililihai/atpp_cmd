#! /bin/bash
# DTI-based parcellation pipeline for specific brain region
# 2014.1.9 by Hai Li


#==============================================================================
# Prerequisites:
# 1) Tools: FSL, MINC Toolbox and MATLAB(with NIfTI toolbox)
# 2) Data files:
#    > T1 image for each subject
#	 > normalized T1 image preprocessed by CIVET for each subject
# 	 > DTI images preprocessed by FSL(eddy correct, bedpostx) for each subject
#==============================================================================


#================================================================
# The variables below MUST be set before running the pipeline
#================================================================
# pipeline scripts directory
pipeline=$1
# working directory
WD=$3
# data directory
DATA_DIR=$6
# CIVET directory
CIVET_DIR=$7
# prefix for data preprocessed by CIVET
PREFIX=$8
# brain region name
PART=$2
# subject list
SUB_LIST=$9
# Left ROI in MNI space, mnc format
ROI_L=${WD}/ROI/${PART}_L.mnc
# Right ROI in MNI space, mnc format
ROI_R=${WD}/ROI/${PART}_R.mnc
# Max cluster number
MAX_CL_NUM=$4
# Cluster number
CL_NUM=$5
#parallel workers for shell scripts
parallel=$10
#================================================================


#================================================================
# Environment variables
#================================================================
LOCAL_soft=/mnt/software
alias matlab='${LOCAL_soft}/matlab/bin/matlab'
FSLDIR=${LOCAL_soft}/fsl5.0
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:${LOCAL_soft}/lib:${LOCAL_soft}/fsl/
export PATH=$PATH:/usr/lib/x86_64-linux-gnu/
export PATH=$PATH:$LOCAL_soft/afni64
export PATH=$PATH:$LOCAL_soft/matlab/bin
source /DATA/233/hli/toolbox/minc/minc-toolkit-config.sh
source /opt/sge/default/common/settings.sh

echo "!!!${PART}@`hostname`!!!"

#================================================================
#---------------------------Pipeline-----------------------------
#================================================================ 

# switch for each step,
# a step will NOT run if its number is NOT in the following array
switch=(6 7 8 9 10)

# 4) calculate connectivity matrix between each voxel in ROI and the remain voxels of whole brain 
#	 and correlation matrix among voxels in ROI
#    downsample to 5mm isotropic voxels
if [[ ${switch[@]/4/} != ${switch[@]} ]]; then
echo "=== 4_ROI_calc_matrix start! ==="
${pipeline}/4_ROI_calc_matrix.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST}
echo "4_ROI_calc_matrix done!" >> ${WD}/log/progress_check.txt
fi

# 5) ROI parcellation using spectral clustering, to generate 2 to max cluster number subregions
if [[ ${switch[@]/5/} != ${switch[@]} ]]; then
echo "=== 5_ROI_parcellation start! ==="
${pipeline}/5_ROI_parcellation.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM}
echo "5_ROI_parcellation done!" >> ${WD}/log/progress_check.txt
fi

# 6) transform parcellated ROI from DTI space to MNI space
#if [[ ${switch[@]/6/} != ${switch[@]} ]]; then
#echo "=== 6_ROI_toMNI start! ==="
#${pipeline}/6_ROI_toMNI.sh ${WD} ${CIVET_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM} ${parallel}
#echo "6_ROI_toMNI done!" >> ${WD}/log/progress_check.txt
#fi

# 6) transform parcellated ROI from DTI space to MNI space
if [[ ${switch[@]/6/} != ${switch[@]} ]]; then
echo "=== 6_ROI_toMNI_spm start! ==="
${pipeline}/6_ROI_toMNI_spm.sh ${pipeline} ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM}
echo "6_ROI_toMNI_spm done!" >> ${WD}/log/progress_check.txt
fi

# 7) calculate group reference image to prepare for the relabel step
#	 !!the cluster number CL_NUM you want to parcellate should be set!!
#    threshold at 0.5
if [[ ${switch[@]/7/} != ${switch[@]} ]]; then
echo "=== 7_group_refer start! ==="
${pipeline}/7_group_refer_L.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "7_group_refer_L done!" >> ${WD}/log/progress_check.txt
${pipeline}/7_group_refer_R.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "7_group_refer_R done!" >> ${WD}/log/progress_check.txt
fi

# 8) cluster relabeling according to the group reference image
if [[ ${switch[@]/8/} != ${switch[@]} ]]; then
echo "=== 8_cluster_relabel start! ==="
${pipeline}/8_cluster_relabel.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "8_cluster_relabel done!" >> ${WD}/log/progress_check.txt
fi

# 9) generate maximum probability map for ROI and probabilistic maps for each subregion
#    threshold at 0.5
if [[ ${switch[@]/9/} != ${switch[@]} ]]; then
echo "=== 9_calc_mpm_L start! ==="
${pipeline}/9_calc_mpm_L.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "9_calc_mpm_L done!" >> ${WD}/log/progress_check.txt
${pipeline}/9_calc_mpm_R.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "9_calc_mpm_R done!" >> ${WD}/log/progress_check.txt
fi

# 10) smooth the mpm image
if [[ ${switch[@]/10/} != ${switch[@]} ]]; then
echo "=== 10_postprocess_mpm start! ==="
${pipeline}/10_postprocess_mpm.sh ${pipeline} ${WD} ${PART} ${CL_NUM}
echo "10_postprocess_mpm done!" >> ${WD}/log/progress_check.txt
fi

echo "-----------------------------------------------------------------------"
echo "--------------All Done!! Please check the result images----------------"
echo "-----------------------------------------------------------------------"
