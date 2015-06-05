#! /bin/bash

# Automatic Tractography-based Parcellation Pipeline (ATPP)
# global configuration file that includes all the variables
# 2014.7.13 by Hai Li


#===============================================================================
# global paths and variables settings
#===============================================================================

# pipeline directory
PIPELINE=/DATA/233/hli/ATPP_test

# ROI directory which contains ROI files, e.g., Amyg_L.nii
ROI_DIR=/DATA/233/hli/BA_fs/ROI/1mm

# Left ROI in MNI space, nii format 
ROI_L=${WD}/ROI/${PART}_L.nii

# Right ROI in MNI space
ROI_R=${WD}/ROI/${PART}_R.nii

# the number of parallel workers for MATLAB programs, default 7
POOLSIZE=7

#===============================================================================
# global switches for the pipeline
#===============================================================================

# switches for each step,
# a step will NOT run if its number is NOT in the following array
# 0 -- generate the working directory, NEED to modify
# 1 -- ROI registration, from MNI space to DTI space, using spm batch
SWITCH=(5)

# switch for processing left hemisphere, 1--yes, 0--no
LEFT=1

# switch for processing right hemisphere, 1--yes, 0--no
RIGHT=1

#===============================================================================
# specific variables for some steps
#===============================================================================

# 1_ROI_registration_spm, SPM directory
SPM=/DATA/233/hli/toolbox/spm8

# 1_ROI_registration_spm, 6_ROI_toMNI_spm, template image
TEMPLATE=${DATA_DIR}/HCP40_MNI_1.25mm.nii

# 2_ROI_calc_coord, NIFTI toolbox directory
NIFTI=/DATA/233/hli/toolbox

# 3_ROI_probtrackx, Number of samples, default 5000
N_SAMPLES=5000

# 3_ROI_probtrackx, 14_subregion_probtrackx, distance correction, yes--(--pd), no--( )space
DIS_COR=--pd

# 3_ROI_probtrackx, the length of each step, default 0.5 mm
LEN_STEP=0.5

# 3_ROI_probtrackx, maximum number of steps, default 2000
N_STEPS=2000

# 3_ROI_probtrackx, curvature threshold (cosine of degree), default 0.2
CUR_THRES=0.2

# 4_ROI_calc_matrix, value threshold, default 10
VAL_THRES=10

# 4_ROI_calc_matrix, downsampling, new voxel size, default 5*5*5
DOWN_SIZE=5

# 5_ROI_parcellation, clustering method, default Sc
METHOD=Sc

# 6_ROI_toMNI_spm, new voxel size, default 1*1*1
VOX_SIZE=1.25

# 7_group_refer, group threshold, default 0.5
GROUP_THRES=0.25

# 9_calc_mpm, mpm threshold, default 0.5
MPM_THRES=0.25

# 11_validation, the number of iteration, default 20
N_ITER=100

# 15_probtrackx_toMNI, the p value threshold
P=0.0004

# 16_probtrackx_pm, the threshold
PM_THRES=0.25
 


#===============================================================================
# environment variables that can be modified if necessary
#===============================================================================
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
source /opt/sge/default/common/settings.sh
