#! /bin/bash
# Automatic DTI-based Parcellation Pipeline (ADPP)
# Usgage: sh batch_process.sh [0|1|2]
# 2014.3.10 by Hai Li
# 2014.3.24 parallel computing for matlab programs, added by Hai Li
# 2014.4.10 parallel computing for shell scripts, added by Hai Li
# 2014.7.1 Registration with SPM


# directory where you put the scripts
pipeline=/DATA/233/hli/ADPP4_PT

# what do you want to run?
# 0 - ADPP stage 0 (preprocessing)
# 1 - ADPP stage 1 (waiting for the results from probtrackx) (default)
# 2 - ADPP stage 2
# 3 - ADPP stage 3 subregion tractography 1
# 4 - ADPP stage 4 subregion tractography 2
# 5 - ADPP stage 5 stability indice
test ! -e $1 && what_to_do=$1 || what_to_do=1

# ROI directory which contains ROI files, i.e. Amyg_L.nii
ROI_dir=/DATA/233/hli/BN_Atlas/ROI

# Parallel parameters
# the default number of parallel workers for matlab programs is 7
# the default number of parallel workers for shell scripts is 10, which can be modified
parallel=10

#====================================================================================
# batch processing parameter list
# DO NOT FORGET TO EDIT batch_list.txt itself to include the appropriate parameters
#====================================================================================
# batch_list.txt contains the following 8 parameters in each line:
# - Data directory , i.e. /DATA/233/hli/Data/chengdu
# - CIVET data directory , i.e. /DATA/233/hli/Data/chegndu/CIVET
# - Prefix of data , i.e. CD
# - List of subjects , i.e. /DATA/233/hli/Data/chengdu/sub_CD.txt
# - Brain region name , i.e. Amyg
# - working directory , i.e. /DATA/233/hli/Amyg
# - Maximum cluster number , i.e. 6
# - Cluster number , i.e. 3
test -e $2 && batch_list=$2 || batch_list=${pipeline}/batch_list.txt


#=======================================================================================
#----------------------------START OF SCRIPT--------------------------------------------
#----------NO EDITING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING--------------------------
#=======================================================================================

while read line
do

# 1. cut specific parameters from batch_list
DATA_DIR=$( echo $line | cut -d ' ' -f1 )
#CIVET_DIR=$( echo $line | cut -d ' ' -f2 )
PREFIX=$( echo $line | cut -d ' ' -f2 )
SUB_LIST=$( echo $line | cut -d ' ' -f3 )
PART=$( echo $line | cut -d ' ' -f4 )
WD=$( echo $line | cut -d ' ' -f5 )
MAX_CL_NUM=$( echo $line | cut -d ' ' -f6 )
CL_NUM=$( echo $line | cut -d ' ' -f7 )

CIVET_DIR='NONE'


# 2. distribute a task to the most available host
IP=`qhost | awk 'NR>4{print $4/$3,$1}' | sort -n | awk 'NR==1{print $2}'`

# 3. do the processing asked for
case ${what_to_do} in
0) echo "=============== ADPP Stage 0 ==============="
${pipeline}/batch_process_0.sh ${WD} ${DATA_DIR} ${PART} ${SUB_LIST} ${ROI_dir}
;;
1) echo "============================================================="
echo "=============== ADPP Stage 1 -- ${PART}@${IP} ==============="
ssh ${IP} "bash -s " < ${pipeline}/batch_process_1.sh ${pipeline} ${PART} ${WD} ${MAX_CL_NUM} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${SUB_LIST} ${parallel} >${WD}/log/stage_1_log.txt 2>&1 &
echo "==== Processing info @ ${WD}/log/stage_1_log.txt ====" 
sleep 15s # waiting for a proper host
;;
2) echo "============================================================="
echo "=============== ADPP Stage 2 -- ${PART}@${IP} ==============="
ssh ${IP} "bash -s " < ${pipeline}/batch_process_2.sh ${pipeline} ${PART} ${WD} ${MAX_CL_NUM} ${CL_NUM} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${SUB_LIST} ${parallel} >${WD}/log/stage_2_log.txt 2>&1 &
echo "==== Processing info @ ${WD}/log/stage_2_log.txt ====" 
sleep 15s
;;
3) echo "============================================================="
echo "=============== ADPP Stage 3 -- ${PART}@${IP} ==============="
ssh ${IP} "bash -s " < ${pipeline}/batch_process_3.sh ${pipeline} ${PART} ${WD} ${MAX_CL_NUM} ${CL_NUM} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${SUB_LIST} ${parallel} >${WD}/log/stage_3_log.txt 2>&1 &
echo "==== Processing info @ ${WD}/log/stage_3_log.txt ====" 
sleep 15s
;;
4) echo "============================================================="
echo "=============== ADPP Stage 4 -- ${PART}@${IP} ==============="
ssh ${IP} "bash -s " < ${pipeline}/batch_process_4.sh ${pipeline} ${PART} ${WD} ${MAX_CL_NUM} ${CL_NUM} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${SUB_LIST} ${parallel} >${WD}/log/stage_4_log.txt 2>&1 &
echo "==== Processing info @ ${WD}/log/stage_4_log.txt ====" 
sleep 15s
;;
5) echo "============================================================="
echo "=============== ADPP Stage 5 -- ${PART}@${IP} ==============="
ssh ${IP} "bash -s " < ${pipeline}/batch_process_5.sh ${pipeline} ${PART} ${WD} ${MAX_CL_NUM} ${CL_NUM} ${DATA_DIR} ${CIVET_DIR} ${PREFIX} ${SUB_LIST} ${parallel} >${WD}/log/stage_5_log.txt 2>&1 &
echo "==== Processing info @ ${WD}/log/stage_5_log.txt ====" 
sleep 15s
;;
6)
	cd ${WD}/validation
	mv stability_index.txt ${PART}_L_stability_index.txt
	mv ${PART}_indice.mat ${PART}_L_indice.mat
;;
esac


done < ${batch_list}
