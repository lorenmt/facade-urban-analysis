function cRetMember=MSClustering(data,bandwidth,data_rep)

[mu,c,band]=OSX_CPPMeanShiftCluster(data,bandwidth);
nC=max(c);
cMember=cell(1,nC);
for k=1:nC
    cMember{k}=[];
end

for k=1:length(c)
    cMember{c(k)}=[cMember{c(k)} data_rep(:,k)];   
end

cRetMember={};
pos=1;
for k=1:nC
    if ~isempty(cMember{k})
       cRetMember{pos}=cMember{k} ;
       pos=pos+1;
    end
end