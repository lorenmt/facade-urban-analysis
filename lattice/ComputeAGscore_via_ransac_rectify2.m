function [nA, TexelStd, Ascore] = ComputeAGscore_via_ransac_rectify2(ccMPT,cmIsGood,im)

%seed idx;;;;
nA = inf;
TexelStd = 0;
Ascore = 0;
[h,w]=size(cmIsGood);
cRegMPT=ccMPT;


%We will cross out for the intersected lattice...
x1=[ccMPT{1,1};1]; x2=[ccMPT{1,w};1];
L1=CrossProduct(x1,x2);
x3=[ccMPT{h,1};1]; x4=[ccMPT{h,w};1];
L2=CrossProduct(x3,x4);
crss1=CrossProduct(L1,L2);
x5=[ccMPT{1,1};1]; x6=[ccMPT{h,1};1];
L3=CrossProduct(x5,x6);
x7=[ccMPT{1,w};1]; x8=[ccMPT{h,w};1];
L4=CrossProduct(x7,x8);
crss2=CrossProduct(L3,L4);

crss1=crss1(1:2)/crss1(3);
crss2=crss2(1:2)/crss2(3);

%These points should not be on the lines L1,L2,L3,L4
vec1=x2(1:2)-crss1;
vec2=x1(1:2)-crss1;
vec12=x2(1:2)-x1(1:2);

vec3=x5(1:2)-crss2;
vec4=x6(1:2)-crss2;
vec34=x6(1:2)-x5(1:2);

f1=abs(mean(vec1./vec12));
f2=abs(mean(vec2./vec12));
f3=abs(mean(vec3./vec34));
f4=abs(mean(vec4./vec34));

if (f1<1 && f2<1) || (f3<1 &&f4<1)
    return;
end

seed_ix=round(w/2);
seed_iy=round(h/2);

t1=ccMPT{seed_iy,seed_ix+1}-ccMPT{seed_iy,seed_ix};
t2=ccMPT{seed_iy+1,seed_ix}-ccMPT{seed_iy,seed_ix};


srcpt=[];
dstpt=[];
for iy=1:h
    for ix=1:w
        cRegMPT{iy,ix}=ccMPT{seed_iy,seed_ix}+t1*(ix-w/2-1)+t2*(iy-h/2-1);
        if cmIsGood(iy,ix)>0
            srcpt=[srcpt ccMPT{iy,ix}];
            dstpt=[dstpt cRegMPT{iy,ix}];
        end
    end
end
check=0;
for iy=1:h-1
    for ix=1:w-1
        flag=cmIsGood(iy,ix)+cmIsGood(iy,ix+1)+cmIsGood(iy+1,ix+1)+cmIsGood(iy+1,ix);
        if flag==4
            check=check+1;
        end
    end
end
if check<2
    return;    
end

[H,inlier]=FindHomography(srcpt,dstpt,0.5);
if H(3,3)~=1
    [H,inlier]=FindHomography(srcpt,dstpt,0);
end
mReIsGood=cmIsGood;
pos=1;
for iy=1:h
    for ix=1:w
        if cmIsGood(iy,ix)>0
            if inlier(pos)==0
                mReIsGood(iy,ix)=0;
            end
            pos=pos+1;
        end
    end
end

%Now we compute A and G score.....
bFirst=1;
T = [];
pos=0;
[imh,imw,~]=size(im);


tw=40;
th=40;
ptdst=[1 1;tw 1;tw th;1 th];

%ptdst=[cRegMPT{1,1} cRegMPT{1,1+1} cRegMPT{1+1,1+1} cRegMPT{1+1,1}];
%ptdst=round(ptdst);


for iy=1:h-1
    for ix=1:w-1
        flag=mReIsGood(iy,ix)+mReIsGood(iy,ix+1)+mReIsGood(iy+1,ix+1)+mReIsGood(iy+1,ix);
        if flag >= 3
            %
            ptsrc=[ccMPT{iy,ix} ccMPT{iy,ix+1} ccMPT{iy+1,ix+1} ccMPT{iy+1,ix}];
            minx=min(ptsrc(1,:));
            maxx=max(ptsrc(1,:));
            miny=min(ptsrc(2,:));
            maxy=max(ptsrc(2,:));
            if minx>=1 && maxx <=imw && miny>=1 && maxy<=imh
                try
                    T = maketform('projective',ptsrc',ptdst);
                    A = imtransform(im,T,'XData',[1 tw],'YData',[1 th]);
                    if bFirst==1
                        bFirst=0;
                        Texel=zeros(size(A,1),size(A,2),size(A,3),2);
                    end
                    pos=pos+1;
                    Texel(:,:,:,pos)=double(A);
                end
            end
        end
    end
end
if bFirst==1
    return;
end
mT=median(Texel,4);
Texel=Texel(:,:,:,1:pos);
A = var(Texel,0,4);
A = sqrt(A);
nA = mean(A(:))/max(pos,eps);
mH = maketform('projective',H');
gray=mean(double(mT),3);
if std(gray(:))<3
    nA = Inf;
end

dx=imfilter(gray,[-1 0 1]);
dy=imfilter(gray,[-1 0 1]');
mag=sqrt(dx.^2+dy.^2);

flag = sum(mag(:))/size(A,1)/size(A,2);

TexelStd = std(gray(:));
Ascore = sum(A(:));

end





  






