#! /bin/bash
# DTI-based parcellation pipeline for specific brain region
# 2014.1.9 by Hai Li


#==============================================================================
# Prerequisites:
# 1) Tools: FSL, MINC Toolbox and MATLAB(with NIfTI toolbox)
# 2) Data files:
#    > T1 image for each subject
#    > normalized T1 image preprocessed by CIVET for each subject
#    > DTI images preprocessed by FSL(eddy correct, bedpostx) for each subject
#==============================================================================

#================================================================
# The variables below MUST be set before running the pipeline
#================================================================
# pipeline scripts directory
pipeline=$1
# working directory
WD=$3
# data directory
DATA_DIR=$5
# CIVET directory
CIVET_DIR=$6
# prefix for data preprocessed by CIVET
PREFIX=$7
# brain region name
PART=$2
# subject list
SUB_LIST=$8
# Left ROI in MNI space, mnc format
ROI_L=${WD}/ROI/${PART}_L.nii
# Right ROI in MNI space, mnc format
ROI_R=${WD}/ROI/${PART}_R.nii
# Max cluster number
MAX_CL_NUM=$4
#parallel workers for shell scripts
parallel=$9
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
. /DATA/233/hli/toolbox/minc/minc-toolkit-config.sh
. /opt/sge/default/common/settings.sh

echo "!!!${PART}@`hostname`!!!"

#================================================================
#---------------------------Pipeline-----------------------------
#================================================================ 

# switch for each step,
# a step will NOT run if its number is NOT in the following array
switch=(1 2 3)


# 1) ROI registration, from MNI space to DTI space
#if [[ ${switch[@]/1/} != ${switch[@]} ]]; then
#echo "=== 1_ROI_registration start! ==="
#${pipeline}/1_ROI_registration.sh ${WD} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${ROI_L} ${ROI_R} ${parallel}
#echo "1_ROI_registration done!" > ${WD}/log/progress_check.txt
#fi

# 1) ROI registration, from MNI space to DTI space, using spm batch
if [[ ${switch[@]/1/} != ${switch[@]} ]]; then
echo "=== 1_ROI_registration_spm start! ==="
${pipeline}/1_ROI_registration_spm.sh ${pipeline} ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST} ${ROI_L} ${ROI_R}
echo "1_ROI_registration_spm done!" > ${WD}/log/progress_check.txt
fi

# 2) calculate ROI coordinates in DTI space
if [[ ${switch[@]/2/} != ${switch[@]} ]]; then
echo "=== 2_ROI_calc_coord start! ==="
${pipeline}/2_ROI_calc_coord.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST}
echo "2_ROI_calc_coord done!" >> ${WD}/log/progress_check.txt
fi

# 3) generate probabilistic tractography for each voxel in ROI
#    5000 samples for each voxel, with distance correction
if [[ ${switch[@]/3/} != ${switch[@]} ]]; then
echo "=== 3_ROI_probtrack start! ==="
${pipeline}/3_ROI_probtrackx.sh ${WD} ${DATA_DIR} ${PREFIX} ${PART} ${SUB_LIST}
echo "3_ROI_probtrackx done!" >> ${WD}/log/progress_check.txt
fi
