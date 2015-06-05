function indice_plot(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LEFT,RIGHT)

	addpath('/mnt/software/matlab/toolbox/stats');

	% methods
	split_half=1;
	pairwise=1;
	leave_one_out=1;
	continuity=1;
	hi=1;
	vi=1;

	if split_half==1
	    if LEFT==1
	        plot_split_half(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
	    end
	    if RIGHT==1
	        plot_split_half(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
	    end
	end

	if leave_one_out==1
	    if LEFT==1
	        plot_leave_one_out(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
	    end
	    if RIGHT==1
	        plot_leave_one_out(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
	    end
	end

	if pairwise==1
	    if LEFT==1
	        plot_pairwise(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
	    end
	    if RIGHT==1
	        plot_pairwise(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
	    end
	end

	if continuity==1
	    if LEFT==1
	        plot_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
	    end
	    if RIGHT==1
	        plot_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
	    end
	end

	if hi==1
	    if LEFT==1
	        plot_hi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
	    end
	    if RIGHT==1
	        plot_hi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
	    end
	end

	if vi==1
	    if LEFT==1
	        plot_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
	    end
	    if RIGHT==1
	        plot_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
	    end
	end

function plot_split_half(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_split_half.mat');
	load(file);
	x=2:MAX_CL_NUM;

	m_dice=reshape(mean(dice(:,2,:)),1,length(mean(dice(:,2,:))));
	std_dice=reshape(std(dice(:,2,:)),1,length(std(dice(:,2,:))));
	m_nmi=reshape(mean(nminfo(:,1,:)),1,length(mean(nminfo(:,1,:))));
	std_nmi=reshape(std(nminfo(:,1,:)),1,length(std(nminfo(:,1,:))));
	m_cv=reshape(mean(cv(:,1,:)),1,length(mean(cv(:,1,:))));
	std_cv=reshape(std(cv(:,1,:)),1,length(std(cv(:,1,:))));

	hold on;
	errorbar(x,m_dice(2:end),std_dice(2:end),'-r','Marker','*');
	errorbar(x,m_nmi(2:end),std_nmi(2:end),'-b','Marker','*');
	errorbar(x,m_cv(2:end),std_cv(2:end),'-g','Marker','*');
	hold off;

	set(gca,'XTick',x);
	legend('Dice','NMI','CV','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' split half'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_split_half.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

	% VI with non-significant label
	m_vi=mean(vi);
	std_vi=std(vi);
	errorbar(x,m_vi(2:end),std_vi(2:end),'-r','Marker','*');
	for k=2:MAX_CL_NUM-1
		h=ttest2(vi(:,k),vi(:,k+1),0.05,'left');
		if h==0
			sigstar({[k,k+1]},[nan]);
		end
	end

	set(gca,'XTick',x);
	xlabel('Number of clusters','FontSize',14);ylabel('VI','FontSize',14);
	title(strcat(PART,'.',LR,' split half VI'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_split_half_vi.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

function plot_leave_one_out(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_leave_one_out.mat');
	load(file);
	x=2:MAX_CL_NUM;

	m_dice=reshape(mean(dice(:,2,:)),1,length(mean(dice(:,2,:))));
	std_dice=reshape(std(dice(:,2,:)),1,length(std(dice(:,2,:))));
	m_nmi=reshape(mean(nminfo(:,1,:)),1,length(mean(nminfo(:,1,:))));
	std_nmi=reshape(std(nminfo(:,1,:)),1,length(std(nminfo(:,1,:))));
	m_cv=reshape(mean(cv(:,1,:)),1,length(mean(cv(:,1,:))));
	std_cv=reshape(std(cv(:,1,:)),1,length(std(cv(:,1,:))));

	hold on;
	errorbar(x,m_dice(2:end),std_dice(2:end),'-r','Marker','*');
	errorbar(x,m_nmi(2:end),std_nmi(2:end),'-b','Marker','*');
	errorbar(x,m_cv(2:end),std_cv(2:end),'-g','Marker','*');
	hold off;

	set(gca,'XTick',x);
	legend('Dice','NMI','CV','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' leave one out'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_leave_one_out.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

	% VI with non-significant label
	m_vi=mean(vi);
	std_vi=std(vi);
	errorbar(x,m_vi(2:end),std_vi(2:end),'-r','Marker','*');
	for k=2:MAX_CL_NUM-1
		h=ttest2(vi(:,k),vi(:,k+1),0.05,'left');
		if h==0
			sigstar({[k,k+1]},[nan]);
		end
	end

	set(gca,'XTick',x);
	xlabel('Number of clusters','FontSize',14);ylabel('VI','FontSize',14);
	title(strcat(PART,'.',LR,' leave one out VI'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_leave_one_out_vi.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

function plot_pairwise(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_pairwise.mat');
	load(file);
	x=2:MAX_CL_NUM;

	mat_cv=[];
	mat_dice=[];
	mat_nmi=[];
	mat_vi=[];
	for kc=2:MAX_CL_NUM
		col_cv=cv(:,:,kc);
        col_cv=col_cv(find(col_cv~=0));
        mat_cv=[mat_cv col_cv];
        col_dice=dice(:,:,kc);
        col_dice=col_dice(find(col_dice~=0));
        mat_dice=[mat_dice col_dice];
        col_nmi=nminfo(:,:,kc); 
        col_nmi=col_nmi(find(col_nmi~=0));
        mat_nmi=[mat_nmi col_nmi];
        col_vi=vi(:,:,kc); 
        col_vi=col_vi(find(col_vi~=0));
        mat_vi=[mat_vi col_vi];
    end

	hold on;
	errorbar(x,mean(mat_dice),std(mat_dice),'-r','Marker','*');
	errorbar(x,mean(mat_nmi),std(mat_nmi),'-b','Marker','*');
	errorbar(x,mean(mat_cv),std(mat_cv),'-g','Marker','*');
	hold off;

	set(gca,'XTick',x);
	legend('Dice','NMI','CV','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' pairwise'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_pairwise.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

	% VI with non-significant label
	errorbar(x,mean(mat_vi),std(mat_vi),'-r','Marker','.');
	for k=2:MAX_CL_NUM-1
		h=ttest2(vi(:,k),vi(:,k+1),0.05,'left');
		if h==0
			sigstar({[k,k+1]},[nan]);
		end
	end

	set(gca,'XTick',x);
	xlabel('Number of clusters','FontSize',14);ylabel('VI','FontSize',14);
	title(strcat(PART,'.',LR,' pairwise VI'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_pairwise_vi.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;

function plot_cont(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_continuity.mat');
	load(file1);
	file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_continuity.mat');
	load(file2);
	x=2:MAX_CL_NUM;

	m_indi_cont=mean(indi_cont');
	std_indi_cont=std(indi_cont');

	hold on;
	plot(x,group_cont(2:end),'-r','Marker','*');
	errorbar(x,m_indi_cont(2:end),std_indi_cont(2:end),'-b','Marker','*');
	hold off;

	set(gca,'XTick',x);
	legend('group cont','indi cont','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' continuity'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_continuity.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;


function plot_hi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_hi.mat');
	load(file1);
	file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_hi.mat');
	load(file2);
	x=3:MAX_CL_NUM;

	m_indi_hi=mean(indi_hi);
	std_indi_hi=std(indi_hi);

	hold on;
	plot(x,group_hi(3:end),'-r','Marker','*');
	errorbar(x,m_indi_hi(3:end),std_indi_hi(3:end),'-b','Marker','*');
	hold off;

	set(gca,'XTick',x);
	legend('group hi','indi hi','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' hierarchy index'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_hi.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;


function plot_vi(PWD,PART,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

	if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

	file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_group_hi.mat');
	load(file1);
	file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_index_indi_hi.mat');
	load(file2);
	x=3:MAX_CL_NUM;

	m_indi_vi=mean(indi_vi);
	std_indi_vi=std(indi_vi);

	hold on;
	plot(x,group_vi(3:end),'-r','Marker','*');
	errorbar(x,m_indi_vi(3:end),std_indi_vi(3:end),'-b','Marker','*');
	for k=3:MAX_CL_NUM-1
		h1=ttest2(indi_vi(:,k),indi_vi(:,k+1),0.05,'left');
		if h1==1
			sigstar({[k,k+1]},[0.01]);
		end
		h2=ttest2(indi_vi(:,k),indi_vi(:,k+1),0.05,'right');
		if h2==1
			sigstar({[k,k+1]},[0.05]);
		end
	end
	hold off;

	set(gca,'XTick',x);
	legend('group vi','indi vi','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(PART,'.',LR,' variation of information'),'FontSize',14);

	output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',PART,'_',LR,'_vi.jpg');
	hgexport(gcf,output,hgexport('factorystyle'),'Format','jpeg');

	close;


