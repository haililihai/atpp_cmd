function ROI_calc_matrix(PWD,PREFIX,PART,SUB_LIST,POOLSIZE,VAL_THRES,DOWN_SIZE,LEFT,RIGHT)
% calculate the connectivity and correlation matrix
% require NIfTI toolbox for MATLAB
% load_nii_hdr modified to support .gz files

SUB=textread(SUB_LIST,'%s');

threshold = VAL_THRES; 
resampflag = 1;
NewVoxSize = [DOWN_SIZE DOWN_SIZE DOWN_SIZE];
method = 1;

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)

%parfor
parfor i = 1:length(SUB);

	if LEFT == 1
	coord_L = load(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L_coord.txt'));
	imgfolder_L = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L_probtrackx');
	outfolder_L = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L_matrix/');
	if ~exist(outfolder_L) mkdir(outfolder_L);end
 	f_Create_Matrix_v3_new(imgfolder_L,outfolder_L,coord_L,threshold,resampflag,NewVoxSize,method);
	end

	if RIGHT == 1
	coord_R = load(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R_coord.txt'));
	imgfolder_R = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R_probtrackx');
	outfolder_R = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R_matrix/');
	if ~exist(outfolder_R) mkdir(outfolder_R);end
	f_Create_Matrix_v3_new(imgfolder_R,outfolder_R,coord_R,threshold,resampflag,NewVoxSize,method);
	end

end
matlabpool close
