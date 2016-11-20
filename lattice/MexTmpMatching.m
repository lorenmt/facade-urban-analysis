function [map]=MexTmpMatching(im,tmp,mask)

[h,w,c]=size(im);
    
[th,tw,tc]=size(tmp);
if c>1
    im=rgb2gray(im);
end
if tc>1
    tmp=rgb2gray(tmp);
end
if mean(tmp)<=1
    im=uint8(im*255);
    tmp=uint8(tmp*255);
end
im=double(im);
tmp=double(tmp);


if nargin >2
 tmp=tmp.*mask;
end
    
[th,tw,tc]=size(tmp);

bh=floor(th/2);
bw=floor(tw/2);

imnew=zeros(h+2*bh,w+2*bw);
imnew(bh+1:bh+h,bw+1:bw+w)=im;
ROI=-1;
if ismac
    map=OSX_TemplateMatching(imnew,tmp,ROI);
else
    map=TemplateMatching(imnew,tmp,ROI);
end
map=map(1:h,1:w);
