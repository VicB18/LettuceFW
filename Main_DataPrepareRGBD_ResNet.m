DataFolder='F:\Lettuce\Piikkio_2023_Test\';
% DataFolder='F:\Lettuce\WUR_OnlineChallenge\';

RESNETimsize=224;

if contains(DataFolder,'Piikkio_2023')
    FL=ReadExpFileList(DataFolder,{'2023_03_09','2023_04_04','2023_05_16'});
    OutputFolder=['F:\Lettuce\Piikkio_2023_RGH' num2str(RESNETimsize)];
    CameraHeight=0.32;%m
    CameraD405WA=87; CameraD405HA=58;
    ImW=1280; ImH=720;
    kx=2*CameraHeight*1000*tand(CameraD405WA/2)/ImW;
    ky=2*CameraHeight*1000*tand(CameraD405HA/2)/ImH;
    k=(kx+ky)/2;%mm/pix for D405 at h=0.32m %0.5*(150/306)
    ResolutionFactor_RGB=k/2; %kmm/pix / 2mm/pix
elseif contains(DataFolder,'WUR_OnlineChallenge')
    FL=ReadOnlineChallengeFileList(DataFolder);
    OutputFolder=['F:\Lettuce\WUR_OnlineChallenge_RGH' num2str(RESNETimsize)];
    CameraHeight=0.9;%m
    ImW=1920; ImH=1080;
    CameraD415WA=69; CameraD415HA=42;
    kx=2*CameraHeight*1000*tand(CameraD415WA/2)/ImW;
    ky=2*CameraHeight*1000*tand(CameraD415HA/2)/ImH;
    k=(kx+ky)/2;%mm/pix for D415 at h=0.9m
    ResolutionFactor_RGB=k/2; %kmm/pix / 2mm/pix
end
mkdir(OutputFolder);

k_Depth=0.5;%gray scale unit/mm

for Plant_i=140:length(FL)
    if contains(DataFolder,'Piikkio_2023')
        disp([num2str(Plant_i) ' / ' num2str(length(FL)) ' ' FL(Plant_i).Path]);
        A=imread([FL(Plant_i).Path '\' 'Cam4.png']);
        if isfile([FL(Plant_i).Path '\' 'Depth4.bin'])
            D=ReadDepthBin([FL(Plant_i).Path '\'],'Depth4.bin',ImW,ImH);
        elseif isfile([FL(Plant_i).Path '\' 'Depth4.png'])
            D=imread([FL(Plant_i).Path '\' 'Depth4.png']);
            D=double(D)/1000;
        end
    elseif contains(DataFolder,'WUR_OnlineChallenge')
        disp([num2str(Plant_i) ' / ' num2str(length(FL)) ' ' FL(Plant_i).FileName1{1}]);
        A=imread([FL(Plant_i).Path1 FL(Plant_i).FileName1{1}]);
        D=imread([FL(Plant_i).Path FL(Plant_i).FileName{1}]);
        D=double(D)/1000;
    end
    H=zeros(ImH,ImW,'uint8');
    H(D~=0)=uint8((CameraHeight-D(D~=0))*k_Depth*1000);%
%     imshow(A); imshow(double(D)/double(max(max(D))));
% figure; imshow(H); imshow(D);

    A1=imresize(A,ResolutionFactor_RGB); % imshow(A1); hold on; scatter(x,y); 
    H1=imresize(H,ResolutionFactor_RGB); % figure; imshow(H1);

    R1=A1(:,:,1); G1=A1(:,:,2); B1=A1(:,:,3);
    q_plant=H1>10; %imshow(q_plant);
    [n,m]=size(q_plant);
    x=0; y=0; l=0;
    for i=round(n/4):round(3*n/4)
        for j=round(m/4):round(3*m/4)
            if q_plant(i,j)
                x=x+i;
                y=y+j;
                l=l+1;
            end
        end
    end
    x=round(x/l); y=round(y/l);
    xmin=max([1,x-RESNETimsize/2]);
    xmax=min([n,x+RESNETimsize/2-1]);
    ymin=max([1,y-RESNETimsize/2]);
    ymax=min([m,y+RESNETimsize/2-1]);

    R2=zeros(RESNETimsize,RESNETimsize,'uint8')+255;
    G2=zeros(RESNETimsize,RESNETimsize,'uint8')+255;
%     B2=zeros(RESNETimsize,RESNETimsize,'uint8')+255;
    H2=zeros(RESNETimsize,RESNETimsize,'uint8')+0;

    xx=(RESNETimsize-xmax+xmin-1)+(1:(xmax-xmin+1));
    yy=(RESNETimsize-ymax+ymin-1)+(1:(ymax-ymin+1));

    R2(xx,yy)=R1(xmin:xmax,ymin:ymax);
    G2(xx,yy)=G1(xmin:xmax,ymin:ymax);
%     B2(xx,yy)=B1(xmin:xmax,ymin:ymax);
    H2(xx,yy)=H1(xmin:xmax,ymin:ymax);

%     RGB2=cat(3,R2,G2,B2);
    RGH2=cat(3,R2,G2,H2); % imshow(RGB2);imshow(RGH2);imshow(H2);
%     imwrite(RGB2,[OutputFolder '\' FL(Plant_i).Date '_' num2str(FL(Plant_i).PlantNo) '.png']);
    imwrite(RGH2,[OutputFolder '\' FL(Plant_i).Date '_' num2str(FL(Plant_i).PlantNo) '.png']);
    s=[FL(Plant_i).Date '_' num2str(FL(Plant_i).PlantNo) '.png;' num2str(FL(Plant_i).RefFreshWeight) newline];
    if ~isfile([OutputFolder '\' 'LettuceMassReference.csv'])
        fid=fopen([OutputFolder '\' 'LettuceMassReference.csv'], 'a');
        fprintf(fid,['FileName;FreshWeightRef' newline]);
        fclose(fid);
    end
    fid=fopen([OutputFolder '\' 'LettuceMassReference.csv'], 'a');
    fprintf(fid,s);
    fclose(fid);
end
% writelines(ImList,[OutputFolder '\' 'LettuceMassReference.csv']);