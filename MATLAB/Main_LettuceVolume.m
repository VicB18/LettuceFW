DataFolder='F:\Lettuce\Piikkio_2023_Test\';%
% DataFolder='F:\Lettuce\WUR_OnlineChallenge\';

TopView=0;% 0 for 4 views
Draw=0;

VacuumPackageMethod=0; AN=24; PacN=200;
AlphaShapeMethod=0; Alpha_Param=0.2;
BallPivotingMethod=0; BallPivotingR=0.05;%minimal radius without holes in reconstructed surface

if TopView
    ResFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
else
    ResFileName=[DataFolder 'CalculatedPlantVolume_All.csv'];
end

if contains(DataFolder,'Piikkio_2023')
    FL=ReadExpFileList(DataFolder,{'2023_03_09','2023_04_04','2023_05_16'});
    if TopView
        PCfile='XYZC_Top.mat';
    else
        PCfile='XYZC.mat';    
    end
    ObjectDist=0.20;
elseif contains(DataFolder,'WUR_OnlineChallenge')
    FL=ReadOnlineChallengeFileList(DataFolder);
    CameraWA=69; CameraHA=42;
    ObjectDist=0.25;
    if TopView
        PCfile='XYZC_Top.mat';
    else
        disp('No all 4 views for the WUR dataset.');    
        return;
    end
end

if ~isfile(ResFileName)
    s='Date;PlantNo;RefFreshWeight;';
    if VacuumPackageMethod
        s=[s 'VP;'];
    end
    if AlphaShapeMethod
        s=[s 'AS;'];
    end        
    if BallPivotingMethod
        s=[s 'BP;'];
    end

    fid=fopen(ResFileName,'a');
    fprintf(fid,[s '\n']);
    fclose(fid);
end

for Plant_i=127:length(FL)%277, 309127
    if Draw
        figure;
        cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
        title(strrep([FL(Plant_i).Date ', ' FL(Plant_i).PlantNo ', Ref FW=' num2str(FL(Plant_i).RefFreshWeight) ' g'],'_','.'));
    end
    disp([num2str(Plant_i ) ' / ' num2str(length(FL)) ', ' FL(Plant_i).Path FL(Plant_i).FileName{1}]);
    if isfile([FL(Plant_i).Path FL(Plant_i).PlantNo PCfile]) % the poin cloud was created before
        load([FL(Plant_i).Path FL(Plant_i).PlantNo PCfile]);
        if Draw
%             figure;
            cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
            scatter3(XX,YY,ZZ,1,CC/256); view(-90,75);
            title(strrep([FL(Plant_i).Date ', ' FL(Plant_i).PlantNo ', Ref FW=' num2str(FL(Plant_i).RefFreshWeight) ' g'],'_','.'));
%             continue
        end
    else % to create the point cloud
        XX=[]; YY=[]; ZZ=[]; CC=[];
        for Cam_i=1:FL(Plant_i).CameraN
            if contains(FL(Plant_i).FileName{Cam_i},'.ply') % in Pii dataset
                [vertex,face,vertexColor]=read_ply([FL(Plant_i).Path FL(Plant_i).FileName{Cam_i}]);
                X=vertex(:,1); Y=vertex(:,2); Z=vertex(:,3); C=vertexColor;
                x=X; y=Y; z=Z;
                X=-z; Y=-x; Z=y;
%                 A=imread([FL(Plant_i).Path 'Cam' num2str(Cam_i) '.png']); figure; imshow(A);
            elseif contains(FL(Plant_i).FileName{Cam_i},'.png') % in WUR dataset
                D=imread([FL(Plant_i).Path FL(Plant_i).FileName{Cam_i}]);
                A=imread([FL(Plant_i).Path1 FL(Plant_i).FileName1{Cam_i}]);
