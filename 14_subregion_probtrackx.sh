#! /bin/bash

WD=$1
shift
DATA_DIR=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
CL_NUM=$1
shift
VOX_SIZE=$1
shift
MPM_THRES=$1
shift
N_SAMPLES=$1
shift
DIS_COR=$1
shift
LEN_STEP=$1
shift
N_STEPS=$1
shift
CUR_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

MPM_THRES100=$(echo "${MPM_THRES}*100"|bc)
MPM_THRES100=${MPM_THRES100%.00}

# create a directory to check the status
if [ -d ${WD}/subregion_qsub_jobdone ]
then
	rm -rf ${WD}/subregion_qsub_jobdone
	mkdir -p ${WD}/subregion_qsub_jobdone
else
	mkdir -p ${WD}/subregion_qsub_jobdone
fi

for sub in $(cat ${SUB_LIST})
do
mkdir -p ${WD}/${sub}/subregion_probtrackx
if [ "${LEFT}" == "1" ]; then	
	for i in `seq 1 ${CL_NUM}`
	do
	job_id=$(fsl_sub probtrackx -o ${PART}_L_${CL_NUM}_${i}_nodc -x ${WD}/${sub}/subregion/${PART}_L_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask -l -c ${CUR_THRES} -S ${N_STEPS} --steplength=${LEN_STEP} -P ${N_SAMPLES} --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${WD}/${sub}/subregion_probtrackx &)
	echo "${sub}_${CL_NUM}_${i}_L probtrackx is running...! job_ID is ${job_id}"
	mute=$(fsl_sub -j ${job_id} -N running... touch ${WD}/subregion_qsub_jobdone/${sub}_${CL_NUM}_${i}_L.jobdone)
	done
fi
if [ "${RIGHT}" == "1" ]; then	
	for i in `seq 1 ${CL_NUM}`
	do
	job_id=$(fsl_sub probtrackx -o ${PART}_R_${CL_NUM}_${i}_nodc -x ${WD}/${sub}/subregion/${PART}_R_${CL_NUM}_${i}_DTI_thr${MPM_THRES100}_mask -l -c ${CUR_THRES} -S ${N_STEPS} --steplength=${LEN_STEP} -P ${N_SAMPLES} --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${WD}/${sub}/subregion_probtrackx &)
	echo "${sub}_${CL_NUM}_${i}_R probtrackx is running...! job_ID is ${job_id}"
	mute=$(fsl_sub -j ${job_id} -N running... touch ${WD}/subregion_qsub_jobdone/${sub}_${CL_NUM}_${i}_R.jobdone)
	done
fi
done
	

# check whether the tasks are finished or not
SUB_NUM=$(cat ${SUB_LIST}|wc -l)
N=$((${SUB_NUM}*${CL_NUM}))
if [ "${LEFT}" == "1" -a "${RIGHT}" == "0" ]
then
	while [ "$(ls ${WD}/subregion_qsub_jobdone|wc -l)" != "${N}"  ]
	do
		sleep 30s
	done	
fi

if [ "${LEFT}" == "0" -a "${RIGHT}" == "1" ]
then
	while [ "$(ls ${WD}/subregion_qsub_jobdone|wc -l)" != "${N}"  ]
	do
		sleep 30s
	done	
fi

if [ "${LEFT}" == "1" -a "${RIGHT}" == "1" ]
then
	while [ "$(ls ${WD}/subregion_qsub_jobdone|wc -l)" != "$((${N}*2))"  ]
	do
		sleep 30s
	done	
fi

echo "=== Finally Subregions' Probtrackx All Done!! ==="
