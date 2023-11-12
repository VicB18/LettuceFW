function [X,Y,Z]=RotateY(X,Y,Z,a)
ca=cos(a); sa=sin(a);
x=ca*X+sa*Z;
z=-sa*X+ca*Z;
X=x;
Z=z;

% for i=1:length(X)
%     x=ca*X(i)+sa*Z(i);
%     y=Y(i);
%     z=-sa*X(i)+ca*Z(i);
%     X(i)=x;
%     Y(i)=y;
%     Z(i)=z;
% end