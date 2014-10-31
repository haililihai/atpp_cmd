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
MAX_CL_NUM=$1
shift
ITER=$1
shift
GROUP_THRES=$1
shift
MPM_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

if [ "${LEFT}" == "1" -a "${RIGHT}" == "0" ]
then
	matlab -nodisplay -nosplash -r "addpath('${pipeline}');cross_validation_N_L('${WD}','${PREFIX}','${PART}','${SUB}',${MAX_CL_NUM},${ITER},${GROUP_THRES},${MPM_THRES});exit" &
	wait
elif [ "${LEFT}" == "0" -a "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${pipeline}');cross_validation_N_R('${WD}','${PREFIX}','${PART}','${SUB}',${MAX_CL_NUM},${ITER},${GROUP_THRES},${MPM_THRES});exit" &
	wait
elif [ "${LEFT}" == "1" -a "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${pipeline}');cross_validation_N_L('${WD}','${PREFIX}','${PART}','${SUB}',${MAX_CL_NUM},${ITER},${GROUP_THRES},${MPM_THRES});exit" &
	matlab -nodisplay -nosplash -r "addpath('${pipeline}');cross_validation_N_R('${WD}','${PREFIX}','${PART}','${SUB}',${MAX_CL_NUM},${ITER},${GROUP_THRES},${MPM_THRES});exit" &
	wait
fi


