function indice_plot(wd,part,N)
	file_L=strcat(wd,'/validation/',part,'_L_indice.mat');
	load(file_L)
	x=2:N;
	plot(x,mcv(2:end),'-r',x,mdice(2:end),'--g',x,mnmi(2:end),'-.b','Marker','*');
	legend('mCV','mDice','mNMI','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(part,' L stability indice'),'FontSize',14);
	output_L=strcat(wd,'/validation/',part,'_L_indice.jpg');
	hgexport(gcf,output_L,hgexport('factorystyle'),'Format','jpeg');

	file_R=strcat(wd,'/validation/',part,'_R_indice.mat');
	load(file_R)
	x=2:N;
	plot(x,mcv(2:end),'-r',x,mdice(2:end),'--g',x,mnmi(2:end),'-.b','Marker','*');
	legend('mCV','mDice','mNMI','Location','SouthWest');
	xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
	title(strcat(part,' R stability indice'),'FontSize',14);
	output_R=strcat(wd,'/validation/',part,'_R_indice.jpg');
	hgexport(gcf,output_R,hgexport('factorystyle'),'Format','jpeg');
end
