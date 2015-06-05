function ROI_registration_spm(WD,PREFIX,PART,SUB_LIST,POOLSIZE,TEMPLATE,LEFT,ROI_L,RIGHT,ROI_R)
%-----------------------------------------------------------------------
% transform ROIs from MNI space to DTI(b0) space
%-----------------------------------------------------------------------

SUB = textread(SUB_LIST,'%s');

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)


% coregister T1 to b0 space
parfor i=1:length(SUB)
	spm_coreg_ew(WD,SUB,i)
end
matlabbatch=[];


% coregistered T1 image from b0 to MNI space
parfor i=1:length(SUB)
	spm_norm_e(WD,SUB,i,TEMPLATE)
end 
matlabbatch=[];


% ROIs from MNI space to b0 space using inverse matrix
if LEFT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,ROI_L)
	end 
	matlabbatch=[];
end

if RIGHT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,ROI_R)
	end 
	matlabbatch=[];
end

matlabpool close


function spm_coreg_ew(WD,SUB,i)
	sourcepath = strcat(WD,'/',SUB{i});
	disp(sourcepath);
	b0refimg = strcat(sourcepath,'/b0_',SUB{i},'.nii');
	T1sourceimg = strcat(sourcepath,'/T1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');

 	matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {b0refimg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {T1sourceimg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.002 0.002 0.002 0.0001 0.0001 0.0001 0.001 0.001 0.001 0.0001 0.0001 0.0001];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

	spm_jobman('run',matlabbatch)


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


function spm_util_deform(WD,SUB,i,ROI)
	sourcepath = strcat(WD,'/',SUB{i});
    disp(sourcepath);
	roimat = strcat(sourcepath,'/rT1_',SUB{i},'_sn.mat');
   	refimg = strcat(sourcepath,'/rT1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');
	
   	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {roimat};
	matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {refimg};
	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
       	                                                      	  NaN NaN NaN];
	matlabbatch{1}.spm.util.defs.ofname = '';
	matlabbatch{1}.spm.util.defs.fnames = {ROI};
	matlabbatch{1}.spm.util.defs.savedir.saveusr = {sourcepath};
	matlabbatch{1}.spm.util.defs.interp = 0;

	spm_jobman('run',matlabbatch)

