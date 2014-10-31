#! /bin/bash

DATA_DIR=$1
PWD=$2
PREFIX=$3
PART=$4
SUB_LIST=$5
N=$6

for sub in `cat ${SUB_LIST}`
do
	mkdir -p ${PWD}/${sub}/subregion_probtrackx
	
	for i in `seq 1 ${N}`
	do
	fsl_sub probtrackx -o ${PART}_L_${N}_${i}_nodc -x ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_DTI -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${PWD}/${sub}/subregion_probtrackx &
	done

	for i in `seq 1 ${N}`
	do
	fsl_sub probtrackx -o ${PART}_R_${N}_${i}_nodc -x ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_DTI -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${PWD}/${sub}/subregion_probtrackx &
	done
done
	
