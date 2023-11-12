function [X,Y,Z,q]=PCstdFilter(X,Y,Z,s)
mx=mean(X);
my=mean(Y);
mz=mean(Z);

d=sqrt((X-mx).^2+(Y-my).^2+(Z-mz).^2);
r=mean(d);

q=d<r*s;

X=X(q);
Y=Y(q);
Z=Z(q);