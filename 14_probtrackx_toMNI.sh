#! /bin/bash


DATA_DIR=$1
PWD=$2
PREFIX=$3
PART=$4
SUB_LIST=$5
N=$6
parallel=$7
DIR=subregion_probtrackx

cd ${PWD}
i=1
for sub in `cat ${SUB_LIST}`
do
	#(
	# Left
	for i in `seq 1 ${N}` 
	do
	flirt -in ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres -ref ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_L.nii -applyxfm -init ${PWD}/${sub}/DTI_T1.mat -out ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_T1 -interp nearestneighbour
	gunzip ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_T1.nii.gz
	nii2mnc ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_T1.nii ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_T1.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_final.mnc -transformation ${DATA_DIR}/${sub}/transforms/linear/${PREFIX}_${sub}_t1_tal.xfm ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_T1.mnc ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_lin.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_nl.mnc -transformation ${DATA_DIR}/${sub}/transforms/nonlinear/${PREFIX}_${sub}_nlfit_It.xfm ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_lin.mnc ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_MNI.mnc
	mnc2nii ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_MNI.mnc ${PWD}/${sub}/${DIR}/${PART}_L_${N}_${i}_nodc_thres_MNI.nii
	done
	
	# Right
	for i in `seq 1 ${N}` 
	do
	flirt -in ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres -ref ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_R.nii -applyxfm -init ${PWD}/${sub}/DTI_T1.mat -out ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_T1 -interp nearestneighbour
	gunzip ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_T1.nii.gz
	nii2mnc ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_T1.nii ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_T1.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_final.mnc -transformation ${DATA_DIR}/${sub}/transforms/linear/${PREFIX}_${sub}_t1_tal.xfm ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_T1.mnc ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_lin.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_nl.mnc -transformation ${DATA_DIR}/${sub}/transforms/nonlinear/${PREFIX}_${sub}_nlfit_It.xfm ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_lin.mnc ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_MNI.mnc
	mnc2nii ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_MNI.mnc ${PWD}/${sub}/${DIR}/${PART}_R_${N}_${i}_nodc_thres_MNI.nii
	done
	echo "${sub} done!"
	#)&
	#[ $(($i%${parallel})) -eq 0 ] && wait
	#i=$(($i+1))

done
