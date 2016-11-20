function s = PathManager(city, imId, type, id)

s=[];
imPath = '..\..\..\data\';
featPath = '..\interData\Feat\';
gtPath = '..\interData\GT\';
visuPath = '..\interData\Visu\';

city = strcat(city, '\');
%type = lower(type);
if strcmp(type, 'img')
    s = sprintf('%s%simage%07d.png', imPath,city,imId);
elseif strcmp(type, 'lMap')
    s = sprintf('%s%spredict%07d.txt', featPath,city,imId);
elseif strcmp(type, 'angVer')
    s = sprintf('%s%sfeatAngVer%07d.txt', featPath,city,imId);
elseif strcmp(type, 'angHor')
    s = sprintf('%s%sfeatAngHor%07d_%d.txt', featPath,city,imId,id);
elseif strcmp(type, 'scale')
    s = sprintf('%s%sfeatLocalScale%07d.txt', featPath,city,imId); 

elseif strcmp(type, 'projVer')
    s = sprintf('%s%sfeatVerProj%07d.txt', featPath,city,imId);    
elseif strcmp(type, 'projHor')
    s = sprintf('%s%sfeatHorProj%07d.txt', featPath,city,imId); 
elseif strcmp(type, 'distVer')
    s = sprintf('%s%sfeatVerDist%07d.txt', featPath,city,imId); 
elseif strcmp(type, 'density')
    s = sprintf('%s%sfeatDensity%07d.txt', featPath,city,imId); 
    
elseif strcmp(type, 'linSeg')
    s = sprintf('%s%sfeatEdgelet%07d.mat', featPath,city,imId); 
elseif strcmp(type, 'trainData')
    s = sprintf('%s%strain%07d.txt', featPath,city,imId);
elseif strcmp(type, 'gt')
    s = sprintf('%s%sgt%07d.mat',gtPath,city,imId);
elseif strcmp(type, 'rIm')
    s = sprintf('%s%sr%07d_%d.png',visuPath,city,imId,id);
end


end
    