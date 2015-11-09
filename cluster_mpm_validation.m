function mpm_cluster=cluster_mpm_validation(PWD,PREFIX,PART,SUB,METHOD,VOX_SIZE,kc,MPM_THRES,LorR)

	addpath('/DATA/233/hli/toolbox');

	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end

	sub=SUB;
	sub_num=length(SUB);
	if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
    	MPM_THRES=0.25;
	end

	vnii_ref=load_untouch_nii(strcat(PWD,'/',sub{1},'/',PREFIX,'_',sub{1},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz'));
	ref_img=vnii_ref.img;
	IMGSIZE=size(ref_img);
	sumimg=zeros(IMGSIZE);

	prob_cluster=zeros([IMGSIZE,kc]);
	for subi=1:sub_num
		sub_file=strcat(PWD,'/',sub{subi},'/',PREFIX,'_',sub{subi},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
		vnii=load_untouch_nii(sub_file);
		tha_seg_result= vnii.img;   
		dataimg=vnii.img;
		dataimg(dataimg>0)=1;
		sumimg=sumimg+double(dataimg);

	%computing the probabilistic maps
		for ki=1:kc
	    	tmp_ind=(tha_seg_result==ki);
	    	prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki) + tmp_ind;  
		end
	end

	indeximg=sumimg;
	indeximg(indeximg<MPM_THRES*sub_num)=0;
	indeximg(indeximg>0)=1;

	for ki=1:kc
		prob_cluster(:,:,:,ki)=prob_cluster(:,:,:,ki).*indeximg;
	end

	index=find(indeximg>0);
	[xi,yi,zi]=ind2sub(IMGSIZE,index);
	no_voxel=length(index);

	mpm_cluster=zeros(IMGSIZE);
	for vi=1:no_voxel
		prob=(prob_cluster(xi(vi),yi(vi),zi(vi),:)/sumimg(xi(vi),yi(vi),zi(vi)))*100;
		[tmp_prob,tmp_ind]=sort(-prob);
		if prob(tmp_ind(1))-prob(tmp_ind(2))>0
			mpm_cluster(index(vi))=tmp_ind(1);
		else
			mpm_cluster(index(vi))=tmp_ind(2);
	    end
	end
end
