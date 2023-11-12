% FL=ReadExpFileList('F:\Lettuce\Piikkio_2023\',{'2023_03_09'});
CameraAngleW=87+4; CameraAngleH=58+2;
ImW=1280; ImH=720; h_WUR=0.9; kx=(ImW/2)/(CameraAngleW/2);  ky=(ImH/2)/(CameraAngleH/2);% ImWx=h*tand(69/2)*2; ImWy=h*tand(42/2)*2;

for Plant_i=1:length(FL)
    disp([num2str(Plant_i) ' / ' num2str(length(FL)) ' ' FL(Plant_i).Path]);
    Cam_i=4;
    [vertex,face,vertexColor]=read_ply([FL(Plant_i).Path FL(Plant_i).FileName{Cam_i}]);
    X=vertex(:,1); Y=vertex(:,2); Z=vertex(:,3); C=vertexColor;
    [RGB,D]=PointCloudToDepth(X,Y,Z,C,ImW,ImH,CameraAngleW,CameraAngleH);

    if ~isfile([FL(Plant_i).Path 'Cam4.png']) || contains(FL(Plant_i).PlantNo,'.')
        imwrite(RGB,[FL(Plant_i).Path '\' 'Cam4.png']);
    end
    imwrite(D,[FL(Plant_i).Path '\' 'Depth4.png']);
    imwrite(uint8(double(D)/double(max(max(D)))*255),[FL(Plant_i).Path '\' 'Depth4_Gray.png']);
    % figure; imshow(RGB);
    % figure; imshow(D);
end