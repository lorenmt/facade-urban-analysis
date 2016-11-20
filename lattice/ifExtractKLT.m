function [bklt]=ifExtractKLT(impath,ptNum)
window=3;
qual=0.01;
automatic=1;
% bklt=OSX_BlockWiseKLTPropose(impath,window,qual,ptNum,automatic);
% clear OSX_BlockWiseKLTPropose;

%bklt=ExtractBWKLTplusHistEQ(impath,window,qual,ptNum,automatic);

bklt=ExtractKLT(impath,3,window,qual,ptNum);
while size(bklt,2)<ptNum*0.9 && qual>0.000001
    qual = qual*0.9;
    bklt=ExtractKLT(impath,3,window,qual,ptNum);
end
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

idx=bklt(2,:)+bklt(1,:)*h;
val=mag(idx);
filteredid=find(val>0.1);
bklt=bklt(:,filteredid);
