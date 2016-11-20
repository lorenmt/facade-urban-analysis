function facades = DetectionMain(city, imId)

flagSupervise = 1;
addpath('poly');
addpath('lsd');
para.nSample = 2000; % num of facade reinitialization
para.nTop = 500;  % not using this parameter
para.nRadius = 20; %  #floors
para.nHorOri = 2;  % try top 2 dominant horizontal orientations
para.res = 8;  % feature density -- should be consistent with the same para in C++ code
para.angTh = 10/180*pi; % tolerance of horizontal orientation noise
para.ang2Punish = .8; % ratio to punish the 2nd dominant horizotnal orientation over the 1st


[img, lMap, angHors, angVer, scale] = LoadFeat(city, imId, flagSupervise); %#ok<*ASGLU>
edge = load(PathManager(city,imId,'linSeg'));
edge = edge.lsg;

%[Y X] = size(lMap);
coverMap = zeros(size(lMap));
%[x0s y0s] = GenSample(lMap, para.nSample);%sample initialization from lMap
facadeAll = [];
scoreAll = [];

for i=1:para.nSample
%    x0 = x0s(i);
%    y0 = y0s(i);
    [x0, y0] = GenSampleSeq(lMap, coverMap);
    if x0<0
        fprintf('no more valid initialization at iter %d\n',i)
        break;
    end
    aV = angVer(y0,x0);
    s = scale(y0,x0)/para.res;
   
   % facades=[];
    for k=1:para.nHorOri   -1
        aH = angHors(y0,x0,k);
        [minAng, minId] = min( abs(angHors-aH), [], 3 );
        id2 = minId==2;
        map = lMap.*double(minAng<para.angTh);
        map(id2) = map(id2)*para.ang2Punish;
        if flagSupervise
            [facadeCand ] = GrowFacade(map,x0,y0,aV,aH,s, para);
        else
            [facadeCand ] = GrowFacadeUnsupervised(map,x0,y0,aV,aH,s, para);
        end
        facadeCand.angVer = aV;
        facadeCand.angHor = aH;
        facadeCand = computeFacadeAttributes(facadeCand);
       facadeAll = cat(1, facadeAll, facadeCand);
       scoreAll = cat(1, scoreAll, facadeCand.score);
       coverMap = updateCoverMap(coverMap, facadeCand);
% imshow(localMap,[]);
    end   
end    
for i = 1:length(facadeAll)
    s = scoreAll(i)*CheckEdgeConsistency(facadeAll(i), edge);
%      s=scoreAll(i);
    scoreAll(i) = s;
    facadeAll(i).score = s;
end
    
[nu, id] = sort(scoreAll,'descend');
id = id(1:min(para.nTop, length(id)));
try
    facades = RemOverlap(facadeAll);
catch
    fprintf('Removing Overlap Failed on image %d in city %s\n',imId,city)
    facades = facadeAll(id);
end

%visualization of detected facades
VisuResult(facadeAll,[],size(lMap),city,imId,1);
VisuResult(facades,[],size(lMap),city,imId,2);
VisuResult(facades,lMap,[],city,imId,3);
end




function [xs, ys] = GenSample(lMap, n)
[Y, X] = size(lMap);
count=0;
pts=zeros(n,2);
thMin = 0.3;
while count<n
    x = ceil(rand*X);
    y = ceil(rand*Y);
    if lMap(y,x)<thMin % rand
        continue;
    end
    count = count+1;
    pts(count,:) = [x y];
end
xs = pts(:,1);
ys = pts(:,2);
end

function [x0, y0] = GenSampleSeq(lMap, coverMap)
nMaxCover = 5;
thMin = 0.3;
id = find(coverMap(:)<nMaxCover & lMap(:)>thMin);

if isempty(id)
    x0=-1;y0=-1;return;
end
i = randsample(id,1);
[y0, x0] = ind2sub(size(lMap),i);
end


function facade = computeFacadeAttributes(facade)

cors = facade.corners;
center = mean(cors,1);
radius = max(dist(cors, center'));

facade.center = mean(facade.corners,1);
facade.radius = radius;
facade.area = polyarea(cors([1:end 1],1),cors([1:end 1],2));

end


function facades = RemOverlap(facades)
n = length(facades);
costMat=zeros(n);
for i=1:n
    costMat(i,i) = facades(i).score;
    areaI = facades(i).area;
    for j=i+1:n
        d = dist(facades(i).center, facades(j).center');
        if d > facades(i).radius + facades(j).radius
            continue;
        end
        if d < max(facades(i).radius, facades(j).radius)/2
            costMat(i,j) = -inf;
            costMat(j,i) = -inf;
            continue;
        end
        areaOL = CalcuIntersectionArea(facades(i).corners, facades(j).corners);
        
        areaJ = facades(j).area;
        olRatio = areaOL/min(areaI,areaJ);
        if olRatio < 0.3
            continue;
        end
        if olRatio > 0.7
            costMat(i,j) = -inf;
        else
            costMat(i,j) = -areaOL/areaI*facades(i).score-areaOL/areaJ*facades(j).score;
        end
        costMat(j,i) = costMat(i,j);
    end
end

[id, score] = IQPdaq(costMat);
facades = facades(id);
n = length(facades);
areas = zeros(n,1);
for i=1:n
    areas(i) = facades(i).area;
end
[sArea, id] = sort(areas, 'descend');
minArea = 30;
topK = 300;
iStop = find(sArea>minArea,1,'last');
if isempty(iStop)
    iStop = n;
end
iStop = min(topK, iStop);
facades = facades(id(1:iStop));
end

function coverMap = updateCoverMap(coverMap, facade)

[Y, X] = size(coverMap);
[xs, ys] = meshgrid(1:X,1:Y);
xp = facade.corners([1:end 1],1);
yp = facade.corners([1:end 1],2);
map = inpolygon(xs,ys,xp,yp);
coverMap = coverMap+map;
end



function [id, score] = IQPdaq(costMat)
n = size(costMat,1);
idGroup = 1:n;
id = costMat == -inf;
costMat(id) = - max(costMat(:))*2;
for i1=1:n
    for i2=i1+1:n
        if idGroup(i1)==idGroup(i2)||costMat(i1,i2)==0
            continue;
        end
        idGroup(idGroup==idGroup(i2))=idGroup(i1);
    end
end
idu = unique(idGroup);
id = zeros(n,1);
score=0;
for i=1:length(idu)
    iset = find(idGroup == idu(i));
    [id(iset), s] = IQP(costMat(iset,iset));
    score = score+s;
end
id = logical(id);
end