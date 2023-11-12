function [X,Y,Z,C]=DepthToPointCloud(D,WidthAngle,HeightAngle,RGB,Draw)%n=1280, m=720
[m,n]=size(D);
DepthScale=0.001;
kx=tand(WidthAngle/2)/(n/2);
ky=tand(HeightAngle/2)/(m/2);
Zgrid=zeros(size(D)); Xgrid=Zgrid; Ygrid=Zgrid;
D=double(D)*DepthScale;
for i=1:n
    ix=(n/2-i);
    for j=1:m
        iy=(m/2-j);
        Zgrid(j, i) = D(j, i);
        Xgrid(j, i) = Zgrid(j, i)*ix*kx;
        Ygrid(j, i) = Zgrid(j, i)*iy*ky;
   end
end

f=~isempty(RGB);
X=zeros(n*m,1); Y=zeros(n*m,1); Z=zeros(n*m,1);
if f
    C=zeros(n*m,3);
else
    C=[];
end
k=0;
for i=1:n
    for j=1:m
        if Zgrid(j,i)~=0 && Xgrid(j,i)~=0 && Ygrid(j,i)~=0
            k=k+1;
            X(k)=-Xgrid(j,i);
            Y(k)=Ygrid(j,i);
            Z(k)=Zgrid(j,i);
            if f
                C(k,:)=RGB(j,i,:);
            end
        end
    end
end

X=X(1:k); Y=Y(1:k); Z=Z(1:k);
if f
    C=C(1:k,:);
end

if Draw
    figure; hold on; rotate3d on;
    if f
        scatter3(X,Y,Z,1,C/256);
    else
        plot3(X,Y,Z,'.');
    end
    % tri=delaunay(X,Y);
    % trimesh(tri,X,Y,Z);
    axis equal; xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
end