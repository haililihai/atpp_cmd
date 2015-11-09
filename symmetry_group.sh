#!/bin/bash
PWD=/DATA/233/hli/BA_fs
SUB_LIST=/DATA/233/hli/Data/HCP_40/sub_HCP.txt
#POOLSIZE=12
THRES=0.25
#VOX=1.25

#for VOX in 1.25 2
for VOX in 1.25
do
while read line
do
	PART=$(echo $line|cut -d ' ' -f5)
	MAX_CL_NUM=$(echo $line|cut -d ' ' -f6)
	fsl_sub /mnt/software/matlab/bin/matlab -nodisplay -r "addpath('/DATA/233/hli/ATPP_test');symmetry_group('${PWD}','${PART}','${SUB_LIST}',${MAX_CL_NUM},${VOX},${THRES});exit"
done < /DATA/233/hli/ATPP_test/atlas_Ins.txt
#done < /DATA/233/hli/ATPP_test/atlas.txt
done
