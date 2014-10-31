function mpm_cluster=cluster_mpm_mod(wd,prefix,part,sub_list,kc,prob_thre,mpm_thre)

addpath('/DATA/233/hli/toolbox');
sub=sub_list;
sub_num=length(sub_list);
if ~exist('kc','var') | isempty(kc)
    kc=3;
end
if ~exist('prob_thre','var') | isempty(prob_thre)
    prob_thre=0.5;
end
if ~exist('mpm_thre','var') | isempty(mpm_thre)
    mpm_thre=0.5;
end
% if  isfield(segdirstruct,'inputdir'), inputdir=segdirstruct.inputdir;else inputdir='';end;
% if  isfield(segdirstruct,'area'), area=segdirstruct.area;else area='';end;

% for i=1:length(sub)
% %      tmp=dir(strcat(pathlab,sub{i},'*',seg,num2str(kc),postfix,'_new.nii'));
% %         tmp=regexp(sub{i},'_+','split');
% %        tmp_sub=tmp{1};
%     ref_file=strcat(pathlab,sub{i},'/',area,num2str(kc),'_new','.nii');
%     if exist(ref_file,'file'), break; end;
% end
% if ~exist(ref_file,'file')
%     disp('reference file not exist.');
%     disp(strcat('no mpm for cluster : ',num2str(kc)));
%     return;
% end
%vnii_ref=load_untouch_nii(strcat(pathlab,sub{1}));
% ref_file = strcat('/DATA/233/hli/TP/001/CD_001_TP_L_Sc/TP_L_2_MNI_relabel.nii');
vnii_ref=load_untouch_nii(strcat(wd,'/',sub{1},'/',prefix,'_',sub{1},'_',part,'_L_Sc/',part,'_L_',num2str(kc),'_MNI_relabel_group.nii'));
ref_img=vnii_ref.img;
IMGSIZE=size(ref_img);

prob_cluster=zeros([IMGSIZE,kc]);
for subi=1:sub_num
	sub_file=strcat(wd,'/',sub{subi},'/',prefix,'_',sub{subi},'_',part,'_L_Sc/',part,'_L_',num2str(kc),'_MNI_relabel_group.nii');
	vnii=load_untouch_nii(sub_file);
	tha_seg_result= vnii.img;   

%computering the probabilistic maps
	for ki=1:kc
    	tmp_ind=(tha_seg_result==ki);
    	prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki) + tmp_ind;  
	end

end
index=find(sum(prob_cluster,4)>0);
[xi,yi,zi]=ind2sub(IMGSIZE,index);
no_voxel=length(index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate maximum probabilistic map
mpm_cluster=zeros(IMGSIZE);
pvoxel=0;
for vi=1:no_voxel
psum=sum(prob_cluster(xi(vi),yi(vi),zi(vi),:));
if psum>prob_thre*sub_num  %??????????????>0.6
    prob=prob_cluster(xi(vi),yi(vi),zi(vi),:);
    [tmp_prob,tmp_ind]=sort(-prob);
     if prob(tmp_ind(1))-prob(tmp_ind(2))>1 
         if prob(tmp_ind(1))>mpm_thre*sub_num   
        mpm_cluster(xi(vi),yi(vi),zi(vi))=tmp_ind(1);
        pvoxel=pvoxel+1;
         end
     end
end
end
