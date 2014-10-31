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
switch=(13 14 15)

# 13) threshold the result of probtrackx
if [[ ${switch[@]/13/} != ${switch[@]} ]]; then
echo "=== 13_probtrackx_thres start! ==="
${pipeline}/13_probtrackx_thres.sh ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${p} ${sample} ${parallel}
echo "13_probtrackx_thres done!" >> ${WD}/log/progress_check.txt
fi

# 14) transform the result of probtrackx from DTI space to MNI space
if [[ ${switch[@]/14/} != ${switch[@]} ]]; then
echo "=== 14_probtrackx_toMNI start! ==="
${pipeline}/14_probtrackx_toMNI.sh ${CIVET_DIR} ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${parallel}
echo "14_probtrackx_toMNI done!" >> ${WD}/log/progress_check.txt
fi

# 15) average, normalize and generate the probilistic maps of the group results
if [[ ${switch[@]/15/} != ${switch[@]} ]]; then
echo "=== 15_probtrackx_pm start! ==="
${pipeline}/15_probtrackx_pm.sh ${WD} ${PREFIX} ${PART} ${SUB_LIST} ${CL_NUM} ${thres}
echo "15_probtrackx_pm done!" >> ${WD}/log/progress_check.txt
fi



echo "-----------------------------------------------------------------------"
echo "--------------All Done!! Please check the result images----------------"
echo "-----------------------------------------------------------------------"
