function [map]=MexTmpColMatching(im,tmp)

R=MexTmpMatching(im(:,:,1),tmp(:,:,1));
G=MexTmpMatching(im(:,:,2),tmp(:,:,2));
B=MexTmpMatching(im(:,:,3),tmp(:,:,3));

map=(R+G+B)/3;