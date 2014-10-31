#! /bin/bash

pipeline=$1
shift
WD=$1
shift
PART=$1
shift
MAX_CL_NUM=$1

matlab -nodisplay -nosplash -r "addpath('${pipeline}');indice_plot('${WD}','${PART}',${MAX_CL_NUM});exit"
