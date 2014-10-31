#! /bin/bash
# 2013.12.30 by Hai Li


PWD=$1
PREFIX=$2
PART=$3
SUB_LIST=$4
N=$5
thres=$6

for i in `seq 1 ${N}`
do
	for sub in `cat ${SUB_LIST}`
	do
		rm -f ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres_MNI.mnc
		rm -f ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres_MNI.mnc
	done
done
echo "remove done!"

num=`wc -l < ${SUB_LIST}`


for i in `seq 1 ${N}`
do
	cp ${PWD}/001/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres_MNI.nii  ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm.nii
	fslchfiletype NIFTI_GZ ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm.nii
	fslmaths ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm -uthr 0 ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm

	for sub in `cat ${SUB_LIST}`
	do
		fslmaths ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres_MNI -bin ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres_MNI_bin
		fslmaths ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm -add ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres_MNI_bin ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm 
	done

	fslmaths ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm -thr `echo "${num}*${thres}" | bc` ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres}
	fslmaths ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres} -div ${num} ${PWD}/group/${PART}_L_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres}_normalize
done
echo "Left done!"

for i in `seq 1 ${N}`
do
	cp ${PWD}/001/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres_MNI.nii  ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm.nii
	fslchfiletype NIFTI_GZ ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm.nii
	fslmaths ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm -uthr 0 ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm

	for sub in `cat ${SUB_LIST}`
	do
		fslmaths ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres_MNI -bin ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres_MNI_bin
		fslmaths ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm -add ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres_MNI_bin ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm 
	done

	fslmaths ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm -thr `echo "${num}*${thres}" | bc` ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres}
	fslmaths ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres} -div ${num} ${PWD}/group/${PART}_R_${N}_${i}_probtrackx_nodc_thres_MNI_pm_thr${thres}_normalize
done
echo "Right done!"

	
