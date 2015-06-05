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
N_SAMPLES=$1
shift
P=$1
shift
POOLSIZE=$1
shift
SPM=$1
shift
LEFT=$1
shift
RIGHT=$1

MPM_THRES100=$(echo "${MPM_THRES}*100"|bc)
MPM_THRES100=${MPM_THRES100%.00}

for sub in $(cat ${SUB_LIST})
do	
	for i in $(seq 1 ${N})
	do
	if [ "${LEFT}" == "1" ]; then
		vol=$(fslstats ${WD}/${sub}/subregion/${PART}_L_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask -n -V | awk '{print $1}')
		thres=$(echo "${vol}*${P}*${N_SAMPLES}" | bc)
		fslmaths ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc -thr ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres
		fslchfiletype NIFTI ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres.nii.gz ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_spm
	fi
	if [ "${RIGHT}" == "1" ]; then
		vol=$(fslstats ${WD}/${sub}/subregion/${PART}_R_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask -n -V | awk '{print $1}')
		thres=$(echo "${vol}*${P}*${N_SAMPLES}" | bc)
		fslmaths ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc -thr ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres
		fslchfiletype NIFTI ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres.nii.gz ${thres} ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_spm
	fi
	done
done

(matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');probtrackx_toMNI_spm('${WD}','${PART}','${SUB_LIST}',${CL_NUM},'${TEMPLATE}',${VOX_SIZE},${POOLSIZE},${LEFT},${RIGHT});exit") &
wait

for sub in $(cat ${SUB_LIST})
do
	for i in $(seq 1 ${CL_NUM})
    do
    if [ "${LEFT}" == "1" ]; then
	fslchfiletype NIFTI_GZ ${WD}/${sub}/subregion_probtrackx/w${PART}_L_${CL_NUM}_${i}_nodc_thres_spm.nii ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI
    fi
    if [ "${RIGHT}" == "1" ]; then
	fslchfiletype NIFTI_GZ ${WD}/${sub}/subregion_probtrackx/w${PART}_R_${CL_NUM}_${i}_nodc_thres_spm.nii ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI
    fi
	done
done
