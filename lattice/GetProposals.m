function [ccMPT,cmIsGood,elpasedtime]=GetProposals(imname,impath)

display = 0;
nConn = 4;
nThreshold=0.2;
im = imread(impath);
if size(im,3)==1
    imgray=im;
else
    imgray=rgb2gray(im);
end
[h,w,~]=size(im);

ccMPT={};
cmIsGood={};
cSrc={};
pos=0;
tic
if 1
    [bklt] = ExtractBWKLTPlusFiltering(impath);    
    bklt = round(bklt);
    [bklt,vec_bklt] = MexExtractPatchInterface(imgray,5,bklt);    
    
    vec_bklt = [bklt(1,:)/w; bklt(2,:)/h;vec_bklt];    
    cKLTMember = MSClustering(vec_bklt,6,bklt);    
   
    for k = 1:length(cKLTMember)
        if size(cKLTMember{k},2) > 7
            tmp=cKLTMember{k};
            
            [cMPT,mIsGood,src]=FindMotifAffine(tmp(1:2,:),tmp(1:2,:),im,nThreshold,nConn);
        
            if ~isempty(cMPT)
                pos=pos+1;
                ccMPT{pos}=cMPT;
                cmIsGood{pos}=mIsGood;
                cSrc{pos}=src;
                if display
                    figure(5);clf;imshow(im);hold on;
                    plot([src(:,1)' src(1,1)],[src(:,2)' src(1,2)],'-b','linewidth',2);
                    hold on;plot(tmp(1,:),tmp(2,:),'.g');
                    drawLatticeFromCell(cMPT,'r',zeros(size(mIsGood)),mIsGood);hold on;
                    pause;
                end
            end
        end
    end
end

if size(im,3)>1
    eqim=histeq(rgb2gray(im));
else
    eqim=histeq(im);
end
%imwrite(eqim,'./tmp.jpg','jpg');

[~,FP]=vl_mser(uint8(eqim),'BrightOnDark',1,'DarkOnBright',0,'MaxArea',30*30/h/w,'MaxVariation',0.5,'MinArea',20/h/w);
[~,FM]=vl_mser(uint8(eqim),'BrightOnDark',0,'DarkOnBright',1,'MaxArea',30*30/h/w,'MaxVariation',0.5,'MinArea',20/h/w);

FM=vl_ertr(FM);
FP=vl_ertr(FP);

[newFP,~]=GetMSERRectangle(FP);
[newFM,~]=GetMSERRectangle(FM);

newFP=round(newFP);
newFM=round(newFM);

[pts_FM,vec_FM]=MexExtractPatchInterface(imgray,5,newFM(1:2,:));
clear ExtractPatch;

[pts_FP,vec_FP]=MexExtractPatchInterface(imgray,5,newFP(1:2,:));
clear ExtractPatch;

vec_FM=[pts_FM(1,:)/w ;pts_FM(2,:)/h; vec_FM];
vec_FP=[pts_FP(1,:)/w ;pts_FP(2,:)/h; vec_FP];

cMSERmMember=MSClustering(vec_FM,7,pts_FM);
cMSERpMember=MSClustering(vec_FP,7,pts_FP);

if 1
    tic;
    for k=1:length(cMSERmMember)
        if size(cMSERmMember{k},2)>5
            tmp=cMSERmMember{k};

            [cMPT,mIsGood,src]=FindMotifAffine(tmp(1:2,:),tmp(1:2,:),im,0.3,nConn);
            if ~isempty(cMPT)
                pos=pos+1;
                ccMPT{pos}=cMPT;
                cmIsGood{pos}=mIsGood;
                cSrc{pos}=src;
                if display
                    figure(5);clf;imshow(im);hold on;
                    plot([src(:,1)' src(1,1)],[src(:,2)' src(1,2)],'-b','linewidth',2);
                    hold on;plot(tmp(1,:),tmp(2,:),'.g');
                    drawLatticeFromCell(cMPT,'r',zeros(size(mIsGood)),mIsGood);hold on;
                    pause;
                end
            end
        end
    end  
end


