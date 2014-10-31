function [mdice,mnmi,mcv]=cross_validation_mod_R(wd,prefix,part,sub_list,kc,iter,prob_thre,mpm_thre)

addpath('/DATA/233/hli/toolbox');

sub=textread(sub_list,'%s');
sub_num=length(sub);
if ~exist('kc','var') | isempty(kc)
    kc=3;
end
% if ~exist('reg','var') | isempty(reg)
%     reg='nonlin';
% end
if ~exist('prob_thre','var') | isempty(prob_thre)
    prob_thre=0.5;
end
if ~exist('mpm_thre','var') | isempty(mpm_thre)
    mpm_thre=0.5;
end

% sub=textread(strcat(wd,'list_sub_seg.txt'),'%s');
% sub_num=length(sub);
% kc=6;
% reg='nonlin';
% prob_thre=0;
% mpm_thre=0;
% flag_prob=0;
% if  isfield(para,'seg'), seg=para.seg;else seg='';end;

N=iter; %modified by haili
n1=floor(sub_num/2);
dice=zeros(N,2);
nminfo=zeros(N,2);
cv=zeros(N,1);
list1_sub={};
list2_sub={};
for ti=1:N
    tmp=randperm(sub_num);
    list1_sub={sub{tmp(1:n1)}}';
    list2_sub={sub{tmp(n1+1:sub_num)}}';
    mpm_cluster1=cluster_mpm_mod_R(wd,prefix,part,list1_sub,kc,prob_thre,mpm_thre);
    mpm_cluster2=cluster_mpm_mod_R(wd,prefix,part,list2_sub,kc,prob_thre,mpm_thre);
    
    %compute dice coefficent
    num=0;
    den=0;
    dice_m=zeros(kc,1);
    for ki=1:kc
        tmp1=(mpm_cluster1==ki);
        tmp2=(mpm_cluster2==ki);
        num=num+length(find(tmp1.*tmp2>0));
        den=den+length(find(tmp1+tmp2>0));
        dice_m(ki)=2*length(find(tmp1.*tmp2>0))/length(find(tmp1+tmp2>0));
    end
    dice(ti,1)=2*num/den;
    dice_m(isnan(dice_m))=0;
    dice(ti,2)=mean(dice_m);
    
    %compute the normalized mutual information
    [nminfo(ti,1),nminfo(ti,2)]=my_nmi(mpm_cluster1,mpm_cluster2);
    
    %compute cramer V
    [cxy,pxy]=hist_table(mpm_cluster1,mpm_cluster2);
    cv(ti)=my_cramerv(pxy);
    
    disp(strcat('iter: ',num2str(ti),'/',num2str(N)));
end
if ~exist(strcat(wd,'/validation')) mkdir(strcat(wd,'/validation'));end
fp=fopen(strcat(wd,'/validation/',part,'_R_stability_index.txt'),'at');
if fp
    fprintf(fp,'%s','cluster num = ');
    fprintf(fp,'%d',kc);
    fprintf(fp,'\n');
    fprintf(fp,'%s','  dice: mean = ');
    fprintf(fp,'%f  %f',mean(dice));
    fprintf(fp,'%s',' , std = ');
    fprintf(fp,'%f  %f',std(dice));
    fprintf(fp,'\n');
    fprintf(fp,'%s','  mutual info: mi(nmi) = ');
    fprintf(fp,'%f  %f',mean(nminfo));
    fprintf(fp,'\n');
    fprintf(fp,'%s','  cramer V: cv = ');
    fprintf(fp,'%f  %f',mean(cv));
    fprintf(fp,'\n');
	fprintf(fp,'mdice: %f, mnmi: %f, mcv: %f',mean(dice(:,2))/2,mean(nminfo(:,1)),mean(cv));
    fprintf(fp,'\n');
	fprintf(fp,'\n');
end
fclose(fp);

mdice=mean(dice(:,2))/2;
mnmi=mean(nminfo(:,1));
mcv=mean(cv);
