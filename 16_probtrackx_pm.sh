#! /bin/bash


WD=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
CL_NUM=$1
shift
PM_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

first_sub=$(cat ${SUB_LIST}|head -n 1)
sub_num=$(cat ${SUB_LIST}|wc -l)
PM_THRES100=$(echo "${PM_THRES}*100"|bc)
PM_THRES100=${PM_THRES100%.00}

mkdir -p ${WD}/subregion_group_${sub_num}_probtrackx

if [ "${LEFT}" == "1" ]; then
for i in $(seq 1 ${CL_NUM})
do
	cp ${WD}/${first_sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI.nii.gz ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz
	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz -uthr 0 ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz
	for sub in `cat ${SUB_LIST}`
	do
		fslmaths ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI -bin ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_bin
		fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm -add ${WD}/${sub}/subregion_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_bin ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm 
	done

	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm -thr `echo "${sub_num}*${PM_THRES}" | bc` ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100}
	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100} -div ${sub_num} $${WD}/subregion_group_${sub_num}_probtrackx/${PART}_L_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100}_norm
done
echo "Left done!"
fi

if [ "${RIGHT}" == "1" ]; then
for i in $(seq 1 ${CL_NUM})
do
	cp ${WD}/${first_sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI.nii.gz ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz
	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz -uthr 0 ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm.nii.gz
	for sub in `cat ${SUB_LIST}`
	do
		fslmaths ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI -bin ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_bin
		fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm -add ${WD}/${sub}/subregion_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_bin ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm 
	done

	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm -thr `echo "${sub_num}*${PM_THRES}" | bc` ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100}
	fslmaths ${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100} -div ${sub_num} $${WD}/subregion_group_${sub_num}_probtrackx/${PART}_R_${CL_NUM}_${i}_nodc_thres_MNI_pm_thr${PM_THRES100}_norm
done
echo "Right done!"
fi

	
