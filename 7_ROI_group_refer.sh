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
CL_NUM=$1
shift
NIFTI=$1
shift
METHOD=$1
shift
GROUP_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1


if [ "${LEFT}" == "1" -a "${RIGHT}" == "0" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${CL_NUM},'${METHOD}',${GROUP_THRES},1);exit" &
	wait
elif [ "${LEFT}" == "0" -a "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${CL_NUM},'${METHOD}',${GROUP_THRES},0);exit" &
	wait
elif [ "${LEFT}" == "1" -a "${RIGHT}" == "1" ]
then
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${CL_NUM},'${METHOD}',${GROUP_THRES},1);exit" &
	matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_group_refer('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${CL_NUM},'${METHOD}',${GROUP_THRES},0);exit" &
	wait
fi
