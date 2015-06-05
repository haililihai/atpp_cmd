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
MAX_CL_NUM=$1
shift
NIFTI=$1
shift
METHOD=$1
shift
VOX_SIZE=$1
shift
GROUP_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1


if [ "${LEFT}" == "1" ] && [ "${RIGHT}" == "0" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer_xmm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},'${METHOD}',${VOX_SIZE},${GROUP_THRES},1);exit" &
	wait
elif [ "${LEFT}" == "0" ] && [ "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer_xmm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},'${METHOD}',${VOX_SIZE},${GROUP_THRES},0);exit" &
	wait
elif [ "${LEFT}" == "1" ] && [  "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer_xmm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},'${METHOD}',${VOX_SIZE},${GROUP_THRES},1);exit" &
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer_xmm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},'${METHOD}',${VOX_SIZE},${GROUP_THRES},0);exit" &
	wait
fi
