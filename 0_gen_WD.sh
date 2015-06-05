#! /bin/bash
# generate working directory for ATPP
#
# Directory structure:
#	  Working_dir
#     |-- sub1
#     |   |-- T1_sub1.nii
#     |   |-- b0_sub1.nii
#     |-- sub2
#     |-- ...
#     |-- subN
#     |-- ROI
#     |   |-- ROI_L.nii
#     |   `-- ROI_R.nii
#     `-- log 
#
# modify the following codes to organzie these files according to the above structure


WD=$1
shift
DATA_DIR=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
ROI_DIR=$1


#mkdir -p ${WD}
#mkdir -p ${WD}/ROI
#mkdir -p ${WD}/log

#gunzip ${ROI_DIR}/${PART}_L.nii.gz
#gunzip ${ROI_DIR}/${PART}_R.nii.gz

#cp -v -r -t ${WD}/ROI ${ROI_DIR}/${PART}_L.nii ${ROI_DIR}/${PART}_R.nii

for sub in `cat ${SUB_LIST}`
do
    mkdir -p ${WD}/${sub} 
	#cp -v -r -t ${WD}/${sub} ${DATA_DIR}/${sub}/3D/T1_${sub}.nii ${DATA_DIR}/${sub}/DTI/nodif.nii ${DATA_DIR}/${sub}/DTI/nodif_brain_mask.nii.gz
	#gunzip ${WD}/${sub}/nodif_brain.nii.gz
	#gunzip ${WD}/${sub}/T1_brain.nii.gz
	#mv -v ${WD}/${sub}/T1_brain.nii ${WD}/${sub}/T1_${sub}.nii	
	#mv -v ${WD}/${sub}/nodif.nii ${WD}/${sub}/b0_${sub}.nii	
done
