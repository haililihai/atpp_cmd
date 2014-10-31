#! /bin/bash

PWD=$1
PREFIX=$2
PART=$3
SUB_LIST=$4
N=$5
p=$6
sample=$7
parallel=$8

i=1
for sub in `cat ${SUB_LIST}`
do
	#(	
	for i in `seq 1 ${N}`
	do
	vol=`fslstats ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_L_${N}_${i}_DTI.nii.gz -V | awk '{print $1}'`
	thres=`echo "${vol}*${p}*${sample}" | bc`
	fslmaths ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc -thr ${thres} ${PWD}/${sub}/subregion_probtrackx/${PART}_L_${N}_${i}_nodc_thres
	done

	for i in `seq 1 ${N}`
	do
	vol=`fslstats ${PWD}/${sub}/${PREFIX}_${sub}_${PART}_R_${N}_${i}_DTI.nii.gz -V | awk '{print $1}'`
	thres=`echo "${vol}*${p}*${sample}" | bc`
	fslmaths ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc -thr ${thres} ${PWD}/${sub}/subregion_probtrackx/${PART}_R_${N}_${i}_nodc_thres
	done
	echo "${sub} done!"
	#)&
	#[ $(($i%${parallel})) -eq 0 ] && wait
	#i=$(($i+1))

done
	
