function r = CheckEdgeConsistency(facade, edges)

ath = 15/180*pi;
bondR = 1.1;
region = (facade.corners - repmat(facade.center,4,1))*bondR + repmat(facade.center,4,1);

inFlag = inpolygon( (edges(:,1)+edges(:,3))/2, (edges(:,2)+edges(:,4))/2, region([1:end 1],1), region([1:end 1],2) );

daH = mod(-edges(:,6) - facade.angHor, pi);
daH = min(daH, pi-daH);

daV = mod(-edges(:,6) - facade.angVer, pi);
daV = min(daV, pi-daV);

idP = find(inFlag & (daH<ath) );
idN = find(inFlag & (daH>=ath) & (daV>=ath) );

if isempty(idN) && isempty(idP) 
    r = 0.5;
elseif isempty(idP)
    r = 0;
elseif isempty(idN)
    r = 1;
else
    r = sum(edges(idP,5))/(sum(edges(idP,5))+sum(edges(idN,5)));
end

weight = 0.6;
r = r*weight + (1-weight);

