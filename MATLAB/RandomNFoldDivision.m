function q=RandomNFoldDivision(N,FoldN)
q=zeros(FoldN,N)==1;
Taken=ones(1,N);
n=N; m=ceil(N/FoldN);
for i=1:FoldN-1
    j=1;
    while j<m
        k=randi(N);
        if Taken(k)==1
            Taken(k)=0;
            q(i,k)=true;
            j=j+1;
        end
    end
    n=n-m;
end
q(FoldN,:)=Taken==1;