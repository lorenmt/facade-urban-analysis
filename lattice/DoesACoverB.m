function occupancy=DoesACoverB(A,B,mIsGoodA,mIsGoodB)

[bh,bw]=size(B);
pt=[];
for i=1:bh*bw
    if mIsGoodB(i)>0
      pt=[pt B{i}];  
    end
end


[ah,aw]=size(A);
pos=0;
IDX=zeros(1,size(pt,2));
for iy=1:ah-1
    for ix=1:aw-1
        flag=mIsGoodA(iy,ix)+ mIsGoodA(iy,ix+1)+ mIsGoodA(iy+1,ix+1)+ mIsGoodA(iy+1,ix);
        if flag==4
            pos=pos+1;
            quad=[A{iy,ix} A{iy,ix+1} A{iy+1,ix+1} A{iy+1,ix} A{iy,ix}];
            [in,on]=inpolygon(pt(1,:),pt(2,:),quad(1,:)',quad(2,:)');
            IDX=IDX+in+on;
%             figure(7);clf;plot(quad(1,:),quad(2,:),'-r');
%             hold on;plot(pt(1,:),pt(2,:),'.');
        end
    end
end

occupancy=sum(IDX)/length(IDX);




