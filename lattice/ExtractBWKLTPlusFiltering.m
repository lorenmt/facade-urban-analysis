function [bklt]=ExtractBWKLTPlusFiltering(impath)
window=3;
qual=0.1;
ptNum=30;
automatic=1;
% bklt=OSX_BlockWiseKLTPropose(impath,window,qual,ptNum,automatic);
% clear OSX_BlockWiseKLTPropose;

%bklt=ExtractBWKLTplusHistEQ(impath,window,qual,ptNum,automatic);
bklt=ifExtractKLT(impath,3000);
im=imread(impath);
if size(im,3)==1
    im=double(im);
else
    im=double(rgb2gray(im));
end

im=im/max(im(:));
dx=imfilter(im,[-1 0 1;-2 0 2;-1 0 1]);    
dy=imfilter(im,[-1 0 1;-2 0 2;-1 0 1]');    
mag=dx.^2+dy.^2;
mag=sqrt(mag);
bklt=round(bklt);

[h,w]=size(im);

idx=bklt(2,:)+(bklt(1,:)-1)*h;
val=mag(idx);
filteredid=find(val>0.1);
bklt=bklt(:,filteredid);
