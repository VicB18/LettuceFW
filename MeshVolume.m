function V=MeshVolume(t,X,Y,Z,tnorm)
% figure; trisurf(t,X,Y,Z,'EdgeColor','none'); hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
nf=~isempty(tnorm);

V=0;
for j=1:length(t)
    x1=X(t(j,1)); x2=X(t(j,2)); x3=X(t(j,3));
    y1=Y(t(j,1)); y2=Y(t(j,2)); y3=Y(t(j,3));
    z1=Z(t(j,1)); z2=Z(t(j,2)); z3=Z(t(j,3));
    dV=(z1+z2+z3)*(x1*y2-x2*y1+x2*y3-x3*y2+x3*y1-x1*y3)/6;%https://www.mathpages.com/home/kmath393.htm
%     V=V+abs(dV);
    if nf
        if tnorm(j,3)>0
            V=V+abs(dV);
        else
            V=V-abs(dV)*0;%there is a inner layer that compensates all the volume from the upper layer
        end
    else
        V=V+abs(dV);
    end
%     if abs(dV)>0.000001
% dV
%     end
%     if tnorm(j,3)>0
%         patch([x1 x2 x3],[y1 y2 y3],[z1 z2 z3],'green','EdgeColor','none');
%     else
%         patch([x1 x2 x3],[y1 y2 y3],[z1 z2 z3],'red','EdgeColor','none');
%     end
%     plot3((x1+x2+x3)/3+[0 tnorm(j,1)]*abs(x1-x2-x3),(y1+y2+y3)/3+[0 tnorm(j,2)]*abs(x1-x2-x3),(z1+z2+z3)/3+[0 tnorm(j,3)]*abs(x1-x2-x3),'g','LineWidth',2)
%     disp(tnorm(j,:))
end
V=V*1000;%liters
