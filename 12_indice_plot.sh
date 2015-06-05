#! /bin/bash

pipeline=$1
shift
WD=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
VOX_SIZE=$1
shift
MAX_CL_NUM=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${pipeline}');indice_plot('${WD}','${PART}','${SUB_LIST}',${VOX_SIZE},${MAX_CL_NUM},${LEFT},${RIGHT});exit"
