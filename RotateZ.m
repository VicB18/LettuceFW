function [X,Y,Z]=RotateZ(X,Y,Z,a)
% Rx=[cos(a) -sin(a) 0; sin(a) cos(a) 0; 1 0 0];
if a==0
    return;
end
ca=cos(a); sa=sin(a);
x=ca*X-sa*Y;
y=sa*X+ca*Y;
X=x;
Y=y;
% for i=1:length(X)
%     x=ca*X(i)-sa*Y(i);
%     y=sa*X(i)+ca*Y(i);
%     z=Z(i);
%     X(i)=x;
%     Y(i)=y;
%     Z(i)=z;
% end
