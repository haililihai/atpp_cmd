function [result,presult,des]=hist_table(x,y)
%compute the 2 dimensional frequency of (x,y)

% vnii=load_untouch_nii('new2/NC001_seg2_lin_new2.nii');
% image1=vnii.img;
% x=image1;
% vnii=load_untouch_nii('new2/NC003_seg2_lin_new2.nii');
% image2=vnii.img;
% y=image2;

if ~exist('x','var') | isempty(x) | ~exist('y','var') | isempty(y)
      error('wrong input of vector x or y');
end

if size(x,1)>1
    x=reshape(x,1,length(x(:)));
end
if size(y,1)>1
    y=reshape(y,1,length(y(:)));
end

minx=min(x);
maxx=max(x);
miny=min(y);
maxy=max(y);

xx=unique(x(x>0));
yy=unique(y(y>0));
m=length(xx);
n=length(yy);
result=zeros(m,n);
for xi=1:length(xx)
    tmp1=(x==xx(xi));
    for yi=1:length(yy)
        tmp2=(y==yy(yi));
        result(xi,yi)=sum(tmp1.*tmp2);
    end
end

presult=result/sum(result(:));
% for xi=1:length(xx)
%     presult(xi,:)=presult(xi,:)/sum(x==xx(xi));
% end
% for yi=1:length(yy)
%     presult(:,yi)=presult(:,yi)/sum(y==yy(yi));
% end

des=[minx,maxx,m;miny,maxy,n];
        
