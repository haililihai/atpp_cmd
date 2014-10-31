function cross_validation_N_R(wd,prefix,part,sub_list,N,iter,prob_thre,mpm_thre)

mdice=[];
mnmi=[];
mcv=[];
for i=2:N
	disp(strcat('====Processing_R_',num2str(i),'_clusters...===='));
	[mdice(i),mnmi(i),mcv(i)]=cross_validation_mod_R(wd,prefix,part,sub_list,i,iter,prob_thre,mpm_thre)
	disp(strcat('==== R_',num2str(i),'_clusters DONE!===='));
end
save(strcat(wd,'/validation/',part,'_R_indice.mat'),'mdice','mnmi','mcv');


