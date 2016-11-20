function im = remBorder(im)

if size(im,3)==3
    gim=rgb2gray(im);
else
    gim=im;
end
hpos = mean(gim,1);
vpos = mean(gim,2);
th=250;
x1=find(hpos<th,1,'first');
x2=find(hpos<th,1,'last');
y1=find(vpos<th,1,'first');
y2=find(vpos<th,1,'last');
im=im(y1:y2,x1:x2,:);

