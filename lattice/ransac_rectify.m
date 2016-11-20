function [A,cRegMPT,mReIsGood,mH]=ransac_rectify(cMPT,mIsGood,im)
%seed idx;;;;


[h,w]=size(mIsGood);
seed_ix=round(w/2);
seed_iy=round(h/2);
% 
% %test...
% for iy=1:h
%     for ix=1:w
%         pt=cMPT{iy,ix};
%         fprintf('%f,%f\n',pt(1),pt(2));
%     end
% end


t1=cMPT{seed_iy,seed_ix+1}-cMPT{seed_iy,seed_ix};
t2=cMPT{seed_iy+1,seed_ix}-cMPT{seed_iy,seed_ix};


% fprintf('t1: %f,%f\n',t1(1),t1(2));
% fprintf('t2: %f,%f\n',t2(1),t2(2));
cRegMPT=cMPT;

srcpt=[];
dstpt=[];
for iy=1:h
    for ix=1:w
        cRegMPT{iy,ix}=cMPT{seed_iy,seed_ix}+t1*(ix-seed_ix)+t2*(iy-seed_iy);

        if mIsGood(iy,ix)>0
           srcpt=[srcpt cMPT{iy,ix}];
           dstpt=[dstpt cRegMPT{iy,ix}];
%            fprintf('(%f,%f)\n',cMPT{iy,ix}(1),cMPT{iy,ix}(2));
%            fprintf('(%f,%f)\n',cRegMPT{iy,ix}(1),cRegMPT{iy,ix}(2));
           
        end
    end
end

[H,inlier]=FindHomography(srcpt,dstpt,0.5);

% 
% fprintf('\n%f,%f,%f\n',H(1,1),H(1,2),H(1,3));
% fprintf('%f,%f,%f\n',H(2,1),H(2,2),H(2,3));
% fprintf('%f,%f,%f\n',H(3,1),H(3,2),H(3,3));
    
    
    
if H(3,3)~=1
    [H,inlier]=FindHomography(srcpt,dstpt,0);
end
mReIsGood=mIsGood;
pos=1;
for iy=1:h
    for ix=1:w
        if mIsGood(iy,ix)>0
            if inlier(pos)==0
                mReIsGood(iy,ix)=0;
            end
            pos=pos+1;
        end
    end
end


mH=maketform('projective',H');

[A,xd,yd]=imtransform(im,mH,'Xdata',[1 size(im,2)],'YData',[1 size(im,1)]);
a='aaa';
% 
% 
% 
% for iy=1:h
%     for ix=1:w
%         cRegMPT{iy,ix}=cRegMPT{iy,ix}+[-xd(1)+1;-yd(1)+1];
%         
%     end
% end









