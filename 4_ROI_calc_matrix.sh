#! /bin/bash
# 2013.12.5 by Hai Li

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
NIFTI=$1
shift
VAL_THRES=$1
shift
DOWN_SIZE=$1
shift
LEFT=$1
shift
RIGHT=$1


matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_calc_matrix('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${POOLSIZE},${VAL_THRES},${DOWN_SIZE},${LEFT},${RIGHT});exit"
