function subregion_toDTI_spm(WD,PART,SUB_LIST,CL_NUM,TEMPLATE,VOX_SIZE,MPM_THRES,POOLSIZE,LEFT,RIGHT)
%-----------------------------------------------------------------------
% transform subregions from MNI space to DTI(b0) space
%-----------------------------------------------------------------------

SUB = textread(SUB_LIST,'%s');
MPM_THRES100=MPM_THRES*100;

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)


% coregistered T1 image from b0 to MNI space
parfor i=1:length(SUB)
	spm_norm_e(WD,SUB,i,TEMPLATE)
end 
matlabbatch=[];


% ROIs from MNI space to b0 space using inverse matrix
if LEFT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,PART,CL_NUM,VOX_SIZE,MPM_THRES100,'L')
	end 
	matlabbatch=[];
end

if RIGHT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,PART,CL_NUM,VOX_SIZE,MPM_THRES100,'R')
	end 
	matlabbatch=[];
end

matlabpool close


function spm_norm_e(WD,SUB,i,TEMPLATE)
	sourcepath = strcat(WD,'/',SUB{i});
	disp(sourcepath);
	sourceimg = strcat(sourcepath,'/rT1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');
	
	matlabbatch{1}.spm.spatial.normalise.est.subj.source = {sourceimg};
	matlabbatch{1}.spm.spatial.normalise.est.subj.wtsrc = '';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.template = {TEMPLATE};
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.weight = '';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.smosrc = 8;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.smoref = 0;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.regtype = 'mni';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.cutoff = 25;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.nits = 16;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = 1; 

	spm_jobman('run',matlabbatch)


function spm_util_deform(WD,SUB,i,PART,CL_NUM,VOX_SIZE,MPM_THRES100,LR)
	sourcepath = strcat(WD,'/',SUB{i});
	output_dir=strcat(sourcepath,'/subregion');
	if ~exist(output_dir) mkdir(output_dir);end
	disp(sourcepath);
	for N=1:CL_NUM
	    ROI{N}=strcat(WD,'/MPM_',num2str(length(SUB)),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(N),'_MNI_thr',num2str(MPM_THRES100),'_mask.nii');
	end
	roimat = strcat(sourcepath,'/rT1_',SUB{i},'_sn.mat');
   	refimg = strcat(sourcepath,'/rT1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');
	
	for N=1:CL_NUM
	   	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {roimat};
		matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {refimg};
		matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
		matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
	       	                                                      	  NaN NaN NaN];
		matlabbatch{1}.spm.util.defs.ofname = '';
		matlabbatch{1}.spm.util.defs.fnames = {ROI{N}};
		matlabbatch{1}.spm.util.defs.savedir.saveusr = {output_dir};
		matlabbatch{1}.spm.util.defs.interp = 0;

		spm_jobman('run',matlabbatch)
	end

