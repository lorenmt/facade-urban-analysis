function [id score] = IQP(costMat)
% if size(costMat,1)==6 &&costMat(1)>6&&costMat(1)<6.1
%     figure;
% end

nInit = min(100, size(costMat,1)*5);
topK = min(nInit,100);
[ids scores] = IQP_grasp(costMat, nInit, topK);
id = ids{1};
score = scores(1);
end


function [ids scores] = IQP_grasp(costMat, nInit, topK)

ids = cell(nInit,1);
scores = zeros(nInit,1);
for i = 1:nInit
    [ids{i} scores(i)] = greedyRandOpt(costMat);
end

[nu rankId] = sort(scores,'descend');
rankId = rankId(1:topK);
ids = ids(rankId);
scores = scores(rankId);
end


function [id score] = greedyRandOpt(costMat)
eps = 0.0001;
n = size(costMat,1);

flag= ones(1,3);%add, rem, replace
id = false(1,n);
score = 0;
while any(flag)
    movs = find(flag);
    m = randsample(movs,1);
    switch m
        case 1
            [idNew scoreNew]=add(id, costMat, score);
        case 2
            [idNew scoreNew]=add(id, costMat, score);%no rem
        case 3
            [idNew scoreNew]=rep(id, costMat, score);
    end
    if scoreNew>score+eps
        flag = ones(1,3);
        id = idNew;
        score = scoreNew;        
    else
        flag(m)=0;        
    end
end

end

function [id score] = add(id, costMat, score)
topK=10;
s = sum(costMat(id,:),1)*2 + diag(costMat)';
s(id)=0;
[nu sid] = sort(s,'descend');
j = find(nu>0,1,'last');
if isempty(j)
    return;
end
sid=sid(1:min(j,topK));
i = randsample(sid, 1);
score = score + s(i);
id(i)=true;
end

function [id score]=rem(id, costMat, score)
topK=3;
s = sum(costMat(id,id),1)*2 - diag(costMat(id,id))';
[nu sid] = sort(s);
j = find(nu<0, 1, 'last');
if isempty(j)
    return;
end
sid = sid(1:min(j,topK));
i = randsample(sid, 1);
score = score - s(i);

ind = find(id);
id(ind(i))=false;

end

function [id score] = rep(id,costMat, score)
topK=5;
N = size(costMat,1);
scoreMat = zeros(N);
for n1=1:N
    if ~id(n1)
        continue;
    end
    for n2=1:N
        if id(n2)||costMat(n1,n2)>=0
            continue;
        end
        scoreMat(n1,n2) = costMat(n2,n2)+sum(costMat(id,n2))*2-2*costMat(n1,n2)...
            -2*sum(costMat(id,n1))+costMat(n1,n1);
    end
end
s = scoreMat(:);
[nu sid] = sort(s,'descend');
j = find(nu>0,1,'last');
if isempty(j)
    return;
end
sid = sid(1:min(topK,j));
i = randsample(sid,1);
[n1 n2] = ind2sub([N N],i);
score = score+s(i);
id(n1) = false;
id(n2) = true;
end