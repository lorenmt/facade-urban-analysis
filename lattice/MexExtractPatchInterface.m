function [nPT,vec]=MexExtractPatchInterface(im,nHalfSize,pts)

[vec,idx,N]=MeXExtractPatch(double(im),5,pts(1:2,:));
clear MeXExtractPatch;
idx=idx(1:N);
nPT=pts(:,idx);
vec=vec(:,1:N);
