#! /bin/bash
# generate subregion tractography
# 2014.4.3 by Hai Li


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
switch=(11 12)

# 11) transform subregions from MNI space to DTI space
if [[ ${switch[@]/11/} != ${switch[@]} ]]; then
echo "=== 11_subregion_toDTI start! ==="
${pipeline}/11_subregion_toDTI.sh ${CIVET_DIR} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${parallel}
echo "11_subregion_toDTI done!" >> ${WD}/log/progress_check.txt
fi

# 12) subregions probtrackx, with no distanc correction
if [[ ${switch[@]/12/} != ${switch[@]} ]]; then
echo "=== 12_subregion_probtrackx start! ==="
${pipeline}/12_subregion_probtrackx.sh ${DATA_DIR} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM}
echo "12_subregion_probtrackx done!" >> ${WD}/log/progress_check.txt
fi


