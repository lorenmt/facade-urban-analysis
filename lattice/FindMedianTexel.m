function [texel,error]=FindMedianTexel(im,nWidIn,cMPT,mIsGood)
[imh,imw,~]=size(im);
[h,w]=size(cMPT);
nWid=[];
for iy=1:h-1
    for ix=1:w-1
        if mIsGood(iy,ix)>0
            pt1=round(cMPT{iy,ix});
            pt2=round(cMPT{iy+1,ix+1});
            nWid=round(sqrt(sum((pt1-pt2).^2))/2);
            
            break;
        end
    end
    if ~isempty(nWid)
        break;
    end
end

nWid=max([nWidIn nWid]);
if nWid>100
    texel=[];
    error=1;
    return;
end
All=zeros(2*nWid+1,2*nWid+1,3,1);
pos=1;
for iy=1:h
    for ix=1:w
        if mIsGood(iy,ix)>0
            
            pt=round(cMPT{iy,ix});
            %fprintf('%f,%f:%d,%d\n',cMPT{iy,ix}(1),cMPT{iy,ix}(2),pt(1),pt(2));
            if pt(2)-nWid>=1 && pt(2)+nWid <=imh &&pt(1)-nWid>=1 &&pt(1)+nWid <=imw
                All(:,:,:,pos)=im(pt(2)-nWid:pt(2)+nWid,pt(1)-nWid:pt(1)+nWid,:);
                %fprintf('%d,%d\n',pt(1)-nWid,pt(2)-nWid);              
                pos=pos+1;
            end
        end
    end
end

texel=uint8(median(All,4));
var_texel=var(All,0,4);
var_val=mean(var_texel(:));
if pos==1 || var_val>3000
    error=1;
else
    error=0;
end

