FoldN=10;
Draw=0;
V_ind=1;%Vacuum package
RegressionModelOutlyerFilter=3;

DataFolder='F:\Lettuce\Piikkio_2023\';
CalculatedFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
T=readtable(CalculatedFileName);
DatePii=string(table2array(T(:,1)));
FWRefPii=table2array(T(:,3));
VolumeCalcPii=table2array(T(:,3+V_ind))/1000;

DataFolder='F:\Lettuce\WUR_OnlineChallenge\';
CalculatedFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
T=readtable(CalculatedFileName);
FWRefWUR=table2array(T(:,3));
VolumeCalcWUR=table2array(T(:,3+V_ind))/1000;

TrainDataName={'Pii','WUR','WUR and Pii'};
ValidDataName={'Pii','WUR'};
TrainN=length(TrainDataName);
ValidN=length(ValidDataName);
ConfMartRMSE=zeros(TrainN,ValidN);
ConfMartNRMSE=zeros(TrainN,ValidN);

FWRef_All=[FWRefPii; FWRefWUR];
VolumeCalcAll=[VolumeCalcPii; VolumeCalcWUR];

Train_Q=[
    [true(1,length(DatePii)) false(1,length(VolumeCalcWUR))];
    [false(1,length(DatePii)) true(1,length(VolumeCalcWUR))];
    [true(1,length(DatePii)) true(1,length(VolumeCalcWUR))]
];
Valid_Q=[
    [true(1,length(DatePii)) false(1,length(VolumeCalcWUR))];
    [false(1,length(DatePii)) true(1,length(VolumeCalcWUR))];
];

%% External validation
t=0;
close all;
for i_train=1:TrainN
    q=Train_Q(i_train,:);
    [b,k,r2,rmse,nrmse]=LinRegression(VolumeCalcAll(q),FWRef_All(q),RegressionModelOutlyerFilter,0);

    for i_valid=1:ValidN
        t=t+1;
        q=Valid_Q(i_valid,:);
        VolumePred=VolumeCalcAll(q);
        FWRef=FWRef_All(q);
        FWPred=VolumePred*k+b;
        if i_valid==i_train
            continue;
        end
