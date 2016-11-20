function batchMerge(fd)
fn=dir(fd);

cd(fd);

fn(1:2)=[];
N=length(fn);
fns=cell(N,1);

for n=1:N
    fns{n}=fn(n).name(1:end-14);
end
z=eye(N);
for n=1:N
    for n2=n+1:N
        if strcmp(fns{n},fns{n2})
            z(n,n2)=1;
            z(n2,n)=1;
        end
    end
end
flag=zeros(N,1);
for n=1:N
    if flag(n)
        continue;
    end
    id=find(z(n,:)==1);
    flag(id)=1;
    mLat(fn(id));
end
end



function [lats flags]=mLat(fns)

lats=[];
flags=[];
N=length(fns);
for n=1:N
    fn=fns(n).name;
    data=load(fn);
    dx=str2double(fn(end-12:end-9));
    dy=str2double(fn(end-7:end-4));
    lat=data.lats;
    flag=data.flags;
    M=length(lat);
    for m=1:M
        [ Y X]=size(lat{m});
        for y=1:Y
            for x=1:X
                lat{m}{y,x}=lat{m}{y,x}+[dx;dy];
            end
        end
    end
    lats=cat(2,lats,lat);
    flags=cat(2,flags,flag);
    fn(end-13:end-4)=[];
    fn(5:8)=[];
    
end
save(fn,'lats','flags');
end
    
    