% FromTheStart=1;
% addpath(genpath('vlfeat'))
% savepath='./proposals';
% finalsavepath='./mexFinalSSap';
% mkdir(finalsavepath);
% mkdir(savepath);
% 
% imfold='GBData\apss\';
% imnames=dir(imfold);
% imnames(1:2)=[];
for i=60:length(imnames)
    if i<-1,continue;end;
    if ~strcmp(imnames(i).name(end-2:end),'jpg')
        continue;
    end
    impath=sprintf('%s%s',imfold,imnames(i).name);
    imname=imnames(i).name(1:end-4);
    
    display=1;
    if FromTheStart==1
        [ccMPT,cmIsGood]=GetProposals(imname,impath,savepath,display);
        clear GetProposals;
    else
        loadpath='./proposals';
        load(sprintf('%s/ccMPT_%s.mat',loadpath,imname));
    end
    %sort by A score...and filter out using occupancy and t1 t2 vector
    %info........
    a='aaa';
    if 1
        tic;
        im=imread(impath);
        
        sortedid=SortByAScore(im,ccMPT,cmIsGood);
        
        clear SortByAScore;
        
        Collected_ccMPT={};
        Collected_mIsGood={};
        nCollected=0;
     
        
        pos=1;
        while ~isempty(sortedid) && pos<=length(sortedid)
            length(sortedid)
            cMPT=ccMPT{sortedid(pos)};
            mIsGood=cmIsGood{sortedid(pos)};
            [cReMPT,mReIsGood]=LatticeComplete(double(im),cMPT,mIsGood,0);
            
            pos=pos+1;
            if ~isempty(mReIsGood)
                nCollected=nCollected+1;
                Collected_ccMPT{nCollected}=cReMPT;
                Collected_mIsGood{nCollected}=mReIsGood;
                a='aaa';
                %Now For this one we need to check the rest if they are
                %part of the found.....
                id_rest=[];
                for m=pos:length(sortedid)
                    cMPT=ccMPT{sortedid(m)};
                    mIsGood=cmIsGood{sortedid(m)};
                    occupancy=DoesACoverB(Collected_ccMPT{nCollected},cMPT,Collected_mIsGood{nCollected},mIsGood);
                    clear DoesACoverB;
                    if occupancy <0.7
                        %This should be saved and must be processed.....
                        id_rest=[id_rest sortedid(m)];
                    end
                end
                pos=1;
                sortedid=id_rest;
            end
        end
        t=toc
        figure(1);clf;imshow(im);
        col=colormap(hsv(length(Collected_ccMPT)));
        for k=1:length(Collected_ccMPT)
            cMPT=Collected_ccMPT{k};
            mIsGood=Collected_mIsGood{k};
            hold on;
            drawLatticeFromCell(cMPT,col(k,:),zeros(size(mIsGood)),mIsGood);
        end
        
        print('-f1',sprintf('%s/Re_%s.png',finalsavepath,imname),'-dpng');
        ccMPT=Collected_ccMPT;
        cmIsGood=Collected_mIsGood;
        
        save(sprintf('%s/lattices_ccMPT_%s.mat',finalsavepath,imname),'ccMPT','cmIsGood','t');
    end
end
