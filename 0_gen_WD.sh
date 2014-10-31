#! /bin/bash
# generate working directory for ATPP


WD=$1
DATA_DIR=$2
PART=$3
SUB_LIST=$4
ROI_DIR=$5


mkdir -p ${WD}
mkdir -p ${WD}/ROI
mkdir -p ${WD}/log

gunzip ${ROI_DIR}/${PART}_L.nii.gz
gunzip ${ROI_DIR}/${PART}_R.nii.gz

cp -v -r -t ${WD}/ROI ${ROI_DIR}/${PART}_L.nii ${ROI_DIR}/${PART}_R.nii

for sub in `cat ${SUB_LIST}`
do
    mkdir -p ${WD}/${sub} 
	cp -v -r -t ${WD}/${sub} ${DATA_DIR}/${sub}/3D/T1_${sub}.nii ${DATA_DIR}/${sub}/DTI/nodif.nii
	#gunzip ${WD}/${sub}/nodif_brain.nii.gz
	#mv -v ${WD}/${sub}/T1.nii ${WD}/${sub}/T1_${sub}.nii	
	mv -v ${WD}/${sub}/nodif.nii ${WD}/${sub}/b0_${sub}.nii	
done
