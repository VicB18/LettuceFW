function [X,Y,Z,C]=AddBottom(X,Y,Z,C,d,c)
% dZ=max(Z)-min(Z);
% q=Z<min(Z)+max([dZ/20 0.05]);
q=Z>0;%all silhuate
Xlow=X(q); Ylow=Y(q);
xmax=max(Xlow); xmin=min(Xlow);
ymax=max(Ylow); ymin=min(Ylow);
t=boundary(Xlow,Ylow,0.25);

% xx=xmin:d:xmax;
% for x_i=1:(length(xx)-1)
%     qx=xx(x_i)<=Xlow & Xlow<xx(x_i+1);
%     ymin=min(Ylow(qx));
%     ymax=max(Ylow(qx));
%     yy=ymin:d:ymax;
%     X=[X; yy'*0+xx(x_i)];
%     Y=[Y; yy'];
%     Z=[Z; yy'*0+rand(length(yy),1)*d/10];
%     C=[C; repmat(c,length(yy),1)];
% end
[xx,yy]=meshgrid(xmin:d:xmax,ymin:d:ymax);
[n,m]=size(xx);
Xb_list=reshape(xx,[],1);
Yb_list=reshape(yy,[],1);
% Zb_list=rand(n*m,1)*d/10;
% Cb_list=repmat(c,n*m,1);

q=inpolygon(Xb_list,Yb_list,Xlow(t),Ylow(t));
% figure; hold on; axis equal; plot(Xlow,Ylow,'*'); plot(Xlow(t),Ylow(t)); plot(Xb_list(q),Yb_list(q),'.');

X=[X; Xb_list(q)];
Y=[Y; Yb_list(q)];
Z=[Z; rand(sum(q),1)*d/10;];
C=[C; repmat(c,sum(q),1)];
% 
% q=true(n*m,1);
% for i=1:length(X)
%     D=sqrt((X(i)-Xlow).^2+(Y(i)-Ylow).^2);
%     dmin=min(D);
%     q(i)=dmin<d;
% end
% X=[X; Xb_list(q)];
% Y=[Y; Yb_list(q)];
% Z=[Z; Zb_list(q)];
% C=[C; Cb_list(q,:)];
