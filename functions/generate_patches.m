function generate_patches(city,imId,facades)
%%  Generate all patches for the facades detected

[img, lMap, angHors, angVer, scale] = LoadFeat(city, imId, 1); %#ok<*ASGLU>
%%


scaling = size(img(:,:,1)) ./ size(lMap);
mkdir(sprintf('facades/%s/%s_%03d/',city,city,imId))
%%
for i=1:length(facades)
    coords = facades(i).corners .* repmat(scaling,[4,1]);
    % figure(1)
    patch = getFv(img,coords',0,0);
    imwrite(patch,sprintf('facades/%s/%s_%03d/%d.jpg',city,city,imId,i));
    % figure(2)
    % imshow(patch)
end
