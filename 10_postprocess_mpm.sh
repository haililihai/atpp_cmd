#! /bin/bash
# 2013.12.12 by Hai Li

PIPELINE=$1
shift
WD=$1
shift
PART=$1
shift
CL_NUM=$1
shift
NIFTI=$1
shift
MPM_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');postprocess_mpm_group('${WD}','${PART}',${CL_NUM},${MPM_THRES},${LEFT},${RIGHT});exit"
