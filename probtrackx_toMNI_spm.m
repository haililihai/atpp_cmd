function probtrackx_toMNI_spm(WD,PART,SUB_LIST,CL_NUM,TEMPLATE,VOX_SIZE,POOLSIZE,LEFT,RIGHT)
%-----------------------------------------------------------------------
% transform probtracks from DTI(b0) space to MNI space
%-----------------------------------------------------------------------

SUB = textread(SUB_LIST,'%s');

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)


if LEFT == 1
	parfor i=1:length(SUB)
		spm_norm_ew(WD,SUB,i,PART,CL_NUM,TEMPLATE,VOX_SIZE,'L')
	end
	matlabbatch=[];
end

if RIGHT == 1
	parfor i=1:length(SUB)
		spm_norm_ew(WD,SUB,i,PART,CL_NUM,TEMPLATE,VOX_SIZE,'R')
	end
	matlabbatch=[];
end

matlabpool close



function spm_norm_ew(WD,SUB,i,PART,CL_NUM,TEMPLATE,VOX_SIZE,LR)
	sourcepath=strcat(WD,'/',SUB{i});
	disp(sourcepath);
	sourceimg=strcat(sourcepath,'/rT1_',SUB{i},'.nii');
	for N=1:CL_NUM
		resampleimg{N}=strcat(sourcepath,'/subregion_probtrackx/',PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(N),'_nodc_thres_spm.nii');
	end

	spm('defaults','fmri');
	spm_jobman('initcfg');

	for N = 1:CL_NUM
		matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {sourceimg};
		matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
		matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {resampleimg{N}};
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {TEMPLATE};
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = {''};
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-90 -126 -72
                                                              		  90 90 108];
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [VOX_SIZE VOX_SIZE VOX_SIZE];
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
 		matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

 		spm_jobman('run',matlabbatch)
	end
	
	disp(strcat(SUB{i},'_',LR,' Done!'));
	
	



