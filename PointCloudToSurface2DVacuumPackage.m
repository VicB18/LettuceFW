function [PacX,PacY,Draw]=PointCloudToSurface2DVacuumPackage(x,y,CX,CY,PacN)
Dmin=1*(max(x)-min(x))/PacN;
PackageAdvanceDist=Dmin/2;
MaxGap=5*(max(x)-min(x))/PacN;
FilterN=3;
ddmin=zeros(FilterN,1);
Draw=0;

t=boundary(x,y,0);
x_hull=x(t);
y_hull=y(t);

l_hull=sqrt((x_hull(1:end-1)-x_hull(2:end)).^2+(y_hull(1:end-1)-y_hull(2:end)).^2);
s=[0; cumsum(l_hull)];
S=linspace(0,max(s),PacN);
PacX=interp1(s,x_hull,S);
PacY=interp1(s,y_hull,S);

FixedPoint=zeros(PacN,1);
FixedPointN=0;
for i=1:length(x_hull)
    d=(x_hull(i)-PacX).^2+(y_hull(i)-PacY).^2;
    [m,k]=min(d);
    FixedPoint(k)=1;
    FixedPointN=FixedPointN+1;
end
FixedPoint(PacN)=1;
FixedPointN=FixedPointN+1;

if Draw
%     figure;
    cla; hold on; axis equal;
    plot(x,y,'.');
    plot(CX,CY,'*');
    plot(x(t),y(t));
    plot(x_hull,y_hull,'*');
    text(x_hull,y_hull,num2str((1:length(x_hull))'));
    plot(PacX,PacY,'b.');
    plot(PacX(FixedPoint==1),PacY(FixedPoint==1),'bo');
    text(PacX,PacY,num2str((1:PacN)'));
end
    
while FixedPointN<PacN
    k1=find(FixedPoint==0,1)-1;
    k2=find(FixedPoint(k1+1:end)==1,1)+k1;
    PackageAdvanceAngle=atan2(PacY(k2)-PacY(k1),PacX(k2)-PacX(k1))+pi/2;
    NewFixedPoint=0;
    gmax=MaxGap/2;
    while NewFixedPoint==0 && gmax<MaxGap% && min(PacY(k1:k2))>=0
        PackageAdvanceShape=PackageAdvanceDist*sin(linspace(0,pi,k2-k1+1));
        PacX(k1:k2)=PacX(k1:k2)+PackageAdvanceShape*cos(PackageAdvanceAngle);
        PacY(k1:k2)=PacY(k1:k2)+PackageAdvanceShape*sin(PackageAdvanceAngle);
        if Draw
            plot(PacX,PacY,'b.');
            plot(PacX(FixedPoint==1),PacY(FixedPoint==1),'bo');
            text(PacX,PacY,num2str((1:PacN)'));
        end
    
        for i=(k1+1):(k2-1)
            d=sqrt((PacX(i)-x).^2+(PacY(i)-y).^2);
            
            g=max(d);
            for j=1:FilterN
                [ddmin(j),s]=min(d);
                d(s)=g;
            end
            if mean(ddmin)<Dmin
                FixedPoint(i)=1;
                FixedPointN=FixedPointN+1;
                NewFixedPoint=1;
                if Draw
                    plot(PacX(i),PacY(i),'ro');
                end
            end
        end

        g=sqrt((PacX(k1:k2-1)-PacX(k1+1:k2)).^2+(PacY(k1:k2-1)-PacY(k1+1:k2)).^2);
        gmax=max(g);
    end
    if gmax>=MaxGap
        FixedPoint(k1:k2)=1;
        FixedPointN=FixedPointN+k2-k1-1;
    end
end

function xmin=minFirstN(x,N)
xmax=max(x);
for i=1:N
    [xmin,k]=min(x);
    x(k)=xmax;
end