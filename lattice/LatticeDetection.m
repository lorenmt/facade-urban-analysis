function [Ascore, Tile, occupancy] = LatticeDetection(impath, imname)

FromTheStart = 1;

% Get Lattice Proposal
im = imread(impath);
if (size(im,3) == 1)
    im = repmat(im,[1 1 3]);
    imwrite(im, impath);
end

if FromTheStart == 1
    fprintf('* Starting: Find Lattice Proposal on id:%03d.\n', imname);
    [ccMPT,cmIsGood] = GetProposals(imname,impath);
    clear GetProposals;
end

if isempty(ccMPT) == 1
    Tile = 0;
    Ascore = 1;
    occupancy = 0;
    return;
end

% Use Ascore and Tile
tic;
if 1        
    [sortedid, ~, ~] = SortByAScore(im,ccMPT,cmIsGood);
    clear SortByAScore;
    Collected_ccMPT={};
    Collected_mIsGood={};
    nCollected = 0;

    pos = 1; 
    while ~isempty(sortedid) && pos <= length(sortedid)
        cMPT = ccMPT{sortedid(pos)};
        mIsGood=cmIsGood{sortedid(pos)};
        [cReMPT,mReIsGood] = LatticeComplete(double(im),cMPT,mIsGood,0);

        pos = pos + 1;
        if ~isempty(mReIsGood)
            nCollected=nCollected+1;
            Collected_ccMPT{nCollected}=cReMPT;
            Collected_mIsGood{nCollected}=mReIsGood;

            id_rest=[];
            for m = pos:length(sortedid)
                cMPT = ccMPT{sortedid(m)};
                mIsGood = cmIsGood{sortedid(m)};
                occupancy = DoesACoverB(Collected_ccMPT{nCollected},cMPT,Collected_mIsGood{nCollected},mIsGood);
                clear DoesACoverB;
                if occupancy < 0.7
                    %This should be saved and must be processed.....
                    id_rest = [id_rest sortedid(m)];
                end
            end
            pos = 1;
            sortedid = id_rest;
        end
    end
    
    ccMPT = Collected_ccMPT;
    cmIsGood = Collected_mIsGood;
    
    if isempty(ccMPT) == 1
        Tile = 0;
        Ascore = 1;
        occupancy = 0;
        return;
    else
        for i = 1: length(ccMPT)
            Ntiles(i) = length(find(cmIsGood{1,i}) == 1);           
        end
        [Tile, Index] = max(Ntiles);
    
    end
    
    im = imread(impath); im = rgb2gray(im);
    Index2 = find(cmIsGood{1,Index} == 1);
    [I,J] = ind2sub(size(cmIsGood{1,Index}), Index2);
    A = abs(ccMPT{1,Index}{1,1}(1) - ccMPT{1,Index}{1,2}(1));
    B = abs(ccMPT{1,Index}{1,1}(2) - ccMPT{1,Index}{1,2}(2));
    
    for j = 0: floor(A)
        for k = 0: floor(B)
            for i = 1: length(Index2)
                if floor(ccMPT{1, Index}{I(i),J(i)}(1)+k) >= size(im, 2) || floor(ccMPT{1, Index}{I(i),J(i)}(2)+j) >= size(im, 1) || ...
                        floor(ccMPT{1, Index}{I(i),J(i)}(1)+k) <= 0 || floor(ccMPT{1, Index}{I(i),J(i)}(2)+j) <= 0
                    continue;
                end
                STD(j+k+1,i) = im(floor(ccMPT{1, Index}{I(i),J(i)}(2)+j), floor(ccMPT{1, Index}{I(i),J(i)}(1)+k));
            end
        end
    end
        
    for i = 1:size(STD, 1);
        TempSTD = STD(i,:);
        Bad = TempSTD == 0;
        TempSTD(Bad) = [];        
        Astd(i) = std(double(TempSTD));
    end          
    
    LatticePixel = abs(ccMPT{1,Index}{1,1}(1)-ccMPT{1,Index}{end,end}(1)) * abs(ccMPT{1,Index}{1,1}(2)-ccMPT{1,Index}{end,end}(2));
    Ascore = sum(Astd)/LatticePixel;    
    
    ImArea = size(imread(impath),1) * size(imread(impath),2) ;
    occupancy = LatticePixel/ImArea;    
    
    t = toc;
    fprintf('* Computational Time: %f second.\n', t); 

end    




