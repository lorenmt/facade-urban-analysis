function [facade localMap]= GrowFacadeUnsupervised(map, x0,y0,aV,aH,s, para)
%different parameter setting with supervised likelihood map
tvx = cos(aV);
tvy = sin(aV);
thx = cos(aH);
thy = sin(aH);
T = [thx thy; tvx tvy];
n = ceil(para.nRadius*s);
os = ones(4,1)*[x0 y0];


[xi, yi]= meshgrid( -n:n, -n:n);
xo = xi*thx +yi*tvx +x0;
yo = xi*thy +yi*tvy +y0;

localMap = interp2(map, xo, yo, 'nearest');
id = isnan(localMap);
localMap(id)=0;

aMap = getAccuMap(localMap);

[xs ys facade.score] = localGrowRand(aMap, [n+1 n+1]);%, localMap); -- for debug
xMin = xs(1)-n-1; xMax = xs(2)-n-1;
yMin = ys(1)-n-1; yMax = ys(2)-n-1;
facade.corners = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]*T + os;

end


function map =getAccuMap(map)

[Y X] = size(map);
for y=2:Y
    map(y,:) = map(y,:)+map(y-1,:);
end
for x=2:X
    map(:,x) = map(:,x)+map(:,x-1);
end
map = blkdiag(0,map);
end

function [score] = searchBF(aMap, pt0, minArea, xRange, yRange)

if nargin<3
    minArea = 30;
end

[Y X] = size(aMap);
Y= Y-1;
X= X-1;
score = zeros(Y,X);
if nargin<5
    xRange = 1:X;
    yRange = 1:Y;
end
x0=pt0(1);
y0=pt0(2);

area = abs((1:Y)-y0)'*abs((1:X)-x0);
id = area < minArea;
area(id) = inf;
areaNorm = sqrt(area);

for x=xRange
    for y=yRange
        xb=max(x,x0);
        xs=min(x,x0);
        yb=max(y,y0);
        ys=min(y,y0);
        score(y,x)=aMap(ys,xs)+aMap(yb+1,xb+1)-aMap(ys,xb+1)-aMap(yb+1,xs);
    end
end
score = score./areaNorm;
score(y0,x0)=0;
end


function [pOut score] = grow(map, d, pIn)
if nargin==3
    x = pIn(1);
    y = pIn(2);
    switch d(1)
        case 't'
            map(y:end,:)=0;
        case 'b'
            map(1:y,:)=0;
    end
    switch d(2)
        case 'l'
            map(:,x:end)=0;
        case 'r'
            map(1:x,:)=0;
    end
end
score = max(map(:));
[yo xo] = find(map==score,1,'first');
pOut = [xo yo];
end

function [xs ys scoreBest] = localGrowRand(aMap, p0, lMap)
[Y X] = size(aMap);
Y=Y-1;
X=X-1;
if nargin<2
    p0 = ceil([Y X]/2);
end
xMin = p0(1);
xMax = p0(1);
yMin = p0(2);
yMax = p0(2);

radiusAbs = 5;
radiusRel = 0.1;
minArea = 10;
flag=ones(1,4); %[tl, tr, bl, br];
scoreBest = 0;
while any(flag)
    rX = round(max(radiusAbs, (xMax-xMin)*radiusRel));
    rY = round(max(radiusAbs, (yMax-yMin)*radiusRel));
    
    id = randperm(4);
    i = find(flag(id),1,'first');
    i = id(i);
    switch i
        case 1 %top left
            xRange = max(1, xMin-rX):min(xMax, xMin+rX);
            yRange = max(1, yMin-rY):min(yMax, yMin+rY);
            scoreMap = searchBF(aMap,[xMax yMax],minArea, xRange, yRange);
            [pNew score] = grow(scoreMap);
            if score>scoreBest
                flag=ones(1,4);
                xMin = pNew(1); yMin = pNew(2);
                scoreBest = score;
            else
                flag(1)=0;
            end
        case 2 %top right
            xRange = max(xMin, xMax-rX):min(X, xMax+rX);
            yRange = max(1, yMin-rY):min(yMax, yMin+rY);
            scoreMap = searchBF(aMap,[xMin yMax],minArea, xRange, yRange);
            [pNew score] = grow(scoreMap);
            if score>scoreBest
                flag=ones(1,4);
                xMax = pNew(1); yMin = pNew(2);
                scoreBest = score;
            else
                flag(2)=0;
            end
        case 3 %bottom left
            xRange = max(1, xMin-rX):min(xMax, xMin+rX);
            yRange = max(yMin, yMax-rY):min(Y, yMax+rY);
            scoreMap = searchBF(aMap,[xMax yMin],minArea, xRange, yRange);
            [pNew score] = grow(scoreMap);
            if score>scoreBest
                flag=ones(1,4);
                xMin = pNew(1); yMax = pNew(2);
                scoreBest = score;
            else
                flag(3)=0;
            end
        otherwise %bottom right
            xRange = max(xMin, xMax-rX):min(X, xMax+rX);
            yRange = max(yMin, yMax-rY):min(Y, yMax+rY);
            scoreMap = searchBF(aMap,[xMin yMin],minArea, xRange, yRange);
            [pNew score] = grow(scoreMap);
            if score>scoreBest
                flag=ones(1,4);
                xMax = pNew(1); yMax = pNew(2);
                scoreBest = score;
            else
                flag(4)=0;
            end
    end
end
xs = [xMin xMax];
ys = [yMin yMax];
end