if 1
   for k=1:length(cMSERpMember)
        if size(cMSERpMember{k},2)>5
            tmp=cMSERpMember{k};
            
            [cMPT,mIsGood,src]=FindMotifAffine(tmp(1:2,:),tmp(1:2,:),im,0.3,nConn);
            
            if ~isempty(cMPT)
                pos=pos+1;
                ccMPT{pos}=cMPT;
                cmIsGood{pos}=mIsGood;
                cSrc{pos}=src;
                if display
                    figure(5);clf;imshow(im);hold on;
                    plot([src(:,1)' src(1,1)],[src(:,2)' src(1,2)],'-b','linewidth',2);
                    hold on;plot(tmp(1,:),tmp(2,:),'.g');
                    drawLatticeFromCell(cMPT,'r',zeros(size(mIsGood)),mIsGood);hold on;
                    pause;
                end
            end
        end
   end   
end


[SURF,desc]=ExtractSURF(impath,1,200);
SURF(1,:)=SURF(1,:)+1;
SURF(2,:)=SURF(2,:)+1;

SURF_p=SURF(:,SURF(3,:)>0);
desc_p=desc(:,SURF(3,:)>0);

SURF_m=SURF(:,SURF(3,:)<0);
desc_m=desc(:,SURF(3,:)<0);

cSURFpMember = MSClustering(desc_p,0.3,SURF_p);
cSURFmMember = MSClustering(desc_m,0.3,SURF_m);

if 1    
    for m=1:length(cSURFmMember)
        tmp=cSURFmMember{m};
        if length(tmp)>10
            
            for i=1:size(tmp,2)
                c=cos(tmp(5,i)*pi/180);
                s=sin(tmp(5,i)*pi/180);
                arrowlength=10;
                src=tmp(1:2,i);
                dst=tmp(1:2,i)+[-s*-arrowlength;c*-arrowlength];
                %plot(tmp(1,i),tmp(2,i),'go');
                %plot([src(1) dst(1)],[src(2) dst(2)],'g');
            end        
    
            [cMPT,mIsGood,src]=FindMotifAffine(tmp(1:2,:),tmp(1:2,:),im,nThreshold,nConn);    
            
            if ~isempty(cMPT)
                pos=pos+1;
                ccMPT{pos} = cMPT;
                cmIsGood{pos} = mIsGood;
                cSrc{pos} = src;
                if display
                    figure(5);clf;imshow(im);hold on;
                    plot([src(:,1)' src(1,1)],[src(:,2)' src(1,2)],'-b','linewidth',2);
                    hold on;plot(tmp(1,:),tmp(2,:),'.g');
                    drawLatticeFromCell(cMPT,'r',zeros(size(mIsGood)),mIsGood);hold on;
                    pause;
                end
            end
        end
    end

    for m=1:length(cSURFpMember)
        tmp=cSURFpMember{m};
        if length(tmp)>10
            
            for i=1:size(tmp,2)
                c=cos(tmp(5,i)*pi/180);
                s=sin(tmp(5,i)*pi/180);
                arrowlength=10;
                src=tmp(1:2,i);
                dst=tmp(1:2,i)+[-s*-arrowlength;c*-arrowlength];
                %plot(tmp(1,i),tmp(2,i),'go');
                %plot([src(1) dst(1)],[src(2) dst(2)],'g');
            end
    
            [cMPT,mIsGood,src]=FindMotifAffine(tmp(1:2,:),tmp(1:2,:),im,nThreshold,nConn);
    
            if ~isempty(cMPT)
                pos=pos+1;
                ccMPT{pos}=cMPT;
                cmIsGood{pos}=mIsGood;
                cSrc{pos}=src;
                if display
                    figure(5);clf;imshow(im);hold on;
                    plot([src(:,1)' src(1,1)],[src(:,2)' src(1,2)],'-b','linewidth',2);
                    hold on;plot(tmp(1,:),tmp(2,:),'.g');
                    drawLatticeFromCell(cMPT,'r',zeros(size(mIsGood)),mIsGood);hold on;
                    pause;
                end
            end
        end
    end
  
end
elpasedtime = toc;

fprintf('* Finished: Using %f secs and %d number of candidate lattices are found.\n\n', elpasedtime, size(ccMPT,2));

















