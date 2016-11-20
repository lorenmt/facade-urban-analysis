function VisuFacade(im, facades)

if ~isempty(im)
    imshow(im);
end
hold on;
for i=1:length(facades)
    pts = facades(i).corners([1:end 1],:);
    plot(pts(:,1),pts(:,2),'r','linewidth',2);
end
hold off;
end