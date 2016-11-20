function [cMaxMPT,mMaxIsGood,maxSRC]=FindMotifAffine(cluster1,data,im,threshold,nConn)
if nargin<=3
    threshold=0.2;
    nConn=8;
end
maxSRC=[];
mMaxIsGood=[];
cMaxMPT=[];
debug=0;
%test......
pt=cluster1;
testpt=data;

%preprocessing.....construct the list of adjacent points.....
cnt=size(pt,2);
G=dist2(pt',pt');

AdjList=zeros(cnt,cnt);
for i=1:cnt
    list=G(i,:);
    idless=find(list<2^2 & list>0);
    list(idless)=list(idless)*10000;
    [v,idx]=sort(list);
    AdjList(i,:)=idx';
end

nIter=100;

dst=[0 0;1 0;1 1;0 1];
maxsrcidx=[];
maxcnt=0;
ransacid=round(rand(nIter*10,1)*(cnt-1))+1;
ransacid=unique(ransacid);
for i=1:cnt%length(ransacid)
    %first choose one point....
    
    id1=i;%;ransacid(i);
    %then select 3 points from the adjacent points of the selected....
    %we will try nIter times....
%     id24=round(rand(round(nIter/2),2)*(min(cnt-1,5)-1))+2;
%     id24=sort(id24,2);
%     id24=unique(id24,'rows');
    id24=nchoosek(2:min(cnt,7),2);
    Tmplist=AdjList(id1,:);
    id1324=[ones(size(id24,1),1)*id1 ones(size(id24,1),1)*NaN Tmplist(id24)];
  
    
    
    %enumerate possible pairs.......
    
    %We need to ensure uniqueness of this idx.......
    %=> No this will be filtered in the next....
    
    PT1=pt(:,id1324(:,1));
    PT2=pt(:,id1324(:,3));
    PT4=pt(:,id1324(:,4));
    PT3=PT4+PT2-PT1;
    l1=FindLineFrom2DPoint(PT3,PT1);
    l2=FindLineFrom2DPoint(PT4,PT2);
    midpt=FindIntersect(l1,l2);
    %midpt should be inside quadrilateral
    VEC13=PT3-PT1;
    VEC1M=midpt(1:2,:)-PT1;
    VEC24=PT4-PT2;
    VEC2M=midpt(1:2,:)-PT2;
    
    
    VEC12=PT2-PT1;
    VEC14=PT4-PT1;
    %rotate
    r=10*pi/180;
    R=[cos(r) sin(r);-sin(r) cos(r)];
    rotated=R*VEC13+PT1;
    rotated=[rotated;ones(1,size(rotated,2))];
    signflag=sum(rotated.*l1,1);
    testpt2=[PT2;ones(1,size(PT2,2))];
    signflag2=sum(testpt2.*l1,1);
    testpt4=[PT4;ones(1,size(PT4,2))];
    signflag4=sum(testpt4.*l1,1);
    
    signflag=signflag.*signflag2;
    
    %Then VEC13=scalar * VEC1M and 0<scalar<1 .....
    %and VEC24=scalar *VEC2M and 0<scalar <1....
    flag1=VEC1M./VEC13;
    flag1= flag1>0.2 &flag1<0.8;
    flag2=VEC2M./VEC24;
    flag2= flag2>0.2 &flag2<0.8;
    flag=flag1&flag2;
    flag=flag(1,:);
    
    ids=find(flag>0 );
    midpt=midpt(:,ids);
    signflag=signflag(ids);
    %These flag1 and flag2 should be 0< ..<1...
    %Now for these suggestion we need to arrange pt2 and pt4 in legitimate
    %way........
    id1324=id1324(ids,:);
    pos=1;
    for m=1:size(id1324,1)
        
        id1234=id1324(m,[1 3 2 4]);
        if signflag(m)<0
            id1234=id1234([1 4 3 2]);
        end
        src=zeros(4,2);
        src(1,:)=pt(:,id1234(1))';
        src(2,:)=pt(:,id1234(2))';
        src(4,:)=pt(:,id1234(4))';
        
        
        %Now compute projective transform from src to dst

        src(3,:)=src(2,:)+src(4,:)-src(1,:);
        
        t1=src(1,:)-src(2,:);
        t2=src(1,:)-src(4,:);
        magt1=sqrt(sum(t1.^2));
        magt2=sqrt(sum(t2.^2));
        mag_ratio=min([magt1 magt2])/max([magt1 magt2]);
        cosTh=sum(t1.*t2)/norm(t1)/norm(t2);
        if  mag_ratio <1/3 || cosTh <-0.8 || cosTh >0.8
            continue;
        end
            
            
        
        t=maketform('projective',src,dst);
        [u,v]=tformfwd(t,cluster1(1,:),cluster1(2,:));
        ru=round(u);
        rv=round(v);
        d=sqrt((u-ru).^2+(v-rv).^2);
        id=find(d<threshold);
        d=d(id);
        
        nSize=10;
        mask=zeros(nSize,nSize);
        id_selected=cell(nSize,nSize);
        duplicate_sits=ones(nSize,nSize)*inf;
        for mm=1:length(id)
            y=rv(id(mm))+nSize/2;
            x=ru(id(mm))+nSize/2;
            if x>=1 && x<=nSize && y>=1 && y<=nSize  
                if d(mm)<duplicate_sits(y,x)
                    duplicate_sits(y,x)=d(mm);
                    mask(y,x)=1;
                    id_selected{y,x}=id(mm);
                end
            end
        end
        
        L = bwlabel(mask,nConn);
        
        [id_y,id_x]=find(L==L(nSize/2,nSize/2));
        minx=min(id_x);
        maxx=max(id_x);
        miny=min(id_y);
        maxy=max(id_y);
        cMPT=cell(nSize,nSize);
        mIsGood=zeros(nSize,nSize);
        ids=[];
        for mm=1:length(id_y)
           ids=[ids id_selected{id_y(mm),id_x(mm)}(1)]; 
           cMPT{id_y(mm),id_x(mm)}=[cluster1(1,ids(end));cluster1(2,ids(end))];
           
           mIsGood(id_y(mm),id_x(mm))=1;
        end
        len=length(ids);
        
        if len > maxcnt
           maxcnt=len;
           
           
           %we first predict using inverse perspective......
           [yy,xx]=meshgrid(1:nSize,1:nSize);
           yy=yy(:);
           xx=xx(:);
           [predicted_x,predicted_y]=tforminv(t,xx-nSize/2,yy-nSize/2);
           for ii=1:nSize*nSize
               
               if isempty(cMPT{yy(ii),xx(ii)})
                   cMPT{yy(ii),xx(ii)}=[predicted_x(ii);predicted_y(ii)];
               end
               
           end
           cMaxMPT=cMPT;
           mMaxIsGood=mIsGood;
           maxSRC=src;
           
        end
        if 0
            figure(1);clf;hold on;
            plot([src(1,1) src(3,1)],[src(1,2) src(3,2)] ,'-r');
            plot([src(2,1) src(4,1)],[src(2,2) src(4,2)] ,'-r');
            plot(midpt(1,m),midpt(2,m),'og');
            
            text(src(1,1),src(1,2),'1');
            text(src(2,1),src(2,2),sprintf('2'));
            text(src(3,1),src(3,2),'3');
            text(src(4,1),src(4,2),sprintf('4'));
            plot(midpt(1,m),midpt(2,m),'og');
            pos=pos+1;
        end
    end
    
    
    %Then we need to arrange or test them if they are legitimate ..
    
    
