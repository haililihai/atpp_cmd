#! /bin/bash

DATA_DIR=$1
DIR=$2
PREFIX=$3
PART=$4
SUB_LIST=$5
N=$6
parallel=$7

i=1
for sub in `cat ${SUB_LIST}`
do
	#(
	for i in `seq 1 ${N}`
	do
	fslmaths ${DIR}/MPM/${PART}_L_${N}_MPM_thr50_group_smoothed -thr $i -uthr $i -bin ${DIR}/MPM/${PART}_L_${N}_${i}_mask
	gunzip ${DIR}/MPM/${PART}_L_${N}_${i}_mask.nii.gz
	nii2mnc ${DIR}/MPM/${PART}_L_${N}_${i}_mask.nii		
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_final.mnc -transformation ${DATA_DIR}/${sub}/transforms/nonlinear/${PREFIX}_${sub}_nlfit_It_invert.xfm ${DIR}/MPM/${PART}_L_${N}_${i}_mask.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_lin.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/native/${PREFIX}_${sub}_t1_nuc.mnc -transformation ${DATA_DIR}/${sub}/transforms/linear/${PREFIX}_${sub}_t1_tal_invert.xfm ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_lin.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_native.mnc
	mnc2nii ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_native.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_T1.nii
	flirt -in ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_T1.nii -ref ${DIR}/${sub}/nodif_brain -applyxfm -init ${DIR}/${sub}/T1_DTI.mat -out ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_DTI -interp nearestneighbour
	done

	for i in `seq 1 ${N}`
	do
	fslmaths ${DIR}/MPM/${PART}_R_${N}_MPM_thr50_group_smoothed -thr $i -uthr $i -bin ${DIR}/MPM/${PART}_R_${N}_${i}_mask
	gunzip ${DIR}/MPM/${PART}_R_${N}_${i}_mask.nii.gz
	nii2mnc ${DIR}/MPM/${PART}_R_${N}_${i}_mask.nii	
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/final/${PREFIX}_${sub}_t1_final.mnc -transformation ${DATA_DIR}/${sub}/transforms/nonlinear/${PREFIX}_${sub}_nlfit_It_invert.xfm ${DIR}/MPM/${PART}_R_${N}_${i}_mask.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_lin.mnc
	mincresample -nearest_neighbour -like ${DATA_DIR}/${sub}/native/${PREFIX}_${sub}_t1_nuc.mnc -transformation ${DATA_DIR}/${sub}/transforms/linear/${PREFIX}_${sub}_t1_tal_invert.xfm ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_lin.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_native.mnc
	mnc2nii ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_native.mnc ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_T1.nii
	flirt -in ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_T1.nii -ref ${DIR}/${sub}/nodif_brain -applyxfm -init ${DIR}/${sub}/T1_DTI.mat -out ${DIR}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_DTI -interp nearestneighbour
	done
	#)&
	#[ $(($i%${parallel})) -eq 0 ] && wait
	#i=$(($i+1))
done
