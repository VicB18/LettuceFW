DataFolder='C:\Users\03138529\Desktop\WUR_OnlineChallenge_RGH224\';
OutputFolder='C:\Users\03138529\Desktop\WUR_OnlineChallenge_RGH224_au10\';
% DataFolder='C:\Users\03138529\Desktop\Piikkio_2023_ResNet50_RGH\';
% OutputFolder='C:\Users\03138529\Desktop\Piikkio_2023_ResNet50_RGH_au\';
AuN=10;
DL=100;

T=readtable([DataFolder 'LettuceMassReference.csv'],"Delimiter",';');
FileName=table2array(T(:,1));
FreshWeightRef=table2array(T(:,2));

FileNameAu=cell(length(FileName)*(AuN+1),1);
FreshWeightRefAu=zeros(length(FileName)*(AuN+1),1);
k=0;

for i=1:length(FileName)
    A=imread([DataFolder FileName{i}]);
    fn=FileName{i}(1:end-4);
    fne=FileName{i}(end-3:end);
    R=A(:,:,1); G=A(:,:,2); H=A(:,:,3);

    k=k+1;
    fna=[fn '_au0' fne];
%     FileNameAu{k}=fna;%OutputFolder 
%     FreshWeightRefAu(k)=FreshWeightRef(i);
    imwrite(A,[OutputFolder fna]);

    for j=1:AuN
        dl=randi(DL)-DL/2;
        R1=R+dl; G1=G+dl;
        RGH1=cat(3,R1,G1,H);
        r=rand;
        if r<0.3
            RGH1=imsharpen(RGH1);
        elseif r>0.7
            RGH1=imgaussfilt(RGH1);
        end
        k=k+1;
        fna=[fn '_au' num2str(j) fne];
%         FileNameAu{k}=fna;%OutputFolder
%         FreshWeightRefAu(k)=FreshWeightRef(i);
        imwrite(RGH1,[OutputFolder fna]);
    end
    disp([num2str(i) ' / ' num2str(length(FileName))]);
end
% FileName=FileNameAu;FreshWeightRef=FreshWeightRefAu;
% writetable(table(FileName,FreshWeightRef),[OutputFolder 'LettuceMassReference.csv'],"Delimiter",';')

%% Changing all file lists 
FileList=dir(DataFolder);
for DayFolderList_i=3:length(FileList)
    RefFileName=FileList(DayFolderList_i).name;
    if contains(RefFileName,'LettuceMassReference') && contains(RefFileName,'.csv')
        if contains(RefFileName,'Train')
            T=readtable([DataFolder RefFileName],"Delimiter",';');
            FileName=table2array(T(:,1));
            FreshWeightRef=table2array(T(:,2));
    
            FileNameAu=cell(length(FileName)*(AuN+1),1);
            FreshWeightRefAu=zeros(length(FileName)*(AuN+1),1);
            k=0;
    
            for i=1:length(FileName)
                fn=FileName{i}(1:end-4);
                fne=FileName{i}(end-3:end);
                for j=0:AuN
                    k=k+1;
                    FileNameAu{k}=[fn '_au' num2str(j) fne];%OutputFolder
                    FreshWeightRefAu(k)=FreshWeightRef(i);
                end
            end
            FileName=FileNameAu;FreshWeightRef=FreshWeightRefAu;
            writetable(table(FileName,FreshWeightRef),[OutputFolder RefFileName],"Delimiter",';')
        elseif contains(RefFileName,'Valid')
            T=readtable([DataFolder RefFileName],"Delimiter",';');
            FileName=table2array(T(:,1));
            FileName=strrep(FileName,'.png','_au0.png');
            FreshWeightRef=table2array(T(:,2));
            writetable(table(FileName,FreshWeightRef),[OutputFolder RefFileName],"Delimiter",';')
        end
    end
end