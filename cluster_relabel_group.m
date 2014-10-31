function cluster_relabel_group(PWD,PREFIX,PART,SUB_LIST,CL_NUM,POOLSIZE,GROUP_THRES,METHOD,LEFT,RIGHT)
% relabel the cluster among the subjects

SUB = textread(SUB_LIST,'%s');

if exist(strcat(prefdir,'/../local_scheduler_data'))
	rmdir(strcat(prefdir,'/../local_scheduler_data'),'s');
end
matlabpool('local',POOLSIZE)

if LEFT == 1
	cluster_relabel(PWD,PREFIX,PART,SUB,CL_NUM,POOLSIZE,GROUP_THRES,METHOD,1)
end

if RIGHT == 1
	cluster_relabel(PWD,PREFIX,PART,SUB,CL_NUM,POOLSIZE,GROUP_THRES,METHOD,0)
end

matlabpool close



function cluster_relabel(PWD,PREFIX,PART,SUB,CL_NUM,POOLSIZE,GROUP_THRES,METHOD,LorR)

	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end
	
	GROUP_THRES=GROUP_THRES*100;

	disp(strcat(PART,'_',LR,'_cluster_',num2str(CL_NUM),' processing...'));
	REFER = strcat(PWD,'/group/',PART,'_',LR,'_',num2str(CL_NUM),'_',num2str(GROUP_THRES),'_group.nii');
	vnii_stand = load_untouch_nii(REFER); 
	standard_cluster= vnii_stand.img; 
 	sub_num=length(SUB);
	group_overlay=zeros(sub_num,CL_NUM);

parfor i=1:sub_num
   
    vnii=load_untouch_nii(strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI.nii')); 
    tha_seg_result= vnii.img;   
    tmp_overlay=zeros(CL_NUM,CL_NUM);
    
    for ki=1:CL_NUM
        for kj=1:CL_NUM
              tmp=(standard_cluster==ki).*(tha_seg_result==kj);
              tmp_overlay(ki,kj)=sum(tmp(:));
        end
    end
	% clear standard_cluster vnii_stand tmp
    overlay=tmp_overlay./repmat(sum(tmp_overlay,2),1,CL_NUM);


    for ki=1:CL_NUM
       tmp_overlay(ki,:)=tmp_overlay(ki,:)/sum(tmp_overlay(ki,:));
    end

    if CL_NUM==2
      tmp1=tmp_overlay(1,1)+tmp_overlay(2,2);
     tmp2=tmp_overlay(1,2)+tmp_overlay(2,1);
    [tmp,cind1]= sort(-[tmp1,tmp2]);
     cind=[cind1(1),cind1(2)];
    else
        x=perms(1:CL_NUM);
        tmpsum=zeros(prod(1:CL_NUM),1);
        for ti=1:length(tmpsum)
          for tj=1:CL_NUM
                tmpsum(ti)=tmpsum(ti)+tmp_overlay(tj,x(ti,tj));
          end
        end
       [tmpsum2,cind2]= sort(-tmpsum);
      cind=x(cind2(1),:);
    end

    tmp_matrix=tha_seg_result;
    
    for ki=1:CL_NUM
        tmp_matrix(tha_seg_result==cind(ki))=ki;
    end
    tha_seg_result=tmp_matrix;
    vnii.img=tha_seg_result;
    save_untouch_nii(vnii,strcat(PWD,'/',SUB{i},'/',PREFIX,'_',SUB{i},'_',PART,'_',LR,'_',METHOD,'/',PART,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii'));

    group_overlay(i,:)=diag(overlay(1:CL_NUM,cind));
    disp(strcat('relabeled for subject : ',SUB{i}));
end


