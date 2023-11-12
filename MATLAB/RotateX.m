function [X,Y,Z]=RotateX(X,Y,Z,a)
% Rx=[1 0 0; 0 cos(a) -sin(a); 0 sin(a) cos(a)];
ca=cos(a); sa=sin(a);
y=ca*Y-sa*Z;
z=sa*Y+ca*Z;
Y=y;
Z=z;
% for i=1:length(X)
%     x=X(i);
%     y=ca*Y(i)-sa*Z(i);
%     z=sa*Y(i)+ca*Z(i);
%     X(i)=x;
%     Y(i)=y;
%     Z(i)=z;
% end
