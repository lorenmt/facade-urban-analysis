function batchSeg(d)

ims=dir(d);
cd(d);
ims(1:2)=[];
for n=1:length(ims)
    try
        imSeg(ims(n).name);
    catch
        continue;
    end
end
end



function imSeg(imname)

R=500; ol=50;
img=imread(imname);
[Y X Z]=size(img);
if Z==1
    img=repmat(img,[1 1 3]);
end
imname(end-3:end)=[];
for x0=0:(R):X-ol
    x2=min(X,x0+R+ol);
    for y0=0:(R):Y-ol
        y2=min(Y, y0+R+ol);
        patch=img(y0+1:y2,x0+1:x2,:);
        imwrite(patch,sprintf('%s%s_%.4d_%.4d.jpg','seg_',imname,x0,y0));
    end
end
end