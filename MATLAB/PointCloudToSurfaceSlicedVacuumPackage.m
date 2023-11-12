function [PacX,PacY,PacZ,Vtotal]=PointCloudToSurfaceSlicedVacuumPackage(XX,YY,ZZ,AN,PacN)
Draw=0;
Vtotal=0;
PacX=zeros(AN*PacN,1); PacY=zeros(AN*PacN,1); PacZ=zeros(AN*PacN,1);
SectorAngle=linspace(0,pi,AN+1);
A=atan2(YY,XX);
for sector_i=1:AN
    q=(SectorAngle(sector_i)<=A & A<SectorAngle(sector_i+1)) | (SectorAngle(sector_i)<=A+pi & A+pi<SectorAngle(sector_i+1));
%     if Draw
%         scatter3(XX(q),YY(q),ZZ(q),1,[0 sector_i/AN 0]);
%     end
    if abs(SectorAngle(sector_i)-pi/2)>0.1
        r=abs(XX(q))./cos(A(q));%projection of the sector to a plane
    else
        r=abs(YY(q))./sin(A(q));
    end
    z=ZZ(q);
    [px,py]=PointCloudToSurface2DVacuumPackage(r,z,PacN);
    if Draw
        cla; hold on; axis equal; plot(r,z,'g.');
        plot(px,py,'b.');
        plot(px,py,'b');
        title(num2str(sector_i));
%         set(gcf,'Position',[50 200 200 150]); axis([min(px)-0.01 max(px)+0.01 min(py)-0.01 max(py)+0.01]); axis equal;
    end
    if sector_i>AN/2+1
        px=-px;
        px=flip(px);
        py=flip(py);
    end
    PacX((sector_i-1)*PacN+(1:PacN))=px*cos(SectorAngle(sector_i));
    PacY((sector_i-1)*PacN+(1:PacN))=px*sin(SectorAngle(sector_i));
    PacZ((sector_i-1)*PacN+(1:PacN))=py;
    for i=1:PacN-1
        if px(i)>0 
            dS=pi*(px(i)^2-px(i+1)^2)/AN/2;
        else
            dS=pi*(px(i+1)^2-px(i)^2)/AN/2;
        end
        Vsector=dS*(py(i+1)+py(i))/2;
        Vtotal=Vtotal+Vsector;
    end
end

if Draw
    figure; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
    scatter3(PacX,PacY,PacZ,1,[0 0 1]);
%     figure; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
%     t=delaunayn([PacX,PacY,PacZ]);
%     t=boundary(PacX,PacY,PacZ,1);
%     trisurf(t,PacX,PacY,PacZ,'EdgeColor','none');
end
%     view(-158,54);