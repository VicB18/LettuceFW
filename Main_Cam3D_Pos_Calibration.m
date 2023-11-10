FolderName='F:\Lettuce\Piikkio_2023\2023_02_16_Day_02\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_02_21_Day_07\0 calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_02_28_Day_14\0 calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_03_09_Day_23\0 calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_03_23_Day_09\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_03_27_Day_13\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_03_30_Day_16\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_04_04_Day_21\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_04_28\0calibrations\';
% FolderName='F:\Lettuce\Piikkio_2023\2023_05_08_Day_21\0calibrations\';
FileList=dir(FolderName);

% TrInit=[-0.25 0 0 0 0 0;
%             0.15 -0.25 0 0 0 1/3*pi*2;
%             0.15 0.2 0 0 0 -1/3*pi*2;
%             0.02 0 0.25 0 1/4*pi*2 0];
TrInit=[-0.187 0.02 0.087 0.0022 0.217 -0.07;
             0.126 -0.23 0.1 0.029 0.17 2.03;
             0.18 0.18 0.09 0.015 0.24 -2.1;
             0.02 0 0.32 0 1.57 0];

CamROImin=[0.1+0.05 -0.14 -0.1;
                        0.1 -0.15 -0.1;
                        0.1 -0.15+0.05 -0.1;
                        0.1 -0.1-0.04 -0.1-0.02];
CamROImax=[0.33 0.15-0.1 0.1;
                         0.37 0.12 0.1;
                         0.4 0.1 0.13;
                         0.4 0.1 0.13];
[CameraN,m]=size(TrInit);
ViewN=3;
RefCam_i=4;

% CamViewObj={};
% CViewObj={};
% for Cam_i=1:CameraN
%     for View_i=1:ViewN
%         FileName=['Cam' num2str(Cam_i) '_' num2str(View_i) '.ply'];
%         [vertex,face,vertexColor]=read_ply([FolderName FileName]);
%         X=vertex(:,1); Y=vertex(:,2); Z=vertex(:,3); C=vertexColor;
%         x=X; y=Y; z=Z;
%         X=-z; Y=-x; Z=y;
%         
%         q=0<X & X<1 & -0.5<Y & Y<0.5 & -0.3<Z & Z<0.3;
%         X=X(q); Y=Y(q); Z=Z(q); C=C(q,:);
% 
% %         close all;
%         figure; title(['Cam ' num2str(Cam_i) ', View '  num2str(View_i)]); w=get(0,'DefaultFigurePosition'); set(gcf,'Position',[50 50 w(3) w(4)]);
%         hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
%         scatter3(X,Y,Z,0.1,C/256);
%         q=CamROImin(Cam_i,1)<X & X<CamROImax(Cam_i,1) & ...
%             CamROImin(Cam_i,2)<Y & Y<CamROImax(Cam_i,2) & ...
%             CamROImin(Cam_i,3)<Z & Z<CamROImax(Cam_i,3);
%         scatter3(X(q),Y(q),Z(q),1,[1 0 0]);
%         figure; title(['Cam ' num2str(Cam_i) ', View '  num2str(View_i)]); w=get(0,'DefaultFigurePosition'); set(gcf,'Position',[50 200 w(3) w(4)]);
%         hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
%         scatter3(X(q),Y(q),Z(q),1,C(q,:)/256);
%         CamViewObj{Cam_i,View_i}=[X(q) Y(q) Z(q)];
%         CViewObj{Cam_i,View_i}=C(q,:);
%     end
% end
% save('CamViewObj.mat','CamViewObj','CViewObj')
% return
load('CamViewObj.mat')

% for View_i=1:ViewN
% %     close all;
%     figure; w=get(0,'DefaultFigurePosition'); set(gcf,'Position',[50*View_i 50*View_i w(3) w(4)]);
%     hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
%     for Cam_i=1:CameraN
%         X=CamViewObj{Cam_i,View_i}(:,1);
%         Y=CamViewObj{Cam_i,View_i}(:,2);
%         Z=CamViewObj{Cam_i,View_i}(:,3);
%         C=CViewObj{Cam_i,View_i};
%         [X,Y,Z]=PointCloudTransformation6(TrInit(Cam_i,:),X,Y,Z);
%         scatter3(X,Y,Z,1,C/256);
%     end
% end

RefCamViewObj=cell(ViewN,1);
for View_i=1:ViewN
    X=CamViewObj{RefCam_i,View_i}(:,1);
    Y=CamViewObj{RefCam_i,View_i}(:,2);
    Z=CamViewObj{RefCam_i,View_i}(:,3);
    [X,Y,Z]=PointCloudTransformation6(TrInit(RefCam_i,:),X,Y,Z);
    RefCamViewObj{View_i}=[X Y Z];
    C=CViewObj{RefCam_i,View_i};
%     figure; w=get(0,'DefaultFigurePosition'); set(gcf,'Position',[50*View_i 50*View_i w(3) w(4)]);
%     scatter3(X,Y,Z,1,C/256); hold on;
end

figure;
CamCal=1:CameraN; CamCal=CamCal(CamCal~=RefCam_i);
for Cam_i=1:(CameraN-1)
    l1=[0.2 0.2 0.2 30*pi/180 30*pi/180 30*pi/180];
    xinit=TrInit(Cam_i,:);
    gaDat.FieldD=[xinit-l1; xinit+l1];
    gaDat.Objfun='PointCloudsFit_ObjFun';
    gaDat.MAXGEN=100;
    gaDat.NIND=100;
    gaDat.indini=xinit;
    s=10;
    CamViewObjS={};
    for View_i=1:ViewN
        CamViewObjS{1,View_i}=CamViewObj{Cam_i,View_i}(1:s:end,:);
    end
    for View_i=1:ViewN
        CamViewObjS{2,View_i}=RefCamViewObj{View_i}(1:s:end,:);
    end
    P.Draw=1;
    P.CamViewObj=CamViewObjS;
    P.CamN=2;
    P.ViewN=ViewN;
    gaDat.ObjfunPar=P;
    gaSol=ga(gaDat);
    x=gaSol.xmin;
    Tr(Cam_i,:)=x;
    disp(['F' num2str(Cam_i) '=' num2str(gaSol.fxmin)]);
end

Tr(RefCam_i,:)=TrInit(RefCam_i,:);

for View_i=1:ViewN
%         close all;
    figure; w=get(0,'DefaultFigurePosition'); set(gcf,'Position',[50*View_i 50*View_i w(3) w(4)]);
    hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
    for Cam_i=1:CameraN
        X=CamViewObj{Cam_i,View_i}(:,1);
        Y=CamViewObj{Cam_i,View_i}(:,2);
        Z=CamViewObj{Cam_i,View_i}(:,3);
        [X,Y,Z]=PointCloudTransformation6(Tr(Cam_i,:),X,Y,Z);
        scatter3(X,Y,Z,1);
    end
    legend('1','2','3','4');
end
s=[Tr(1,:) Tr(2,:) Tr(3,:) Tr(4,:)];
% disp(s);