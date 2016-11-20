function Eva(facades, city, imId, imSz)


gt = load(PathManager(city, imId, 'gt'));
gt = gt.recs;

if isempty(facades) || isempty(gt)
    return;
end
[facMap angMap scoreMap bondMap] = facade2map(facades, imSz);
[facGt angGt scoreGt bondGt] = facade2map(gt, imSz);

yGt = scoreGt(:);
yPredict = scoreMap(:);
[pre rec] = genPR(yPredict, yGt);

figure1 = figure('Color',[1 1 1]);
axes('Parent',figure1,'YTickLabel',{'0','0.2','0.4','0.6','0.8','1'},...
    'YTick',[0 0.2 0.4 0.6 0.8 1],...
    'XTickLabel',{'0','0.2','0.4','0.6','0.8','1'},...
    'XTick',[0 0.2 0.4 0.6 0.8 1]);
xlim([0 1]);ylim([0 1]);
box('on');
grid('on');
hold('all');
plot(rec,pre,'LineWidth',2,'Color',[0 0 0]);
xlabel('Recall');
ylabel('Precision');
end





function [facMap angMap scoreMap bondMap] = facade2map(facades, imSz)
thAngHor = 15/180*pi;
thBondRatio = .1;
res = 8;

scoreMap = -ones(imSz(1)/res, imSz(2)/res);
angMap = zeros(imSz(1)/res, imSz(2)/res);;
facMap = logical(angMap);
bondMap = facMap;

[xs ys] = meshgrid(1:size(facMap,2), 1:size(facMap,1));

for i = 1:size(facades,1)
    if isstruct(facades(i))
        xIn = facades(i).corners(:,1);
        yIn = facades(i).corners(:,2);
        angHor = facades(i).angHor;
        score = facades(i).score;
       
    else
        x = (imSz(2)+1 - facades(i,1:4))/res;
        y = (imSz(1)+1 - facades(i,5:8))/res;
        dy = y(2)-y(1)+y(3)-y(4);
        dx = x(2)-x(1)+x(3)-x(4);
        angHor = atan(dy/dx);
        score = 1;
        
        cx = mean(x);
        cy = mean(y);
        xIn = (x - cx)*(1-thBondRatio) +cx;
        yIn = (y - cy)*(1-thBondRatio) +cy;
        xOut= (x - cx)*(1+thBondRatio) +cx;
        yOut= (y - cy)*(1+thBondRatio) +cy;        
    end
    inMap = inpolygon(xs,ys,xIn([1:end 1]), yIn([1:end 1]));
    if ~isstruct(facades(i))
        outMap = inpolygon(xs,ys,xOut([1:end 1]), yOut([1:end 1]));
        bondMap = bondMap | (xor(inMap, outMap));        
    end
    facMap = facMap | inMap;
    scoreMap(inMap) = max(scoreMap(inMap),score);
    angMap(inMap) = angHor; 
end
bondMap = bondMap & (~facMap);
scoreMap(bondMap(:))=0;
end

function [pre rec] = genPR(yPredict, yGt)
[sPredict id]  = sort(yPredict);
sGt = yGt(id);
total = sum(sGt>=0);
n = length(yGt);
res = ceil(n/1000);
k = floor(n/res);
pre = zeros(k,1);
rec = zeros(k,1);

for i = res:res:n
    rec(i/res) = 1- sum(sGt(1:i)==1)/total;
    pre(i/res) = 1-sum(sGt(i+1:n)==-1)/(n-i);
end
end