%                 figure; imshow(A);
    %             D1=double(D)./max(max(double(D))); imshow(D1);
                [X,Y,Z,C]=DepthToPointCloud(D,CameraWA,CameraHA,A,Draw*0);
                x=X; y=Y; z=Z;
                X=x; Y=y; Z=-z;
            end
            [X,Y,Z]=PointCloudTransformation6(FL(Plant_i).TransformationQ(Cam_i,:),X,Y,Z);
            r=ObjectDist;
            q=-r<X & X<r & -r<Y & Y<r & -0.05<Z & Z<1.5*r;
            X=X(q); Y=Y(q); Z=Z(q); C=C(q,:);
            
            R=C(:,1); G=C(:,2); B=C(:,3);
            if contains(FL(Plant_i).Variety,'Katusa')
                q_plant=G*0.8>B & R*0.8>B & G>20;
            elseif contains(FL(Plant_i).Variety,'Salanova') || contains(FL(Plant_i).Variety,'Satine')
                q_plant=R>B & G>B & B<100 & R<150;
            else
                q_plant=G*0.8>B & R*0.8>B & G>20 & R<200;
             end
            q=q_plant;
            X=X(q); Y=Y(q); Z=Z(q); C=C(q,:);

            if Draw
                scatter3(X,Y,Z,1,C/256);
            end
            XX=[XX; X]; YY=[YY; Y]; ZZ=[ZZ; Z]; CC=[CC; C];
            if FL(Plant_i).CameraN==1 || (Cam_i==4 && FL(Plant_i).CameraN==4)
                X_top=X; Y_top=Y; Z_top=Z; C_top=C;
            end
        end
        q=ZZ>0;
        XX=XX(q); YY=YY(q); ZZ=ZZ(q); CC=CC(q,:);
        [XX,YY,ZZ,q]=PCstdFilter(XX,YY,ZZ,1.5); %scatter3(XX,YY,ZZ,1);
        CC=CC(q,:);
        xm=mean(XX); ym=mean(YY);
        XX=XX-xm; YY=YY-ym;

        q=Z_top>0;
        X_top=X_top(q); Y_top=Y_top(q); Z_top=Z_top(q); C_top=C_top(q,:);
        [X_top,Y_top,Z_top,q]=PCstdFilter(X_top,Y_top,Z_top,2); %scatter3(X_top,Y_top,Z_top,1);
        C_top=C_top(q,:);
        xm=mean(X_top); ym=mean(Y_top);
        X_top=X_top-xm; Y_top=Y_top-ym;

        [XX,YY,ZZ,CC]=AddBottom(XX,YY,ZZ,CC,0.001,[128 0 0]);
        [X_top,Y_top,Z_top,C_top]=AddBottom(X_top,Y_top,Z_top,C_top,0.001,[128 0 0]);

        if FL(Plant_i).CameraN==4
            save([FL(Plant_i).Path FL(Plant_i).PlantNo 'XYZC'],'XX','YY','ZZ','CC');
            if Draw
                figure;
                cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
                scatter3(XX,YY,ZZ,1,CC/256);
            end
            X_all=XX; Y_all=YY; Z_all=ZZ; CC_all=CC;
        end
        
        XX=X_top; YY=Y_top; ZZ=Z_top; CC=C_top;
        save([FL(Plant_i).Path FL(Plant_i).PlantNo 'XYZC_Top'],'XX','YY','ZZ','CC');
        if Draw
            figure;
            cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
            scatter3(XX,YY,ZZ,1,CC/256); view(-90,25);
        end

        if TopView==0
            XX=X_all; YY=Y_all; ZZ=Z_all; CC=CC_all;
        end
    end

    if VacuumPackageMethod
        [PacX,PacY,PacZ,VolumeVP]=PointCloudToSurfaceSlicedVacuumPackage(XX,YY,ZZ,AN,PacN);
        VolumeVP=VolumeVP*10^6;%cm^3
        if Draw
            figure;
            cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
            scatter3(XX,YY,ZZ,1,CC/256);
            scatter3(PacX,PacY,PacZ,1,[0 0 1]);
        end
    end
    if AlphaShapeMethod
        t=boundary(XX,YY,ZZ,Alpha_Param);
        VolumeAS=MeshVolume(t,XX,YY,ZZ,[])*1000;    
        if Draw
            figure;
            cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
            scatter3(XX,YY,ZZ,1,CC/256);
            trisurf(t,XX,YY,ZZ,'EdgeColor','none');%,'FaceColor','r'
            axis([-Inf Inf 0 Inf -Inf Inf]);
        end
    end        
    if BallPivotingMethod
