%test super resolution.......
%you need to specify the region of interest to get the super resolution....
%in this way user can identify the region that is really a lattice.
finalsavepath='./PGPath2';
imgpath='./GBData';



for i=12:12%71
    im=imread(sprintf('%s/gb%.3d.jpg',imgpath,i));
    
    load(sprintf('%s/PG_ccMPT_gb%.3d.mat',finalsavepath,i));
    %sort by Ascore..........and remove noisy lattices..........
    sortedid=SortByAScore(im,ccMPT,cmIsGood);
    
    %now make the input image and cMPT smaller...
    %imsmall=imresize(im,0.5);
    for k=2:length(sortedid)
        cMPT=ccMPT{sortedid(k)};
        mIsGood=cmIsGood{sortedid(k)};
        %propose a line cMPT{1,1} cMPT{1,2} cMPT{2,2}
        figure(1);clf;imshow(im);drawLatticeFromCell(cMPT,'r',-1,mIsGood);
        rect = round(getrect());
        if rect(3)<10 ||rect(4) <10
            continue;
        end
        
        [mh,mw]=size(mIsGood);
        
        imdbl=imresize(im,2);
        cNewMPT=cMPT;
        for mmm=1:mh*mw
            cNewMPT{mmm}=cMPT{mmm}*2; 
        end
        %To rectify image.....
        [A,cRegMPT,mReIsGood,mH]=ransac_rectify(cNewMPT,mIsGood,imdbl);
        
        [imh,imw,c]=size(A);
        
        
        palette=zeros(size(A));
        rx=[rect(1) rect(1)+rect(3)-1];
        ry=[rect(2) rect(2)+rect(4)-1];
    
        original=im(ry(1):ry(2)+1,rx(1):rx(2)+1,:);
        rx=rx*2;
        ry=ry*2;
        upsample=imdbl(ry(1):ry(2)+1,rx(1):rx(2)+1,:);
        
        
        [nrx,nry]=tformfwd(mH,rx,ry);
        
        wid=50;
        pos=1;
        flag1=0;
        %This is to get median texel....
        polyinfo=[nrx(1) nrx(2) nrx(2) nrx(1) nrx(1);nry(1) nry(1) nry(2) nry(2) nry(1)];
        for iy=1:mh-1
            for ix=1:mw-1
                flag=mIsGood(iy,ix)+mIsGood(iy,ix+1)+mIsGood(iy+1,ix+1)+mIsGood(iy+1,ix);
                XX=[cRegMPT{iy,ix} cRegMPT{iy,ix+1} cRegMPT{iy+1,ix+1} cRegMPT{iy+1,ix}];
                
                flagin=inpolygon(XX(1,:),XX(2,:),polyinfo(1,:),polyinfo(2,:));
                if  flag>=4 && sum(flagin)>=1
                    pt1=(cRegMPT{iy,ix});
                    pt2=(cRegMPT{iy,ix+1});
                    pt3=(cRegMPT{iy+1,ix+1});
                    pt4=(cRegMPT{iy+1,ix});
                    src=[pt1 pt2 pt3 pt4];
                    
                    
                    minx=min(round(src(1,:)));
                    maxx=max(round(src(1,:)));
                    miny=min(round(src(2,:)));
                    maxy=max(round(src(2,:)));
                    
                    dst=[minx maxx maxx minx;miny miny maxy maxy];
                    
                    if flag1==0
                        flag1=1;
                        nWidth=maxx-minx+1+2*wid;
                        nHeight=maxy-miny+1+2*wid;
                        P=zeros(nHeight,nWidth,3,1);
                        
                    end
                    if miny-wid>=1 && minx-wid>=1 &&  miny-wid+nHeight-1 <= imh && minx-wid+nWidth-1<=imw
                        P(:,:,:,pos)=A(miny-wid:miny-wid+nHeight-1,minx-wid:minx-wid+nWidth-1,:);
                        pos=pos+1;
                    end
                end
            end
        end


        
        mT2=median(P,4);
        
        %Debluerring process....
        PSF = fspecial('gaussian',[25 25],1.5);
        
        decon=deconvlucy(mT2,PSF);
    
        
        mask=zeros(nHeight,nWidth,3);
        
        for iy=1:mh-1
            for ix=1:mw-1
                if mIsGood(iy,ix)>0
                    pt1=(cRegMPT{iy,ix});
                    pt2=(cRegMPT{iy,ix+1});
                    pt3=(cRegMPT{iy+1,ix+1});
                    pt4=(cRegMPT{iy+1,ix});
                    
                    pt=round([pt1 pt2 pt3 pt4 pt1]);
                    minx=min(pt(1,:));
                    maxx=max(pt(1,:));
                    miny=min(pt(2,:));
                    maxy=max(pt(2,:));
                    
                    pt=pt-repmat([minx-wid+1;miny-wid+1],1,5);
                    BW = roipoly(mask,pt(1,:),pt(2,:));
                    
                    mask(:,:,1)=BW;
                    mask(:,:,2)=BW;
                    mask(:,:,3)=BW;
                    selected=decon.*double(mask);
                    imshow(uint8(selected));
                    [iiy,iix]=find(BW>0);
                    for mmm=1:length(iiy)
                        if miny+iiy(mmm)-wid-1>=1 && miny+iiy(mmm)-wid-1 <=imh &...
                                minx+iix(mmm)-wid-1>=1 && minx+iix(mmm)-wid-1<=imw
                            val=palette(miny+iiy(mmm)-wid-1,minx+iix(mmm)-wid-1,:);
                            if val>0
                                palette(miny+iiy(mmm)-wid-1,minx+iix(mmm)-wid-1,:)=(val+selected(iiy(mmm),iix(mmm),:))/2;
                            else
                                palette(miny+iiy(mmm)-wid-1,minx+iix(mmm)-wid-1,:)=selected(iiy(mmm),iix(mmm),:);
                            end
                        end
                    end
                    % imshow(uint8(palette));
                    a='sss';
                end
            end
        end
        
        
        
        %now transform back to original space.....!!!!
        fim=imtransform(palette,fliptform(mH),'XData',[1 size(imdbl,2)],'YData',[1 size(imdbl,1)]);
        fim=fim(ry(1):ry(2)+1,rx(1):rx(2)+1,:);
        figure(2);clf;subplot(121);imshow(uint8(upsample));subplot(122);imshow(uint8(fim));
        
        fim=double(fim);
        %just to show bicubic interpolation for comparison...
        upsample=double(upsample);
        figure(1);
        subplot(141);imshow(uint8(original));
        subplot(142);imshow(uint8(upsample));
        subplot(143);imshow(uint8(fim));
        
        
        %To transfer local information to super resolution.....
        B=post_SR(fim,upsample);
        
        
        subplot(144);imshow(uint8(B));
        a='ssss';
    end
end