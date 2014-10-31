#! /bin/bash
# 2013.12.6 by Hai Li

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
SPM=$1
shift
POOLSIZE=$1
shift
TEMPLATE=$1
shift
VOX_SIZE=$1
shift
METHOD=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');ROI_toMNI_spm('${WD}','${DATA_DIR}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},${POOLSIZE},'${TEMPLATE}',${VOX_SIZE},'${METHOD}',${LEFT},${RIGHT});exit"

for sub in `cat ${SUB_LIST}`
do
	for num in $(seq 2 ${MAX_CL_NUM})
	do
		if [ "${LEFT}" == "1" ]; then
			mv ${WD}/${sub}/${PREFIX}_${sub}_${PART}_L_${METHOD}/w${PART}_L_${num}.nii ${WD}/${sub}/${PREFIX}_${sub}_${PART}_L_${METHOD}/${PART}_L_${num}_MNI.nii
		fi
		if [ "${RIGHT}" == "1" ]; then
			mv ${WD}/${sub}/${PREFIX}_${sub}_${PART}_R_${METHOD}/w${PART}_R_${num}.nii ${WD}/${sub}/${PREFIX}_${sub}_${PART}_R_${METHOD}/${PART}_R_${num}_MNI.nii
		fi
	done
done