%             subplot(TrainN,ValidN,t); hold on;
        figure; hold on; set(gcf,'Position',[-150+i_train*200 700-i_valid*250 180 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;
        axis([0 1 0 1]*max([FWRef; FWPred]));
        text(20,0.85*max([FWRef; FWPred]),['Model ' strrep(TrainDataName{i_train},'_',' ')]);
        text(0.4*max([FWRef; FWPred]),50,['Val ' strrep(ValidDataName{i_valid},'_',' ')])
        plot([min(FWRef_All) max(FWRef_All)],[min(FWRef_All) max(FWRef_All)],'g');
        plot(FWRef,FWPred,'.b');
        [rmse,nrmse]=RMSE_N(FWRef,FWPred);
        ConfMartRMSE(i_train,i_valid)=rmse;
        ConfMartNRMSE(i_train,i_valid)=nrmse*100;
        disp(['Tr ' TrainDataName{i_train} ', val ' ValidDataName{i_valid} ': RMSE=' num2str(round(rmse,2)) ', NRMSE=' num2str(round(nrmse*100,2))]);
    end
end
% xlabel('Reference FW [g]'); ylabel('Predicted FW [g]');
% title('Volume based')
%% Self validation Pii
DataFolder='F:\Lettuce\Piikkio_2023\';
N=length(VolumeCalcPii);
if isfile([DataFolder 'RandomNFoldDivision_' num2str(N) '.mat'])
    load([DataFolder 'RandomNFoldDivision_' num2str(N)]);
else
    Fold_Q=RandomNFoldDivision(N,FoldN);
    save([DataFolder 'RandomNFoldDivision_' num2str(N)],'Fold_Q');
end

[RR2,RMSE,NRMSE]=NFoldValidation(VolumeCalcPii,FWRefPii,FoldN,Fold_Q,RegressionModelOutlyerFilter);
% title('Self validation Pii');
text(70,250,'Model Pii');
text(120,90,'Val Pii Fold 10');
set(gcf,'Position',[50 250 160 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;

% disp(' ');
% disp(['R2 = ' num2str(mean(RR2)) ' +- ' num2str(std(RR2))])
% disp(['RMSE = ' num2str(mean(RMSE)) ' +- ' num2str(std(RMSE))])
% disp(['NRMSE = ' num2str(mean(NRMSE)*100) ' +- ' num2str(std(NRMSE)*100) '%'])
ConfMartRMSE(1,1)=mean(RMSE);
ConfMartNRMSE(1,1)=mean(NRMSE)*100;

%% Self validation WUR
DataFolder='F:\Lettuce\WUR_OnlineChallenge\';
N=length(VolumeCalcWUR);
if isfile([DataFolder 'RandomNFoldDivision_' num2str(N) '.mat'])
    load([DataFolder 'RandomNFoldDivision_' num2str(N)]);
else
    Fold_Q=RandomNFoldDivision(N,FoldN);
    save([DataFolder 'RandomNFoldDivision_' num2str(N)],'Fold_Q');
end

[RR2,RMSE,NRMSE]=NFoldValidation(VolumeCalcWUR,FWRefWUR,FoldN,Fold_Q,RegressionModelOutlyerFilter);
% title('Self validation WUR');
text(20,370,'Model WUR');
text(80,40,'Val WUR Fold 10');
set(gcf,'Position',[150 200 160 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;

% disp(' ');
% disp(['R2 = ' num2str(mean(RR2)) ' +- ' num2str(std(RR2))])
% disp(['RMSE = ' num2str(mean(RMSE)) ' +- ' num2str(std(RMSE))])
% disp(['NRMSE = ' num2str(mean(NRMSE)*100) ' +- ' num2str(std(NRMSE)*100) '%'])
ConfMartRMSE(2,2)=mean(RMSE);
ConfMartNRMSE(2,2)=mean(NRMSE)*100;

%% Robustness
disp('  ');
disp('Volume Robustness Ratio Pii');
disp(['RMSE Ratio ' num2str(ConfMartRMSE(2,1)/ConfMartRMSE(1,1))]);
disp(['NRMSE Ratio ' num2str(ConfMartNRMSE(2,1)/ConfMartNRMSE(1,1))]);
disp('Volume Robustness Ratio WUR');
disp(['RMSE Ratio ' num2str(ConfMartRMSE(1,2)/ConfMartRMSE(2,2))]);
disp(['NRMSE Ratio ' num2str(ConfMartNRMSE(1,2)/ConfMartNRMSE(2,2))]);

%% Confusion matrix
% DrawReciprocalValidationMatrix(ConfMartRMSE',1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('RMSE [g]');
% DrawReciprocalValidationMatrix(ConfMartNRMSE',1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('NRMSE [%]');

%% Volume methods
close all;
DataFolder='F:\Lettuce\Piikkio_2023\';
CalculatedFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
TPii=readtable(CalculatedFileName);
FWRefPii=table2array(TPii(:,3));

DataFolder='F:\Lettuce\WUR_OnlineChallenge\';
CalculatedFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
TWUR=readtable(CalculatedFileName);
FWRefWUR=table2array(TWUR(:,3));

Vmethod={'Vacuum','Alpha','Ball'};
% TextXPii_Top=1; TextYPii_Top=500;
% TextXPii_All=7; TextYPii_All=200;
% TextdY=50;

for V_ind=1:length(Vmethod)
    figure; hold on;
    VolumeCalcPii=table2array(TPii(:,3+V_ind))/1000;
    VolumeCalcWUR=table2array(TWUR(:,3+V_ind))/1000;
    [bPii,kPii,R2Pii,RMSEPii,NRMSEPii]=LinRegression(VolumeCalcPii,FWRefPii,RegressionModelOutlyerFilter,0);
    plot(VolumeCalcPii,FWRefPii,'.','Color',[0 0 1]);

    [bWUR,kWUR,R2WUR,RMSEWUR,NRMSEWUR]=LinRegression(VolumeCalcWUR,FWRefWUR,RegressionModelOutlyerFilter,0);
    plot(VolumeCalcWUR,FWRefWUR,'.','Color',[1 0 0]);

    plot([min(VolumeCalcPii) max(VolumeCalcPii)],bPii+kPii*[min(VolumeCalcPii) max(VolumeCalcPii)],'Color',[0 0.4 1]);
    plot([min(VolumeCalcWUR) max(VolumeCalcWUR)],bWUR+kWUR*[min(VolumeCalcWUR) max(VolumeCalcWUR)],'Color',[1 0.4 0]);

    disp([Vmethod{V_ind} ' Pii' ', RMSE=' num2str(round(RMSEPii,2)) ', NRMSE=' num2str(round(NRMSEPii*100,2))]);
    disp(['R2Pii=' num2str(round(R2Pii,2)) ', y=' num2str(round(kPii,3)) 'x+' num2str(round(bPii,2))]);
    disp([Vmethod{V_ind} ' WUR' ', RMSE=' num2str(round(RMSEWUR,2)) ', NRMSE=' num2str(round(NRMSEWUR*100,2))]);
    disp(['R2Pii=' num2str(round(R2WUR,2)) ', y=' num2str(round(kWUR,3)) 'x+' num2str(round(bWUR,2))]);

    xlabel('Calculated volume [liter]'); ylabel('Reference FW [g]');
%     title(Vmethod{V_ind});
%     set(gcf,'Position',[50+V_ind*50 350-V_ind*50 300 200]);
    set(gcf,'Position',[-50+V_ind*150 350-V_ind*50 160 120]);

%     text(TextXPii,TextYPii-0*TextdY,['y = ' num2str(kPii,3) 'x + ' num2str(bPii,3)],'Color',[0 0 1]);
%     text(TextXPii_Top,TextYPii_Top-1*TextdY,['R^2 = ' num2str(R2Pii,2)],'Color',[0 0 1]);
%     text(TextXPii,TextYPii-2*TextdY,['RMSE = ' num2str(RMSEPii,3)],'Color',[0 0 1]);
%     text(TextXPii,TextYPii-3*TextdY,['NRMSE = ' num2str(NRMSEPii*100,3) '%'],'Color',[0 0 1]);
%     text(TextXWUR,TextYWUR-0*TextdY,['y = ' num2str(kWUR,3) 'x + ' num2str(bWUR,3)],'Color',[1 0 0]);
%     text(TextXPii_All,TextYPii_All-1*TextdY,['R^2 = ' num2str(R2WUR,2)],'Color',[1 0 0]);
%     text(TextXWUR,TextYWUR-2*TextdY,['RMSE = ' num2str(RMSEWUR,3)],'Color',[1 0 0]);
%     text(TextXWUR,TextYWUR-3*TextdY,['NRMSE = ' num2str(NRMSEWUR*100,3) '%'],'Color',[1 0 0]);
end

figure; hold on; plot(1,1,'.b'); plot(1,1,'.r');
legend({'Pii','WUR'},'NumColumns',2)
set(gcf,'Position',[50 400 200 50]);
figure; hold on; plot(1,1,'.b'); plot(1,1,'.r');
legend('Pii','WUR')
set(gcf,'Position',[150 400 100 200]);

%% Pii Exp 1, Exp 2, Exp 3
TrainDataName={'Pii','Pii_Exp1','Pii_Exp2','Pii_Exp3'};
ValidDataName={'Pii','Pii_Exp1','Pii_Exp2','Pii_Exp3'};
TrainN=length(TrainDataName);
ValidN=length(ValidDataName);
ConfMartRMSE=zeros(TrainN,ValidN);
ConfMartNRMSE=zeros(TrainN,ValidN);

FWRef_All=[FWRefPii; FWRefWUR];
VolumeCalcAll=[VolumeCalcPii; VolumeCalcWUR];

Train_Q=[
    [true(1,length(DatePii)) false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_03_09' false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_04_04' false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_05_16' false(1,length(VolumeCalcWUR))];
];
Valid_Q=[
    [true(1,length(DatePii)) false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_03_09' false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_04_04' false(1,length(VolumeCalcWUR))];
    [DatePii'=='2023_05_16' false(1,length(VolumeCalcWUR))];
];
t=0;
% close all;
% figure;
for i_train=1:TrainN
    q=Train_Q(i_train,:);
    [b,k,r2,rmse,nrmse]=LinRegression(VolumeCalcAll(q),FWRef_All(q),RegressionModelOutlyerFilter,0);

    for i_valid=1:ValidN
        t=t+1;
        q=Valid_Q(i_valid,:);
        VolumePred=VolumeCalcAll(q);
        FWRef=FWRef_All(q);
        FWPred=VolumePred*k+b;
        if i_valid~=i_train
% %             subplot(TrainN,ValidN,t); hold on;
%             figure; hold on; set(gcf,'Position',[50+i_valid*200 720-i_train*200 180 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;
%             axis([0 1 0 1]*max([FWRef; FWPred]));
%             text(20,0.8*max([FWRef; FWPred]),['Tr ' strrep(TrainDataName{i_train},'_',' ')]);
%             text(0.4*max([FWRef; FWPred]),50,['Val ' strrep(ValidDataName{i_valid},'_',' ')])
%             plot([min(FWRefAll) max(FWRefAll)],[min(FWRefAll) max(FWRefAll)],'color',[0 1 1]);
%             plot(FWRef,FWPred,'.b');
            [rmse,nrmse]=RMSE_N(FWRef,FWPred);
            ConfMartRMSE(i_train,i_valid)=rmse;
            ConfMartNRMSE(i_train,i_valid)=nrmse*100;
            disp(['Tr ' TrainDataName{i_train} ', val ' ValidDataName{i_valid} ': RMSE(NRMSE)=' num2str(round(rmse,1)) ' (' num2str(round(nrmse*100,1)) '%)']);
        end
    end
end


%% Top and all views comparison
DataFolder='F:\Lettuce\Piikkio_2023\';
CalculatedFileName=[DataFolder 'CalculatedPlantVolume_All.csv'];
TPii_All=readtable(CalculatedFileName);
FWRefPii_All=table2array(TPii_All(:,3));
Date_All=table2array(TPii_All(:,1));
PlantNo_All=table2array(TPii_All(:,2));

CalculatedFileName=[DataFolder 'CalculatedPlantVolume_Top.csv'];
TPii_Top=readtable(CalculatedFileName);
Date_Top=table2array(TPii_Top(:,1));
PlantNo_Top=table2array(TPii_Top(:,2));

q=false(length(PlantNo_Top),1);
for i=1:length(PlantNo_All)
    k=find(strcmp(Date_All,Date_Top{i}) & PlantNo_All==PlantNo_Top(i));
    if ~isempty(k)
        q(k)=true;
    end
end
FWRefPii_Top=table2array(TPii_Top(:,3));

Vmethod={'Vacuum','Alpha','Ball'};
TextXPii_Top=0; TextYPii_Top=300; TextCPii_Top=[0 1 0];
TextXPii_All=3; TextYPii_All=150; TextCPii_All=[0.5 0 1];
TextdY=25;
close all;

for V_ind=1:length(Vmethod)
    figure; hold on;
    VolumeCalcPii_Top=table2array(TPii_Top(:,3+V_ind))/1000;
    VolumeCalcPii_All=table2array(TPii_All(:,3+V_ind))/1000;

    [bPii_Top,kPii_Top,R2Pii_Top,RMSEPii_Top,NRMSEPii_Top]=LinRegression(VolumeCalcPii_Top,FWRefPii_Top,RegressionModelOutlyerFilter,0);
    plot(VolumeCalcPii_Top,FWRefPii_Top,'.','Color',TextCPii_Top);

    [bPii_All,kPii_All,R2Pii_All,RMSEPii_All,NRMSEPii_All]=LinRegression(VolumeCalcPii_All,FWRefPii_All,RegressionModelOutlyerFilter,0);
    plot(VolumeCalcPii_All,FWRefPii_All,'.','Color',TextCPii_All);

    plot([min(VolumeCalcPii_Top) max(VolumeCalcPii_Top)],bPii_Top+kPii_Top*[min(VolumeCalcPii_Top) max(VolumeCalcPii_Top)],'Color',TextCPii_Top*0.5);
    plot([min(VolumeCalcPii_Top) max(VolumeCalcPii_Top)],bPii_All+kPii_All*[min(VolumeCalcPii_Top) max(VolumeCalcPii_Top)],'Color',TextCPii_All*0.5);

    disp([Vmethod{V_ind} ' Pii_Top' ', RMSE=' num2str(round(RMSEPii_Top,1)) ', NRMSE=' num2str(round(NRMSEPii_Top*100,1))]);
    disp(['R2Pii=' num2str(round(R2Pii_Top,2)) ', y=' num2str(round(kPii_Top,1)) 'V+' num2str(round(bPii_Top,1))]);
    disp([Vmethod{V_ind} ' Pii_All' ', RMSE=' num2str(round(RMSEPii_All,1)) ', NRMSE=' num2str(round(NRMSEPii_All*100,1))]);
    disp(['R2Pii=' num2str(round(R2Pii_All,2)) ', y=' num2str(round(kPii_All,1)) 'V+' num2str(round(bPii_All,1))]);

    xlabel('Calculated volume [liter]'); ylabel('Reference FW [g]');
%     title(Vmethod{V_ind});
    set(gcf,'Position',[-50+V_ind*150 350-V_ind*50 160 120]);

%     text(TextXPii_Top,TextYPii_Top-0*TextdY,['y = ' num2str(kPii_Top,3) 'x + ' num2str(bPii_Top,3)],'Color',TextCPii_Top*0.5);
%     text(min(VolumeCalcPii_Top),TextYPii_Top-1*TextdY,['R^2 = ' num2str(R2Pii_Top,2)],'Color',TextCPii_Top*0.5);
%     text(TextXPii_Top,TextYPii_Top-2*TextdY,['RMSE = ' num2str(RMSEPii_Top,3)],'Color',TextCPii_Top*0.5);
%     text(TextXPii_Top,TextYPii_Top-3*TextdY,['NRMSE = ' num2str(NRMSEPii_Top*100,3) '%'],'Color',TextCPii_Top*0.5);
%     text(TextXPii_All,TextYPii_All-0*TextdY,['y = ' num2str(kPii_All,3) 'x + ' num2str(bPii_All,3)],'Color',TextCPii_All*0.5);
%     text(max(VolumeCalcPii_All)/2,TextYPii_All-1*TextdY,['R^2 = ' num2str(R2Pii_All,2)],'Color',TextCPii_All*0.5);
%     text(TextXPii_All,TextYPii_All-2*TextdY,['RMSE = ' num2str(RMSEPii_All,3)],'Color',TextCPii_All*0.5);
%     text(TextXPii_All,TextYPii_All-3*TextdY,['NRMSE = ' num2str(NRMSEPii_All*100,3) '%'],'Color',TextCPii_All*0.5);
end
% legend('Pii top view','Pii all views')
figure; hold on; plot(1,1,'.','Color',TextCPii_Top); plot(1,1,'.','Color',TextCPii_All);
legend({'Pii top view','Pii all views'},'NumColumns',2)
set(gcf,'Position',[50 200 300 50]);
figure; hold on; plot(1,1,'.','Color',TextCPii_Top); plot(1,1,'.','Color',TextCPii_All);
legend('Pii top view','Pii all views')
set(gcf,'Position',[150 50 150 300]);

function [RR2,RMSE,NRMSE]=NFoldValidation(x,y,FoldN,Fold_Q,RegressionModelOutlyerFilter)
RR2=zeros(FoldN,1); RMSE=RR2; NRMSE=RR2;
% BB=zeros(FoldN,1); KK=zeros(FoldN,1);
figure;
for i=1:FoldN
    q_i=~Fold_Q(i,:);
    [b,k,RR2(i),rmse,nrmse]=LinRegression(x(q_i),y(q_i),RegressionModelOutlyerFilter,0);
%     BB(i)=b; KK(i)=k;

    xq=x(Fold_Q(i,:),:);
    yq=y(Fold_Q(i,:));
    y_pred=xq*k+b;
%     subplot(4,3,i);
    hold on;
    plot([min(y) max(y)],[min(y) max(y)],'g');
    plot(yq,y_pred,'.b');
    [RMSE(i),NRMSE(i)]=RMSE_N(yq,y_pred);
end
disp(' ');
disp(['R2 = ' num2str(mean(RR2)) ' +- ' num2str(std(RR2))])
disp(['RMSE = ' num2str(mean(RMSE)) ' +- ' num2str(std(RMSE))])
disp(['NRMSE = ' num2str(mean(NRMSE)*100) ' +- ' num2str(std(NRMSE)*100) '%'])

end
