function area = CalcuIntersectionArea(poly1, poly2)

area=0;
% cd 'poly'
[ox oy] = polybool2(poly1(:,1),poly1(:,2),poly2(:,1),poly2(:,2),1);
% cd '..';
if isempty(ox)
    return;
end
area = polyarea(ox,oy);

end