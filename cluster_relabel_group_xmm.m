function cluster_relabel_group_xmm(PWD,PREFIX,PART,SUB_LIST,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,LEFT,RIGHT)
% relabel the cluster among the subjects

SUB = textread(SUB_LIST,'%s');

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool close force local
matlabpool('local',POOLSIZE)

if LEFT == 1
	cluster_relabel(PWD,PREFIX,PART,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,1)
end

if RIGHT == 1
	cluster_relabel(PWD,PREFIX,PART,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,0)
end

matlabpool close



function cluster_relabel(PWD,PREFIX,PART,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,LorR)

	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end
	
	GROUP_THRES=GROUP_THRES*100;
for CL_NUM=2:MAX_CL_NUM
	disp(strcat(PART,'_',LR,'_cluster_',num2str(CL_NUM),' processing...'));
	REFER = strcat(PWD,'/group_',num2str(length(SUB)),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(GROUP_THRES),'_group.nii');
	vnii_stand = load_untouch_nii(REFER); 
	standard_cluster= vnii_stand.img; 
 	sub_num=length(SUB);

parfor i=1:sub_num
if ~exist(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii'))
    vnii=load_untouch_nii(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(CL_NUM),'_MNI.nii')); 
    tha_seg_result= vnii.img;   
    tmp_overlay=zeros(CL_NUM,CL_NUM);
    
    for ki=1:CL_NUM
        for kj=1:CL_NUM
              tmp=(standard_cluster==ki).*(tha_seg_result==kj);
              tmp_overlay(ki,kj)=sum(tmp(:));
        end
    end

    for ki=1:CL_NUM
       tmp_overlay(ki,:)=tmp_overlay(ki,:)/sum(tmp_overlay(ki,:));
    end

    [cind,max]=munkres(-tmp_overlay);

    tmp_matrix=tha_seg_result;
    
    for ki=1:CL_NUM
        tmp_matrix(tha_seg_result==cind(ki))=ki;
    end
    tha_seg_result=tmp_matrix;
    vnii.img=tha_seg_result;
    save_untouch_nii(vnii,strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',PART,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii'));

    disp(strcat('relabeled for subject : ',SUB{i}));
else
    disp(strcat('relabeled for subject : ',SUB{i}));
end
end
end
