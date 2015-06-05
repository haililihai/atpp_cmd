#! /bin/bash

pipeline=$1
shift
WD=$1
shift
PREFIX=$1
shift
PART=$1
shift
SUB=$1
shift
METHOD=$1
shift
VOX_SIZE=$1
shift
MAX_CL_NUM=$1
shift
N_ITER=$1
shift
MPM_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${pipeline}');validation('${WD}','${PREFIX}','${PART}','${SUB}','${METHOD}',${VOX_SIZE},${MAX_CL_NUM},${N_ITER},${MPM_THRES},${LEFT},${RIGHT});exit" 


