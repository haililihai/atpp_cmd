#! /bin/bash

PIPELINE=$1
shift
WD=$1
shift
PREFIX=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
POOLSIZE=$1
shift
SPM=$1
shift
TEMPLATE=$1
shift
LEFT=$1
shift
ROI_L=$1
shift
RIGHT=$1
shift
ROI_R=$1
 

(matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');ROI_registration_spm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${POOLSIZE},'${TEMPLATE}',${LEFT},'${ROI_L}',${RIGHT},'${ROI_R}');exit") &
wait


for sub in `cat ${SUB_LIST}`
do
	if [ "${LEFT}" == "1" ]; then
		mv ${WD}/${sub}/w${PART}_L.nii ${WD}/${sub}/${PREFIX}_${sub}_${PART}_L_DTI.nii
		fslchfiletype NIFTI_GZ ${WD}/${sub}/${PREFIX}_${sub}_${PART}_L_DTI
	fi
	if [ "${RIGHT}" == "1" ]; then
		mv ${WD}/${sub}/w${PART}_R.nii ${WD}/${sub}/${PREFIX}_${sub}_${PART}_R_DTI.nii
		fslchfiletype NIFTI_GZ ${WD}/${sub}/${PREFIX}_${sub}_${PART}_R_DTI
	fi
done


