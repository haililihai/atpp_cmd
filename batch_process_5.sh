#! /bin/bash
# generate stability indice
# 2014.5.18 by Hai Li


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
# p-value to threshold the result of probtrackx
p=0.0004
# samples in probtrackx
sample=5000
# threshold to generate probilistic maps
thres=0.5
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
switch=(16 17)

# 16) generate stability indice
if [[ ${switch[@]/16/} != ${switch[@]} ]]; then
echo "=== 16_cross_validation_L start! ==="
${pipeline}/16_cross_validation_L.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM}
echo "16_cross_validation_L done!" >> ${WD}/log/progress_check.txt
echo "=== 16_cross_validation_R start! ==="
${pipeline}/16_cross_validation_R.sh ${pipeline} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${MAX_CL_NUM}
echo "16_cross_validation_R done!" >> ${WD}/log/progress_check.txt
fi

# 17) plot
if [[ ${switch[@]/17/} != ${switch[@]} ]]; then
echo "=== 17_indice_plot start! ==="
${pipeline}/17_indice_plot.sh ${pipeline} ${WD} ${PART} ${MAX_CL_NUM}
echo "17_indice_plot done!" >> ${WD}/log/progress_check.txt
fi

echo "-----------------------------------------------------------------------"
echo "--------------All Done!! Please check the result images----------------"
echo "-----------------------------------------------------------------------"
