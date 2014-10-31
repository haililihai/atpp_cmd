function cross_validation_N_L(wd,prefix,part,sub_list,N,iter,prob_thre,mpm_thre)

mdice=[];
mnmi=[];
mcv=[];
for i=2:N
	disp(strcat('====Processing_L_',num2str(i),'_clusters...===='));
	[mdice(i),mnmi(i),mcv(i)]=cross_validation_mod_L(wd,prefix,part,sub_list,i,iter,prob_thre,mpm_thre)
	disp(strcat('==== L_',num2str(i),'_clusters DONE!===='));
end

save(strcat(wd,'/validation/',part,'_L_indice.mat'),'mdice','mnmi','mcv');

