function [cFinalMPT,mFinalIsGood]=LatticeComplete(im,cMPT,mIsGood,display)

mFinalIsGood=[];
cFinalMPT={};
%For every lattice structur cMPT we need to collect RGB histogram of image
%inside the proposals.

nWid=7;
bwd=150;
ccNewMPT={};
nCollected_MPT=1;
cNewmIsGood={};
cReMPT=cMPT;

impadded=zeros(size(im,1)+2*bwd,size(im,2)+2*bwd,3);
impadded(bwd+1:bwd+size(im,1),bwd+1:bwd+size(im,2),:)=im;
[mH,mW]=size(cReMPT);
for i=1:mH*mW
    cReMPT{i}=cReMPT{i}+[bwd;bwd];
end
error=0;
if sum(mIsGood(:)>0)<=4
    error=1;
    return;
end
seq=1;

for outit=1:2
    [rectim,cRegMPT,mReIsGood,warpH]=ransac_rectify(cReMPT,mIsGood,uint8(impadded));
    mIsGood=mReIsGood;
    if sum(mIsGood(:)>0)<=4
        error = 1;
        return;
    end
    
    %find median texel from rectim..........
    
    [texel,error]=FindMedianTexel(rectim,7,cRegMPT,mIsGood);
    if error==1
        return;
    end
    
    %making image likelihood......
    
    ncc=MexTmpColMatching(rectim,texel);
    
    [y,x, supncc] = nonmaxsup_res(ncc, 4, 0.3);
    if length(y) > 10000
        return;
    end
    if display
        figure(1);clf;subplot(121);imshow(rectim);
        drawLatticeFromCell(cRegMPT,'r',zeros(size(mIsGood)),mIsGood);
        subplot(122);imagesc(supncc);colormap hot;hold on;plot(x,y,'.r');
        print('-f1',sprintf('./movies/growing%.3d.png',seq),'-dpng');
        seq=seq+1;
        a = 'aaaa';
    end
    
    %Now we do this again......
    %From cRegMPT to integer coordinate.....
    osrc=[];
    odes=[];
    for iy=1:mH
        for ix=1:mW
            if mIsGood(iy,ix)>0
                osrc=[osrc cRegMPT{iy,ix}];
                odes=[odes [ix;iy]];
            end
        end
    end
    if display
        figure(1);clf;subplot('position',[0 0 1 1]);imshow(rectim);
        drawLatticeFromCell(cRegMPT,'r',zeros(size(mIsGood)),mIsGood);
        print('-f1',sprintf('./movies/growing%.3d.png',0),'-dpng');
        a='aaaa';
    end
    
    
    src=osrc;
    des=odes;
    
    prev_src=[];
    selected=mIsGood(mIsGood>0);

    for itr=1:10
        if length(selected)<=4
            error = 1;
            return;
        end
        
        [H,~]=FindHomography(src,des,0);
        
        
        mHomo=maketform('projective',H');
        
        X=[x' osrc(1,:)];%maxpts....
        Y=[y' osrc(2,:)];
        [u,v]=tformfwd(mHomo,X,Y);
        iu=round(u);
        iv=round(v);
        dist=sqrt((iu-u).^2+(iv-v).^2);
        in_id=find(dist<0.1);
        if isempty(in_id)
            error=1;
            return;
        end
        %we only need connected component to seed points which is 1,1....
        dist=dist(in_id);
        src=[X(in_id);Y(in_id)];
        des=[iu(in_id);iv(in_id)];
        minx=min([des(1,:) odes(1,:)]);
        maxx=max([des(1,:) odes(1,:)]);
        miny=min([des(2,:) odes(2,:)]);
        maxy=max([des(2,:) odes(2,:)]);
        %error check
        if (maxy-miny+1)*(maxx-minx+1)>1000000
            error=1;
            return;
        end
        %error check
        if maxy-miny+1==1||maxx-minx+1==1
            error=1;
            return;
        end
        mask=zeros(maxy-miny+1,maxx-minx+1);
        idx_map=ones(maxy-miny+1,maxx-minx+1)*inf;
        for kk=1:length(des)%des doesn't contain odes.....
            mask(des(2,kk)-miny+1,des(1,kk)-minx+1)=1;
            idx_map(des(2,kk)-miny+1,des(1,kk)-minx+1)=kk;
        end
        [L,~]=bwlabel(mask,4);
        %check the labels for odes....and we need labels that are covered
        %by odes-min+1 ......
        o_conv_des=odes;
        o_conv_des(1,:)=o_conv_des(1,:)-minx+1;
        o_conv_des(2,:)=o_conv_des(2,:)-miny+1;
        %1D index...
        o_idx=(o_conv_des(1,:)-1)*(maxy-miny+1)+o_conv_des(2,:);
        kk=unique(L(o_idx));
        %Basically we want to collect all the components connected to
        %odes.........selected is the labels that
        selected=[];
        for mmm=1:length(kk)
            selected=[selected idx_map(L==kk(mmm))'];
        end
        
        if selected(1)==inf || isempty(selected)
            error=1;
            return;
        end
        src=src(:,selected);
        des=des(:,selected);
        
        if display
            minx=min(des(1,:));
            maxx=max(des(1,:));
            miny=min(des(2,:));
            maxy=max(des(2,:));
            
            mW=maxx-minx+1;
            mH=maxy-miny+1;
            cTMP=cell(mH,mW);
            mTmpGood=zeros(mH,mW);
            %options 1
            for iy=1:mH
                for ix=1:mW
                    [u,v]=tforminv(mHomo,ix+minx-1,iy+miny-1);
                    cTMP{iy,ix}=[u;v];
                end
            end
            
            for ii=1:size(src,2)
                %       cFinalMPT{des(2,ii)-miny+1,des(1,ii)-minx+1}=src(:,ii);
                mTmpGood(des(2,ii)-miny+1,des(1,ii)-minx+1)=1;
            end
            
            figure(1);clf;subplot('position',[0 0 1 1]);imshow(rectim);
            drawLatticeFromCell(cTMP,'r',zeros(size(mTmpGood)),mTmpGood);
            print('-f1',sprintf('./movies/growing%.3d.png',seq),'-dpng');
            seq=seq+1;
            
            
        end
        if size(prev_src,2)==size(src,2)
            flag=abs(prev_src-src);
            if sum(flag(:))==0
                
                break;
            else
                prev_src= src;
            end
        else
            prev_src= src;
        end
        
    end
    minx=min(des(1,:));
    maxx=max(des(1,:));
    miny=min(des(2,:));
    maxy=max(des(2,:));
    
    mW=maxx-minx+1;
    mH=maxy-miny+1;
    cFinalMPT=cell(mH,mW);
    mIsGood=zeros(mH,mW);
    %options 1
    for iy=1:mH
        for ix=1:mW
            [u,v]=tforminv(mHomo,ix+minx-1,iy+miny-1);
            cFinalMPT{iy,ix}=[u;v];
           % fprintf('%f,%f\n',u,v);
        end
    end
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check from here
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%
    
    for ii=1:size(src,2)
        cFinalMPT{des(2,ii)-miny+1,des(1,ii)-minx+1}=src(:,ii);
        mIsGood(des(2,ii)-miny+1,des(1,ii)-minx+1)=1;
    end
    %inverse cFinalMPT.......using
    [mh,mw]=size(cFinalMPT);
    for iy=1:mh
        for ix=1:mw
            [u,v]=tforminv(warpH,cFinalMPT{iy,ix}(1),cFinalMPT{iy,ix}(2));
         %   fprintf('%f,%f:%d\n',cFinalMPT{iy,ix}(1),cFinalMPT{iy,ix}(2),mIsGood(iy,ix));
            cFinalMPT{iy,ix}=[u;v];
        end
    end
    %Now we decide regions......
    cReMPT=cFinalMPT;
end

mFinalIsGood=mIsGood;


if error==0
    
    for iy=1:mh
        for ix=1:mw
            cFinalMPT{iy,ix}=cFinalMPT{iy,ix}-[bwd;bwd]+[1;1];
        end
    end
    if display
        figure(3);clf;imshow(im);
        drawLatticeFromCell(cFinalMPT,rand(1,3),zeros(size(mIsGood)),mIsGood);
    end
end