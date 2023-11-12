function [X,Y,Z]=PointCloudTransformation6(x,X,Y,Z)
if isempty(X)
    return;
end
% [X,Y,Z]=RotateX_mex(X,Y,Z,x(4));
[X,Y,Z]=RotateX(X,Y,Z,x(4));
% [X,Y,Z]=RotateY_mex(X,Y,Z,x(5));
[X,Y,Z]=RotateY(X,Y,Z,x(5));
[X,Y,Z]=RotateZ(X,Y,Z,x(6));
X=X+x(1);
Y=Y+x(2);
Z=Z+x(3);

