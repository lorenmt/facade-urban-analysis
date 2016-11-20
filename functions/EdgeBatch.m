function EdgeBatch(city, imId)

addpath('lsd');
%city = 'nyc';
%imId = 0;

[img ] = LoadFeat(city, imId);
gim = rgb2gray(img);
edgeim = edge(gim,'canny', [0.1 0.2]);
[edgelist, ~] = edgelink(edgeim, 10);
seglist = lineseg(edgelist, 2);
lsg = GetAllLineSeg(seglist,10);

save(PathManager(city,imId,'linSeg'), 'lsg', 'seglist');