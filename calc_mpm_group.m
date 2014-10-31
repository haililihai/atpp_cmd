function calc_mpm_group(PWD,PREFIX,PART,SUB_LIST,CL_NUM,METHOD,MPM_THRES,LEFT,RIGHT)
% generate the probabilistic maps and the maximum probabilistic map

SUB = textread(SUB_LIST,'%s');

if LEFT == 1
	calc_mpm(PWD,PREFIX,PART,SUB,CL_NUM,METHOD,MPM_THRES,1)
end

if RIGHT == 1
	calc_mpm(PWD,PREFIX,PART,SUB,CL_NUM,METHOD,MPM_THRES,0)
end


function calc_mpm(PWD,PREFIX,PART,SUB,CL_NUM,METHOD,MPM_THRES,LorR)
	
	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end

REFER = strcat(PWD,'/',SUB{1},'/',PREFIX,'_',SUB{1},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii');
vnii_ref = load_untouch_nii(REFER);
ref_img=vnii_ref.img;
IMGSIZE=size(ref_img);
sumimg = zeros(IMGSIZE);

probpath = strcat(PWD,'/MPM/');
if ~exist(probpath,'dir'),  mkdir(probpath);end
prob_cluster=zeros([IMGSIZE,CL_NUM]);

sub_num = length(SUB);
for i=1:sub_num

	sub_file=strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii');
	vnii=load_untouch_nii(sub_file);
	tha_seg_result= vnii.img;   
	dataimg = vnii.img;
	dataimg(dataimg>0) = 1;
	sumimg = sumimg + double(dataimg);

%computering the probabilistic maps
for ki=1:CL_NUM
    tmp_ind=(tha_seg_result==ki);
    prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki) + tmp_ind;  
end

end

indeximg = sumimg;
indeximg(indeximg<MPM_THRES*sub_num) = 0;
indeximg(indeximg>0) = 1;

index=find(indeximg>0);
[xi,yi,zi]=ind2sub(IMGSIZE,index);
no_voxel=length(index);
%%%%%%%%%%%%%%%%%%%%%
%write the probabilistic maps
  for ki=1:CL_NUM
    prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki).*indeximg;
    filename_re=strcat(probpath,PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(ki),'.nii');
    vnii.img = zeros(IMGSIZE);
    probclki = prob_cluster(:,:,:,ki);
    vnii.img(index) = (probclki(index)./sumimg(index))*100;
%    vnii.img(isnan(vnii.img)) =  0;
    save_untouch_nii(vnii,filename_re);
  end
  disp(strcat('Calculating <',PART,'_',LR,'> probabilistic maps...'));
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate maximum probabilistic map
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

filename_re2=strcat(probpath,PART,'_',LR,'_',num2str(CL_NUM),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii');
vnii.img=mpm_cluster;
save_untouch_nii(vnii,filename_re2);
disp(strcat('Calculating <',PART,'_',LR,'> maximum probabilistic maps'));

