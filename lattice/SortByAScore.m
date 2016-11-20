function [sortedid, TexelStd, Ascore] = SortByAScore(im,ccMPT,cmIsGood)

%For every lattice structur cMPT we need to collect RGB histogram of image
%inside the proposals.

nCnt = size(ccMPT,2);

AAA = zeros(nCnt, 3);
for i = 1:nCnt    
    [nA, TexelStd, Ascore] = ComputeAGscore_via_ransac_rectify2(ccMPT{i},cmIsGood{i},im); 
    
    if nA == 0
       nA = inf; 
    end
    AAA(i,1) = nA;
    AAA(i,2) = TexelStd;
    AAA(i,3) = Ascore;
end

[v, sortedid] = sort(AAA(:,1));
sortedid = sortedid(v~=inf);
TexelStd = max(AAA(:,2));
Ascore = max(AAA(:,3));
    