%         [mesh,depth,perVertexDensity]=pc2surfacemesh(ptCloudIn,"poisson");
        tetr=delaunayn([XX YY ZZ]);
        [t,tnorm]=BallFretting(tetr,[XX YY ZZ],BallPivotingR);
        VolumeBP=MeshVolume(t,XX,YY,ZZ,tnorm)*1000;
        if Draw
            figure;
            cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
            scatter3(XX,YY,ZZ,1,CC/256);
            trisurf(t,XX,YY,ZZ,'EdgeColor','none');%,'FaceColor','r'
            axis([-Inf Inf 0 Inf -Inf Inf]);
        end
    end

    s=[FL(Plant_i).Date ';' FL(Plant_i).PlantNo ';' num2str(FL(Plant_i).RefFreshWeight) ';'];
    if VacuumPackageMethod
        s=[s num2str(round(VolumeVP,2)) ';'];
    end
    if AlphaShapeMethod
        s=[s num2str(round(VolumeAS,2)) ';'];
    end        
    if BallPivotingMethod
        s=[s num2str(round(VolumeBP,2)) ';'];
    end
    s=[s '\n'];
    fid=fopen(ResFileName,'a');
    fprintf(fid,s);
    fclose(fid);
end

%% Paper Fig. 2. Reconstruction methods examples
load('F:\Lettuce\Piikkio_2023_Test\2023_03_09_Day_23\1\1XYZC.mat');

t=boundary(XX,YY,ZZ,Alpha_Param);
figure; hold on; axis equal;
h = gca; h.XAxis.Visible = 'off'; h.YAxis.Visible = 'off'; h.ZAxis.Visible = 'off';
colormap bone;
scatter3(XX,YY,ZZ,1,CC/256);
trisurf(t,XX,YY,ZZ,'EdgeColor','none');
% axis([-Inf Inf 0 Inf -Inf Inf]);
axis([-0.15 0.15 -0.15 0.15 0 0.15]);
set(gcf,'Position',[50 100 400 300]*1.2);
view(-40,20);

figure; hold on; axis equal;
h = gca; h.XAxis.Visible = 'off'; h.YAxis.Visible = 'off'; h.ZAxis.Visible = 'off';
colormap bone;
scatter3(XX,YY,ZZ,1,CC/256);
trisurf(t,XX,YY,ZZ,'EdgeColor','none');
axis([-0.15 0.15 0 0.3 0 0.15]);
set(gcf,'Position',[150 200 400 300]*1.2);
view(-40,20);

tetr=delaunayn([XX YY ZZ]);
[t,tnorm]=BallFretting(tetr,[XX YY ZZ],BallPivotingR);
figure; hold on; axis equal;
h = gca; h.XAxis.Visible = 'off'; h.YAxis.Visible = 'off'; h.ZAxis.Visible = 'off';
colormap bone;
scatter3(XX,YY,ZZ,1,CC/256);
trisurf(t,XX,YY,ZZ,'EdgeColor','none');
% axis([-Inf Inf 0 Inf -Inf Inf]);
axis([-0.15 0.15 -0.15 0.15 0 0.15]);
set(gcf,'Position',[250 300 400 300]*1.2);
view(-40,20);

figure; hold on; axis equal;
h = gca; h.XAxis.Visible = 'off'; h.YAxis.Visible = 'off'; h.ZAxis.Visible = 'off';
colormap bone;
scatter3(XX,YY,ZZ,1,CC/256);
trisurf(t,XX,YY,ZZ,'EdgeColor','none');
axis([-0.15 0.15 0 0.3 0 0.15]);
set(gcf,'Position',[350 400 400 300]*1.2);
view(-40,20);


% Paper Fig. 3. Vacuum package explanation
% Plant F:\Lettuce\Piikkio_2023\2023_03_09_Day_23\1\
% view(-60,30); h = gca; h.XAxis.Visible = 'off'; h.YAxis.Visible = 'off'; h.ZAxis.Visible = 'off';
% set(gcf,'Position',[50 200 400 300]); axis tight;
% Sector 20

% [PacX,PacY,PacZ,VolumeVP]=PointCloudToSurfaceSlicedVacuumPackage(XX,YY,ZZ,AN,PacN);
% figure; hold on; axis equal; rotate3d on;
% DT=delaunayTriangulation(PacX,PacY,PacZ);
% tetramesh(DT);%,'FaceAlpha',0.3
% scatter3(PacX,PacY,PacZ,1,[0 0 1]);