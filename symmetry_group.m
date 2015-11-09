function symmetry_group(PWD,PART,SUB_LIST,MAX_CL_NUM,VOX,THRES)
% relabel the cluster among the subjects

SUB = textread(SUB_LIST,'%s');
num=length(SUB);
addpath('/DATA/233/hli/ATPP_test');
addpath('/DATA/233/hli/toolbox');

for CL_NUM=2:MAX_CL_NUM

%if ~exist(strcat(PWD,'/',PART,'/','group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',PART,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'))
    nii_L=load_untouch_nii(strcat(PWD,'/',PART,'/','group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',PART,'_L_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'));
    img_L= nii_L.img;
    nii_R=load_untouch_nii(strcat(PWD,'/',PART,'/','group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',PART,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'));
    img_R= nii_R.img;
    [xr,yr,zr]=size(img_R);
    img_R_mirror=img_R;
    img_R_mirror(:,:,:)=0;
    for x=1:xr
      for y=1:yr
        for z=1:zr   
	if img_R(x,y,z)~=0
           img_R_mirror(xr-x+1,y,z)=img_R(x,y,z);
        end
	end
      end
    end        

    overlay=zeros(CL_NUM,CL_NUM);
    
    for ki=1:CL_NUM
        for kj=1:CL_NUM
              tmp=(img_L==ki).*(img_R_mirror==kj);
              overlay(ki,kj)=sum(tmp(:));
        end
    end
	% clear standard_cluster vnii_stand tmp
    %overlay=tmp_overlay./repmat(sum(tmp_overlay,2),1,CL_NUM);

    for ki=1:CL_NUM
       overlay(ki,:)=overlay(ki,:)/sum(overlay(ki,:));
    end

    [cind,max]=munkres(-overlay);

    tmp_img=img_R;
    
    for ki=1:CL_NUM
        tmp_img(img_R==cind(ki))=ki;
    end
    nii_R.img=tmp_img;
    save_untouch_nii(nii_R,strcat(PWD,'/',PART,'/','group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',PART,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group_sym.nii.gz'));

    disp(strcat('symmed CL_NUM_',num2str(CL_NUM)));
%else
%    disp(strcat('symmed CL_NUM_',num2str(CL_NUM)));
%end
end