end

%Then randomly select one point p1......then select 3 more points from the
%adjacent list of p1......then compute homography H1 from those 4 points to
%integer coordinates....Then we transfer all the test pt using H1 and count
%the inliers.....if the inliers are above certain number we propose refined
%H1 and repeat the above again until no more pts are added....

%When it converges we record H1 and its inliers and the number of
%inliers.............




%this repeats until maximum iteration reached............

function l=FindLineFrom2DPoint(x1,x2)%3 by N......
x1=[x1;ones(1,size(x1,2))];
x2=[x2;ones(1,size(x2,2))];
l=[x1(2,:).*x2(3,:)-x1(3,:).*x2(2,:);-(x1(1,:).*x2(3,:)-x1(3,:).*x2(1,:));x1(1,:).*x2(2,:)-x1(2,:).*x2(1,:)];


function l=FindIntersect(x1,x2)
l=[x1(2,:).*x2(3,:)-x1(3,:).*x2(2,:);-(x1(1,:).*x2(3,:)-x1(3,:).*x2(1,:));x1(1,:).*x2(2,:)-x1(2,:).*x2(1,:)];
%l is 3 by N.........
l(1,:)=l(1,:)./l(3,:);
l(2,:)=l(2,:)./l(3,:);
l(3,:)=1;

function n2 = dist2(x, c)
%DIST2	Calculates squared distance between two sets of points.
%
%	Description
%	D = DIST2(X, C) takes two matrices of vectors and calculates the
%	squared Euclidean distance between them.  Both matrices must be of
%	the same column dimension.  If X has M rows and N columns, and C has
%	L rows and N columns, then the result has M rows and L columns.  The
%	I, Jth entry is the  squared distance from the Ith row of X to the
%	Jth row of C.
%
%	See also
%	GMMACTIV, KMEANS, RBFFWD
%

%	Copyright (c) Christopher M Bishop, Ian T Nabney (1996, 1997)

[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
if dimx ~= dimc
    error('Data dimension does not match dimension of centres')
end

n2 = (ones(ncentres, 1) * sum((x.^2)', 1))' + ...
    ones(ndata, 1) * sum((c.^2)',1) - ...
    2.*(x*(c'));