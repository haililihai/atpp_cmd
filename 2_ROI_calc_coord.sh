#! /bin/bash
# 2013.12.4 by Hai Li

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
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_calc_coord('${WD}','${PREFIX}','${PART}','${SUB_LIST}','${POOLSIZE}',${LEFT},${RIGHT});exit"
