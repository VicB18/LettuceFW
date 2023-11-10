DataFolder='F:\Lettuce\Piikkio_2023\';
% DataFolder='F:\Lettuce\WUR_OnlineChallenge\';
Draw=0;

if contains(DataFolder,'Piikkio_2023')
    FL=ReadExpFileList(DataFolder,{'2023_03_09','2023_04_04','2023_05_16'});
    OutputFolder='F:\Lettuce\Piikkio_2023_ResNet50_RGB';
    CameraHeight=0.32;%m
    CameraWA=87; CameraHA=58;
    ImW=1280; ImH=720;
    ObjectDist=0.20;
elseif contains(DataFolder,'WUR_OnlineChallenge')
    FL=ReadOnlineChallengeFileList(DataFolder);
    OutputFolder=['F:\Lettuce\WUR_OnlineChallenge_RGH' num2str(RESNETimsize)];
    CameraHeight=0.9;%m
    ImW=1920; ImH=1080;
    CameraWA=69; CameraHA=42;
    ObjectDist=0.25;
end

for Plant_i=1:length(FL)
    disp([num2str(Plant_i ) ' / ' num2str(length(FL))]);
    if Draw
        figure;
        cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
        title(strrep([FL(Plant_i).Date ', ' FL(Plant_i).PlantNo ', ref=' num2str(FL(Plant_i).RefFreshWeight)],'_','.'));
    end
    XX=[]; YY=[]; ZZ=[]; CC=[];
    for Cam_i=1:FL(Plant_i).CameraN
        if contains(FL(Plant_i).FileName{Cam_i},'.ply')
            [vertex,face,vertexColor]=read_ply([FL(Plant_i).Path FL(Plant_i).FileName{Cam_i}]);
            X=vertex(:,1); Y=vertex(:,2); Z=vertex(:,3); C=vertexColor;
            x=X; y=Y; z=Z;
            X=-z; Y=-x; Z=y;
        elseif contains(FL(Plant_i).FileName{Cam_i},'.png')
            D=imread([FL(Plant_i).Path FL(Plant_i).FileName{Cam_i}]);
            A=imread([FL(Plant_i).Path1 FL(Plant_i).FileName1{Cam_i}]);
%             D1=double(D)./max(max(double(D))); imshow(D1);
            [X,Y,Z,C]=DepthToPointCloud(D,65,40,A,Draw*0);
            x=X; y=Y; z=Z;
            X=x; Y=-y; Z=-z;% cla;scatter3(X,Y,Z,1,C/256);
        end

        [X,Y,Z]=PointCloudTransformation6(FL(Plant_i).TransformationQ(Cam_i,:),X,Y,Z);
        q=-ObjectDist<X & X<ObjectDist & -ObjectDist<Y & Y<ObjectDist & -0.05<Z & Z<1.5*ObjectDist;
        X=X(q); Y=Y(q); Z=Z(q); C=C(q,:);
        
        R=C(:,1); G=C(:,2); B=C(:,3);
        GG=double((G-R)+(G-B))./double(G);
        q_plant=G*0.8>B & R*0.8>B & G>50; %scatter3(X(q_plant),Y(q_plant),Z(q_plant),1,C(q_plant,:)/256);
        q=q_plant & Z>0;
        X=X(q); Y=Y(q); Z=Z(q); C=C(q,:);
        CC=CC(q,:);

        if Draw
            scatter3(X,Y,Z,1,C/256);
        end
        XX=[XX; X]; YY=[YY; Y]; ZZ=[ZZ; Z]; CC=[CC; C];
        [XX,YY,ZZ,q]=PCstdFilter(XX,YY,ZZ,2); %scatter3(XX,YY,ZZ,1);
        if FL(Plant_i).CameraN==1 || (Cam_i==4 && FL(Plant_i).CameraN==4)
            X_top=X; Y_top=Y; Z_top=Z; C_top=C;
        end
    end
    [XX,YY,ZZ,CC]=AddBottom(XX,YY,ZZ,CC,0.001,[128 0 0]);
    [X_top,Y_top,Z_top,C_top]=AddBottom(X_top,Y_top,Z_top,C_top,0.001,[128 0 0]);

    if Draw
        figure;
        cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
        scatter3(XX,YY,ZZ,1,CC/256); view(-90,25);
        figure;
        cla; hold on; axis equal; rotate3d on; xlabel('X'); ylabel('Y'); zlabel('Z');
        scatter3(X_top,Y_top,Z_top,1,C_top/256); view(-90,25);
    end
    
    save([FL(Plant_i).Path 'XYZC'],'XX','YY','ZZ','CC');
    savepcd([FL(Plant_i).Path 'XYZC.pcd'],[XX YY ZZ CC]');

    XX=X_top; YY=Y_top; ZZ=Z_top; CC=C_top;
    save([FL(Plant_i).Path 'XYZC_Top'],'XX','YY','ZZ','CC');
    savepcd([FL(Plant_i).Path 'XYZC_Top.pcd'],[XX YY ZZ CC]');
end
