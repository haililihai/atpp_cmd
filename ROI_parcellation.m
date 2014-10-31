function ROI_parcellation(PWD,PREFIX,PART,SUB_LIST,MAX_CL_NUM,POOLSIZE,METHOD,LEFT,RIGHT)
% ROI parcellation based on spectral clustering

SUB = textread(SUB_LIST,'%s');

method = METHOD;
N = MAX_CL_NUM-1;

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)

% parfor
parfor i = 1:length(SUB)
	
% Left
if LEFT == 1
    outdir_L = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L','_',method);
    if ~exist(outdir_L) mkdir(outdir_L); end
    data = load(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L_matrix/connection_matrix.mat')); 
    coordinates = data.xyz;
    matrix = data.matrix;
    
    panduan = any(matrix');
    coordinates = coordinates(panduan,:);
    matrix = matrix(panduan,:);

    nii = load_untouch_nii(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_L_DTI.nii.gz'));
    
	for k=1:N
		display(strcat(SUB{i},'_',PART,'_L_',num2str(k+1),' processing...'));
        matrix1 = matrix*matrix';
        matrix1 = matrix1-diag(diag(matrix1));   
        [index C sumd D] = sc2(k+1,matrix1);
        image_f=nii.img;
        image_f(:,:,:)=0;
    for j = 1:length(coordinates)
        image_f(coordinates(j,1)+1,coordinates(j,2)+1,coordinates(j,3)+1)=index(j);
    end
        nii.img=image_f;
        filename=strcat(outdir_L,'/',PART,'_L_',num2str(k+1),'.nii');
		save_untouch_nii(nii,filename);
    end
	disp(strcat(SUB{i},'_',PART,'_L',' Done!'));
end

if RIGHT == 1
	% Right
	outdir_R = strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R','_',method);
    if ~exist(outdir_R)  mkdir(outdir_R); end
    data = load(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R_matrix/connection_matrix.mat')); 
    coordinates = data.xyz;
    matrix = data.matrix;
    
    panduan = any(matrix');
    coordinates = coordinates(panduan,:);
    matrix = matrix(panduan,:);

    nii = load_untouch_nii(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_R_DTI.nii.gz'));
    
	for k=1:N
		display(strcat(SUB{i},'_',PART,'_R_',num2str(k+1),' processing...'));
        matrix1 = matrix*matrix';
        matrix1 = matrix1-diag(diag(matrix1));   
        [index C sumd D] = sc2(k+1,matrix1);
        image_f=nii.img;
        image_f(:,:,:)=0;
    for j = 1:length(coordinates)
        image_f(coordinates(j,1)+1,coordinates(j,2)+1,coordinates(j,3)+1)=index(j);
    end
        nii.img=image_f;
        filename=strcat(outdir_R,'/',PART,'_R_',num2str(k+1),'.nii');
		save_untouch_nii(nii,filename);
    end
end
    disp(strcat(SUB{i},'_',PART,'_R',' Done!'));
end
matlabpool close
