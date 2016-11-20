
function [r,c, response] = nonmaxsup_res(cim, radius, thresh)

subPixel = nargout == 4;            % We want sub-pixel locations
[rows,cols] = size(cim);

% Extract local maxima by performing a grey scale morphological
% dilation and then finding points in the corner strength image that
% match the dilated image and are also greater than the threshold.

sze = 2*radius+1;                   % Size of dilation mask.
mx = ordfilt2(cim,sze^2,ones(sze)); % Grey-scale dilate.

% Make mask to exclude points within radius of the image boundary.
bordermask = zeros(size(cim));
bordermask(radius+1:end-radius, radius+1:end-radius) = 1;

% Find maxima, threshold, and apply bordermask
cimmx = (cim==mx) & (cim>thresh) & bordermask;

[r,c] = find(cimmx);                % Find row,col coords.


response=cim;
response(find(cim~=mx | bordermask==0 | cim<=thresh))=0;