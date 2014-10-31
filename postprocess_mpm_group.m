function postprocess_mpm_group(PWD,PART,CL_NUM,MPM_THRES,LEFT,RIGHT)
%*****************************************
%����ָ����ɢ��.
%*****************************************
%********************************************

if LEFT == 1
	postprocess_mpm(PWD,PART,CL_NUM,MPM_THRES,1)
end

if RIGHT == 1
	postprocess_mpm(PWD,PART,CL_NUM,MPM_THRES,0)
end

function postprocess_mpm(PWD,PART,CL_NUM,MPM_THRES,LorR)

	if LorR == 1
		LR='L';
	elseif LorR == 0
		LR='R';
	end
	
	disp(strcat('Running postprocess for <',PART,'_',LR,'> ...'));	
	
	MPM_THRES = MPM_THRES * 100;

path = strcat(PWD,'/MPM/');
filename = strcat(PART,'_',LR,'_',num2str(CL_NUM),'_MPM_thr',num2str(MPM_THRES),'_group.nii');

info = load_untouch_nii(strcat(path,filename));
img = info.img;
[m n p] = size(img);
coordinates = zeros(0,0);
z = 1;
for i = 1:m
    for j = 1:n
        for k = 1:p
            if img(i,j,k) ~= 0
               coordinates(z,1) = i;
               coordinates(z,2) = j;
               coordinates(z,3) = k;
               z = z + 1;
            end
        end
    end
end

%ƽ����6����.
label = zeros(1,CL_NUM + 1);
max_index=0;
max_num=0;
for i = 1:length(coordinates)
    label = zeros(1,CL_NUM + 1);
    label_value1 = img(coordinates(i,1)-1,coordinates(i,2),coordinates(i,3)) + 1;
    label(label_value1) = label(label_value1) + 1;
    
    label_value2 = img(coordinates(i,1)+1,coordinates(i,2),coordinates(i,3)) + 1;
    label(label_value2) = label(label_value2) + 1;
    
    label_value3 = img(coordinates(i,1),coordinates(i,2)-1,coordinates(i,3)) + 1;
    label(label_value3) = label(label_value3) + 1;
    
    label_value4 = img(coordinates(i,1),coordinates(i,2)+1,coordinates(i,3)) + 1;
    label(label_value4) = label(label_value4) + 1;
    
    label_value5 = img(coordinates(i,1),coordinates(i,2),coordinates(i,3)-1) + 1;
    label(label_value5) = label(label_value5) + 1;
    
    label_value6 = img(coordinates(i,1),coordinates(i,2),coordinates(i,3)+1) + 1;
    label(label_value6) = label(label_value6) + 1;
    
    wjs = max(label);
    jsh = find(label == wjs);
    if length(jsh)>=2
       b = jsh(1,2) - 1;
    else
       b = jsh - 1;
    end
    img(coordinates(i,1),coordinates(i,2),coordinates(i,3)) = b;
end

img_MPM = img;
info = load_untouch_nii(strcat(path,filename));
info.img = img_MPM;
output = strcat(PART,'_',LR,'_',num2str(CL_NUM),'_MPM_thr',num2str(MPM_THRES),'_group_smoothed.nii');
save_untouch_nii(info,strcat(path,output));

	disp(strcat(PART,'_',LR,' Done!'));

