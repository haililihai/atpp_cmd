function [nminfo,minfo,vi]=my_nmi(x,y)
%computethe normalized mutual information for verctor x and y
% clear all
% vnii=load_untouch_nii('new2/NC001_seg4_lin_new2.nii');
% image1=vnii.img;
% x=image1;
% vnii=load_untouch_nii('new2/NC006_seg4_lin_new2.nii');
% image2=vnii.img;
% y=image2;

addpath('/DATA/233/hli/toolbox');

if ~exist('x','var') | isempty(x) | ~exist('y','var') | isempty(y)
      error('wrong input of vector x or y');
end

if size(x,1)>1
    x=reshape(x,1,length(x(:)));
end
if size(y,1)>1
    y=reshape(y,1,length(y(:)));
end

count=max(max(x),max(y));
px=zeros(count,1);
py=zeros(count,1);
for i=1:count
    px(i)=sum(x==i);
    py(i)=sum(y==i);
end
px=px/sum(x>0);
py=py/sum(y>0);

%compute the entropy for x and y
ex=0;
ey=0;
for i=1:count
    if isinf(log(px(i)))
        logpx=-0.000001;
    else
        logpx=log(px(i));
    end
    ex=ex+px(i)*logpx;
    
    if isinf(log(py(i)))
        logpy=-0.000001;
    else
        logpy=log(py(i));
    end
    ey=ey+py(i)*logpy;
end
ex=-ex;
ey=-ey;

%compute the joint entropy for x,y
[cxy,pxy]=hist_table(x,y);
exy=0;
for i=1:size(pxy,1)
    for j=1:size(pxy,2)
       if isinf(log(pxy(i,j)))
          logpxy=-0.000001;
       else
         logpxy=log(pxy(i,j));
       end
         exy=exy+pxy(i,j)*logpxy;
    end
end
exy=-exy;

%compute the mutual information for x,y
minfo=ex+ey-exy;
nminfo=minfo/min(ex,ey);
vi=ex+ey-2*minfo;
  vi=vi/(ex+ey-minfo);
