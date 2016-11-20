function fvPatch = getFv(img, fs, rFlag, plotFlag)
xs=fs(1,:);
ys=fs(2,:);
cors=[xs(:) ys(:)];
%make sure corner order:
%tl -> tr -> br ->bl
lx = round(norm(cors(2,:)-cors(1,:)));
ly = round(norm(cors(4,:)-cors(1,:)));

if nargin>=4 && plotFlag
    imshow(img);hold on;
    plot(xs,ys,'r','linewidth',3);
end
input_points=[1 1; lx 1; lx ly; 1 ly];
TFORM = cp2tform(cors,input_points, 'affine');

fvPatch = imtransform(img, TFORM, 'XData',[1 lx], 'YData',[1 ly]);

if nargin>=3&&rFlag
    fvPatch=fvPatch(end:-1:1,end:-1:1,:);
end