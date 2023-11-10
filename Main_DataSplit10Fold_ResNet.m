DataFolder='C:\Users\03138529\Desktop\Piikkio_2023_RGH224\';
% DataFolder='C:\Users\03138529\Desktop\WUR_OnlineChallenge_RGH224\';
RefFileName='LettuceMassReference.csv';
T=readtable([DataFolder RefFileName],'Delimiter',';');
FileNameAll=string(table2array(T(:,1)));
FreshWeightRefAll=table2array(T(:,2));

FoldN=10;
N=length(FileNameAll);
AugmentationFactor=1;

%% 10 Fold
if isfile([DataFolder 'RandomNFoldDivision_' num2str(N) '.mat'])
    load([DataFolder 'RandomNFoldDivision_' num2str(N)]);
else
    Fold_Q=RandomNFoldDivision(N,FoldN);
    save([DataFolder 'RandomNFoldDivision_' num2str(N)],'Fold_Q');
end
% RefFileName_base=RefFileName(1:end-4);
RefFileName_base='LettuceMassReference';
for Fold_i=1:FoldN
    q=Fold_Q(Fold_i,:);
    FileName=FileNameAll(~q);
    FreshWeightRef=FreshWeightRefAll(~q);
    FileName=repmat(FileName,AugmentationFactor,1);
    FreshWeightRef=repmat(FreshWeightRef,AugmentationFactor,1);
    writetable(table(FileName,FreshWeightRef),[DataFolder RefFileName_base '_Fold' num2str(Fold_i) '_Train.csv'],'Delimiter',';');
    FileName=FileNameAll(q);
    FreshWeightRef=FreshWeightRefAll(q);
    writetable(table(FileName,FreshWeightRef),[DataFolder RefFileName_base '_Fold' num2str(Fold_i) '_Valid.csv'],'Delimiter',';');
end

%% Time split
DateList={'2023_03_09','2023_04_04','2023_05_16'};
for i=1:length(DateList)
    q=contains(FileNameAll,DateList{i});
    FileName=FileNameAll(q);
    FreshWeightRef=FreshWeightRefAll(q);
    FileName=repmat(FileName,AugmentationFactor,1);
    FreshWeightRef=repmat(FreshWeightRef,AugmentationFactor,1);
    writetable(table(FileName,FreshWeightRef),[DataFolder RefFileName_base '_Exp' num2str(i) '_Train.csv'],'Delimiter',';');
    FileName=FileNameAll(~q);
    FreshWeightRef=FreshWeightRefAll(~q);
    writetable(table(FileName,FreshWeightRef),[DataFolder RefFileName_base '_Exp' num2str(i) '_Valid.csv'],'Delimiter',';');
end
