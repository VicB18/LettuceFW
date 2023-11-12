function L=ReadExpFileList(DataFolder,Masks)
L=struct([]);
LN=0;
DayFolderList=dir(DataFolder);
% ReferenceFileName='LettuceMassReference.csv';
% T=readtable([DataFolder ReferenceFileName]);
% DateRef=string(table2array(T(:,1)));
% RefFreshWeight=table2array(T(:,3));
% PlantNoRef=table2array(T(:,2));
% CondRef=table2array(T(:,4));
% CondList=unique(CondRef);
DateRef=[];
RefFreshWeight=[];
PlantNoRef=[];

for DayFolderList_i=3:length(DayFolderList)
    RefFileName=DayFolderList(DayFolderList_i).name;
    f=isempty(Masks);
    for i=1:length(Masks)
        if contains(RefFileName,Masks{i})
            f=true;
        end
    end
    if contains(RefFileName,'LettuceMassReference_') && contains(RefFileName,'.csv') && f
        disp(RefFileName);
        T=readtable([DataFolder RefFileName]);
        PlantNoRef=[PlantNoRef; table2array(T(:,1))];
        RefFreshWeight=[RefFreshWeight; table2array(T(:,2))];
        DateRef=[DateRef; string(repmat(RefFileName(22:31),length(table2array(T(:,1))),1))];
    end
end

for DayFolderList_i=3:length(DayFolderList)
    DayFolderName=DayFolderList(DayFolderList_i).name;
%     if contains(PlantFolderName,'LettuceMassReference_') && contains(PlantFolderName,'.csv')
%         T=readtable([DataFolder ReferenceFileName]);
%         DateRef=string(table2array(T(:,1)));
%         RefFreshWeight=table2array(T(:,3));
%         PlantNoRef=table2array(T(:,2));
%     end
    if ~isfolder([DataFolder DayFolderName])
        continue;
    end
    if ~contains(DayFolderName,'2023_')
        continue;
    end
    FileList=dir([DataFolder DayFolderName]);
    Date=DayFolderName(1:10);
    T=readtable([DataFolder 'CameraCalibration.csv']);
    k=find(string(table2array(T(:,1)))==Date);
    Tr=reshape(table2array(T(k,2:end)),6,4)';
    
    for File_i=3:length(FileList)
        PlantFolderName=FileList(File_i).name;
        if ~isfolder([DataFolder DayFolderName '\' PlantFolderName])
            continue;
        end
        if contains(PlantFolderName,'calibration')
            continue;
        end
        PlantNo=str2num(PlantFolderName);
        k=find(strcmp(Date,DateRef) & floor(PlantNo)==PlantNoRef);
        if isempty(k)
            continue;
        end
        if RefFreshWeight(k)==0 || isnan(RefFreshWeight(k))
            continue;
        end        
        PlantFileList=dir([DataFolder DayFolderName '\' PlantFolderName]);
        LN=LN+1;
        
        fi=0;
        L(LN).FileName=[];
        for Cam_i=3:length(PlantFileList)
            FileName=PlantFileList(Cam_i).name;
            if contains(FileName,'.ply') && contains(FileName,'Cam') && length(FileName)<=9
                fi=fi+1;
                L(LN).FileName{fi}=FileName;
            end
        end
        if fi~=0
            L(LN).Path=[DataFolder DayFolderName '\' PlantFolderName '\'];
            L(LN).TransformationQ=Tr;
            L(LN).Date=Date;
            L(LN).PlantNo=PlantFolderName;
            L(LN).RefFreshWeight=RefFreshWeight(k);
            L(LN).CameraN=fi;
            L(LN).Variety='Katusa';
        else
            LN=LN-1;
        end
    end
end

