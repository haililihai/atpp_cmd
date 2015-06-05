function [nminfo,minfo,vi]=my_nmi(x,y)
%computethe normalized mutual information and variation of information for verctor x and y


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
    if isinf(log2(px(i)))
        logpx=-0.000001;
    else
        logpx=log2(px(i)); %log2
    end
    ex=ex+px(i)*logpx;
    
    if isinf(log2(py(i)))
        logpy=-0.000001;
    else
        logpy=log2(py(i));
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
       if isinf(log2(pxy(i,j)))
          logpxy=-0.000001;
       else
         logpxy=log2(pxy(i,j));
       end
         exy=exy+pxy(i,j)*logpxy;
    end
end
exy=-exy;

%compute the mutual information for x,y
minfo=ex+ey-exy;
nminfo=2*minfo/(ex+ey);  % normalized (ex+ey)/2 is a tight upper bound on minfo 
vi=ex+ey-2*minfo; % non-normalized
%  vi=vi/(ex+ey-minfo);
