function ROI_group_refer(PWD,PREFIX,PART,SUB_LIST,CL_NUM,METHOD,GROUP_THRES,LorR)
% group REFER

	SUB = textread(SUB_LIST,'%s');
	subnum = length(SUB);

	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end 

	defnii = load_untouch_nii(strcat(PWD,'/',SUB{1},'/',PREFIX,'_',SUB{1},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI.nii'));
	sumimg = zeros(size(defnii.img),'single');
	%define the effect ROI size
	disp('confirm effect ROI size');
	for j = 1:subnum 
		  disp(strcat(SUB{j},'_',LR));
		  datanii = load_untouch_nii(strcat(PWD,'/',SUB{j},'/',PREFIX,'_',SUB{j},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI.nii'));
		  datanii.img(datanii.img>0) = 1;
		  sumimg = sumimg + datanii.img;
	end

	defimg = sumimg;
	defimg(defimg<GROUP_THRES*subnum)=0;
	defimg(defimg>0)=1;
	defnii.img = defimg;
	grouproipath = strcat(PWD,'/','group/');
	if ~exist(grouproipath,'dir')
		mkdir(grouproipath);
	end
	save_untouch_nii(defnii,strcat(grouproipath,PART,'_',LR,'_roimask_thr',num2str(GROUP_THRES*100),'.nii'));


	roiindex = find(sumimg >= GROUP_THRES*subnum);
	ROISIZE = length(roiindex);

    disp(strcat(PART,'_',LR,' cluster number_',num2str(CL_NUM),' is running...'));
    groupmatrix = zeros(ROISIZE,ROISIZE,'uint8');
    for j = 1:length(SUB)
		datanii = load_untouch_nii(strcat(PWD,'/',SUB{j},'/',PREFIX,'_',SUB{j},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI.nii'));
		dataimg = datanii.img;
		for ki=1:CL_NUM
			kimatrix = zeros(ROISIZE,ROISIZE,'uint8');
			kind = find(dataimg==ki);
		  	        [tf,vind] = ismember(kind,roiindex);
			kimatrix(vind(vind>0),vind(vind>0)) = 1;
			groupmatrix = groupmatrix + kimatrix;
		end	
    end
    [index C sumd D] = sc2(CL_NUM,single(groupmatrix));
    img_f = zeros(size(defnii.img),'uint8');
    a=1:1:length(index);
    img_f(roiindex(a)) = index(a);
    %groupnii.hdr = defnii.hdr;
    defnii.img = img_f;
    save_untouch_nii(defnii,strcat(grouproipath,PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(GROUP_THRES*100),'_group.nii'));

	disp(strcat(PART,'_',LR,' cluster number_',num2str(CL_NUM),' Done !!'));

