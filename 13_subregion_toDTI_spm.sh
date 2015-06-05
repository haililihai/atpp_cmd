#! /bin/bash

PIPELINE=$1
shift
WD=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
CL_NUM=$1
shift
TEMPLATE=$1
shift
VOX_SIZE=$1
shift
MPM_THRES=$1
shift
POOLSIZE=$1
shift
SPM=$1
shift
LEFT=$1
shift
RIGHT=$1

SUB_NUM=$(cat ${SUB_LIST}|wc -l)
MPM_THRES100=$(echo "${MPM_THRES}*100.00"|bc)
MPM_THRES100=${MPM_THRES100%.00}


#for i in $(seq 1 ${CL_NUM})
#do
#    if [ "${LEFT}" == "1" ]; then
#	fslmaths ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_L_${CL_NUM}_MPM_thr${MPM_THRES100}_group_smoothed.nii -nan -thr ${i} -uthr ${i} -bin ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_L_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask
#	fslchfiletype NIFTI ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_L_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask.nii.gz
#    fi
#    if [ "${RIGHT}" == "1" ]; then
#	fslmaths ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_R_${CL_NUM}_MPM_thr${MPM_THRES100}_group_smoothed.nii -nan -thr ${i} -uthr ${i} -bin ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_R_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask
#	fslchfiletype NIFTI ${WD}/MPM_${SUB_NUM}_${VOX_SIZE}mm/${VOX_SIZE}mm_${PART}_R_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask.nii.gz
#    fi
#done
    
(matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');subregion_toDTI_spm('${WD}','${PART}','${SUB_LIST}',${CL_NUM},'${TEMPLATE}',${VOX_SIZE},${MPM_THRES},${POOLSIZE},${LEFT},${RIGHT});exit") &
wait


for sub in $(cat ${SUB_LIST})
do
    for i in $(seq 1 ${CL_NUM})
    do
    if [ "${LEFT}" == "1" ]; then
	fslchfiletype NIFTI_GZ ${WD}/${sub}/subregion/w${VOX_SIZE}mm_${PART}_L_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask.nii ${WD}/${sub}/subregion/${VOX_SIZE}mm_${PART}_L_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask
    fi
    if [ "${RIGHT}" == "1" ]; then
	fslchfiletype NIFTI_GZ ${WD}/${sub}/subregion/w${VOX_SIZE}mm_${PART}_R_${CL_NUM}_${i}_MNI_thr${MPM_THRES100}_mask.nii ${WD}/${sub}/subregion/${VOX_SIZE}mm_${PART}_R_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask
    fi
    done
done
