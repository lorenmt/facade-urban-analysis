function [img, lMap, angHors, angVer, scale, label, feat] = LoadFeat(city, imId, flagSupervise)

img = imread(PathManager(city,imId,'img') );

if nargout==1
    return;
end
data = importdata(PathManager(city,imId,'angVer'),'\t',1);
angVer = data.data;

[Y, X] = size(angVer);

nHor = 2;
angHors = zeros(Y,X,nHor);
for i = 1:nHor
    data = importdata(PathManager(city,imId,'angHor',i-1),'\t',1);
    angHors(:,:,i) = data.data;
end

data = importdata(PathManager(city,imId,'scale'),'\t',1);
scale = data.data;

data = importdata(PathManager(city,imId,'lMap'),'\t',1);
lMap = reshape(data.data, [X Y])';

if ~flagSupervise
    data = importdata(PathManager(city,imId,'projVer'),'\t',1);
    lMap = lMap.*data.data;
    data = importdata(PathManager(city,imId,'projHor'),'\t',1);
    lMap = lMap.*data.data;
    data = importdata(PathManager(city,imId,'distVer'),'\t',1);
    lMap = lMap.*data.data;
    data = importdata(PathManager(city,imId,'density'),'\t',1);
    lMap = lMap.*data.data;
    lMap = lMap.^0.25;
    lMap = lMap/(max(lMap(:)));
end



if nargout>5
    data = importdata(PathManager(city,imId,'trainData'),'\t',1);
    feat = data.data;
    label = feat(:,1);
    label = reshape(label, [X Y])';
end