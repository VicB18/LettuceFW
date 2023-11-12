function [PacX,PacY]=PointCloudToSurface2DVacuumPackage(x,y,PacN)
Dmin=1*(max(x)-min(x))/PacN;%threshold for proximity of the package point to the body point
PackageAdvanceDist=Dmin/2;%package point advancement step
MaxPacPointDist=5*(max(x)-min(x))/PacN;%maximal allowed distance between the package points simulating the package elastic force
FilterN=3;%number of body points to be considered as outlier
Draw=0;

t=boundary(x,y,0);
x_hull=x(t);
y_hull=y(t);

l_hull=sqrt((x_hull(1:end-1)-x_hull(2:end)).^2+(y_hull(1:end-1)-y_hull(2:end)).^2);
s=[0; cumsum(l_hull)];
S=linspace(0,max(s),PacN);
PacX=interp1(s,x_hull,S);%creating the package point according to the hull points
PacY=interp1(s,y_hull,S);%the package point can not coincident with the hull points

FixedPoint=zeros(PacN,1);%package point is fixed when it touches body points
for i=1:length(x_hull)
    d=(x_hull(i)-PacX).^2+(y_hull(i)-PacY).^2;
    [dmin,k]=min(d);%find the index of the nearest package point

    d=(x_hull(i)-x).^2+(y_hull(i)-y).^2;
    dmin=minFirstN(d,FilterN);%check if the hull point was not created by outliers
    if dmin<Dmin%if it was not outlier, fix the package point
        FixedPoint(k)=1;
    end
end
FixedPoint(1)=1;
FixedPoint(PacN)=1;
FixedPointN=sum(FixedPoint);

if Draw
%     figure;
    cla; hold on; axis equal;
    plot(x,y,'g.');
    plot(x(t),y(t),'b');
%     plot(x_hull,y_hull,'*');
%     text(x_hull,y_hull,num2str((1:length(x_hull))'));
    plot(PacX,PacY,'b.');
    plot(PacX(FixedPoint==1),PacY(FixedPoint==1),'b.','MarkerSize',10);
%     text(PacX,PacY,num2str((1:PacN)'));
end
    
while FixedPointN<PacN
    k1=find(FixedPoint==0,1)-1;%find an interval with unfixed package points
    k2=find(FixedPoint(k1+1:end)==1,1)+k1;
    PackageAdvanceAngle=atan2(PacY(k2)-PacY(k1),PacX(k2)-PacX(k1))+pi/2;%the package adnancement angle is perpendiculat to the interval ends
    NewFixedPoint=0;
    while NewFixedPoint==0
        PackageAdvanceShape=PackageAdvanceDist*sin(linspace(0,pi,k2-k1+1));%sinusoid is taken for simulating package shape
        PacX(k1:k2)=PacX(k1:k2)+PackageAdvanceShape*cos(PackageAdvanceAngle);%the direction is correct if the hull points are numbered in the positive direction
        PacY(k1:k2)=PacY(k1:k2)+PackageAdvanceShape*sin(PackageAdvanceAngle);
        if Draw
            plot(PacX,PacY,'b.');
            plot(PacX(FixedPoint==1),PacY(FixedPoint==1),'b.','MarkerSize',10);
%             text(PacX,PacY,num2str((1:PacN)'));
        end
    
        for i=(k1+1):(k2-1)
            d=sqrt((PacX(i)-x).^2+(PacY(i)-y).^2);
            
            dmin=minFirstN(d,FilterN);
            if dmin<Dmin
                FixedPoint(i)=1;
                FixedPointN=FixedPointN+1;
                NewFixedPoint=1;
                if Draw
%                     plot(PacX(i),PacY(i),'ro');
                end
            end
        end

        PacPointDist=sqrt((PacX(k1:k2-1)-PacX(k1+1:k2)).^2+(PacY(k1:k2-1)-PacY(k1+1:k2)).^2);%distance between the package points
        if max(PacPointDist)>=MaxPacPointDist%package elastic force is equalized with the air pressure force
            FixedPoint(k1:k2)=1;%package advancement is stopped
            FixedPointN=FixedPointN+k2-k1-1;
            NewFixedPoint=1;
        end
    end
end

function [xmin,k]=minFirstN(x,N)
xmax=max(x);
for i=1:N
    [xmin,k]=min(x);
    x(k)=xmax;
end