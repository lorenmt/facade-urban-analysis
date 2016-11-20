%  Batch detection main for lots of images at once
city = 'nyc';
imIds = [0,1,2,6,41,64,75,76,79,83,84,85,101,104,106,109,115,164,172,320,322,372,467,621,672];


parfor imId_idx = 1:length(imIds)
    imId = imIds(imId_idx);
    fprintf('Detecting Facades on image %03d in city %s\n\n', imId, city);
    if ~exist(PathManager(city,imId,'linSeg'),'file')
        fprintf('Detecting Edges on image %03d in city %s\n\n', imId, city);
        EdgeBatch(city,imId);
    end
    facades = DetectionMain(city,imId);
    generate_patches(city,imId,facades);
    parsave(sprintf('%s/facades_%s_%08d.mat',city,city,imId),facades);
end



city = 'sf';
imIds = [79,111,112,239,240,277,279,281,314,317,325,333,337,407,424];


parfor imId_idx = 1:length(imIds)
    imId = imIds(imId_idx);
    fprintf('Detecting Facades on image %03d in city %s\n\n', imId, city);
    if ~exist(PathManager(city,imId,'linSeg'),'file')
        fprintf('Detecting Edges on image %03d in city %s\n\n', imId, city);
        EdgeBatch(city,imId);
    end
    facades = DetectionMain(city,imId);
    generate_patches(city,imId,facades);
    parsave(sprintf('%s/facades_%s_%08d.mat',city,city,imId),facades);
end


city = 'rome';
imIds = [444,448,449,450,451,454,455,462,464,465,467,468,475,476];


parfor imId_idx = 1:length(imIds)
    imId = imIds(imId_idx);
    fprintf('Detecting Facades on image %03d in city %s\n\n', imId, city);
    if ~exist(PathManager(city,imId,'linSeg'),'file')
        fprintf('Detecting Edges on image %03d in city %s\n\n', imId, city);
        EdgeBatch(city,imId);
    end
    facades = DetectionMain(city,imId);
    generate_patches(city,imId,facades);
    parsave(sprintf('%s/facades_%s_%08d.mat',city,city,imId),facades);
end