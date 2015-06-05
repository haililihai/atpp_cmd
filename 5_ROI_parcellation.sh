#! /bin/bash
# 2013.12.6 by Hai Li

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
MAX_CL_NUM=$1
shift
POOLSIZE=$1
shift
METHOD=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');ROI_parcellation('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},${POOLSIZE},'${METHOD}',${LEFT},${RIGHT});exit"
