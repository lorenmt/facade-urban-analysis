function vim = VisuResult(facades, img, sz, city, imId, id)

if isempty(img)
    img = imread(PathManager(city,imId,'img'));
    img = imresize(img, sz);
end
if size(img,3)==3
    img = rgb2gray(img);
end

VisuFacade(img, facades);
saveas(gcf,'tmp.png');
vim = remBorder(imread('tmp.png'));
vim = vim(end:-1:1,end:-1:1,:);
%imshow(vim);

if nargin==6 && id>0
    imwrite(vim, PathManager(city,imId,'rIm',id));
end