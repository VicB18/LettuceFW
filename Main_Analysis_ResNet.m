% ConfMartR2=zeros(2);
DataFolder='C:\Users\03138529\Desktop\Lettuce\ResNet50_Results_250\';

%% External validation
TrainDataName={'Pii','TLWUR_Pii','WUR','TLPii_WUR'};
ValidDataName={'Pii','WUR'};
TrainN=length(TrainDataName);
ValidN=length(ValidDataName);
% ConfMartR2=zeros(TrainN,ValidN);
ConfMartRMSE=zeros(TrainN,ValidN);
ConfMartNRMSE=zeros(TrainN,ValidN);

close all;
t=0;
% Draw=1;
for i_train=1:TrainN
    for i_valid=1:ValidN
        t=t+1;
        ResFileName=['Lettuce' '_Train' TrainDataName{i_train} '_Valid' ValidDataName{i_valid} '_Res.csv'];
        if ~isfile([DataFolder ResFileName])
            continue;
        end
        T=readtable([DataFolder ResFileName]);
        FWPredAll=table2array(T(:,2));
        FWRefAll=table2array(T(:,3));
        [rmse,nrmse]=RMSE_N(FWPredAll,FWRefAll);
%         [b,k,R2,RMSE,NRMSE]=LinRegression(FreshWeightEstAll,FreshWeightRefAll,0,Draw);
        figure; hold on; set(gcf,'Position',[-50+i_train*200 700-i_valid*250 160 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;
        axis([0 1 0 1]*max([FWPredAll; FWRefAll]));
%         text(20,0.99*max([FWPredAll; FWRefAll]),['Model ' strrep(TrainDataName{i_train},'_',' ')]);
        text(0.3*max([FWPredAll; FWRefAll]),50,['Val ' strrep(ValidDataName{i_valid},'_',' ')])
        plot(FWPredAll,FWRefAll,'.b');
        plot([min(FWPredAll) max(FWPredAll)],[min(FWPredAll) max(FWPredAll)],'g');
        ConfMartRMSE(i_train,i_valid)=rmse;
        ConfMartNRMSE(i_train,i_valid)=nrmse;
        disp(['Tr ' TrainDataName{i_train} ', val ' ValidDataName{i_valid} ': RMSE(NRMSE)=' num2str(round(rmse,1)) ' (' num2str(round(nrmse*100,1)) '%)']);
    end
end
% text(10,400,'Model Pii');
% text(10,400,'Model PreWUR Pii');
% text(80,100,'Model WUR');
% text(0,250,'Model PrePii WUR');


%% Self validation Pii
Mask='_Pii_Fold'; k=1;
% Mask='_TLWUR_Pii_Fold'; k=2;
FoldN=10;

figure; hold on;
% R2Fold=zeros(FoldN,1);
RMSEFold=zeros(FoldN,1);
NRMSEFold=zeros(FoldN,1);
ma=0; mi=10000;
for Fold_i=1:FoldN
    ResFileName=['Lettuce' Mask num2str(Fold_i) '_Res.csv'];
    if ~isfile([DataFolder ResFileName])
        continue;
    end
    T=readtable([DataFolder ResFileName]);
    FWPredAll=table2array(T(:,2));
    FWRefAll=table2array(T(:,3));
    [RMSEFold(Fold_i),NRMSEFold(Fold_i)]=RMSE_N(FWPredAll,FWRefAll);
%     subplot(3,4,Fold_i); hold on;
    plot(FWPredAll,FWRefAll,'.b');
    ma=max([ma max(FWPredAll)]); mi=min([mi min(FWPredAll)]);
%     plot([min(FreshWeightEstAll) max(FreshWeightEstAll)],[min(FreshWeightEstAll) max(FreshWeightEstAll)],'g');
end
plot([mi ma],[mi ma],'g');
text(90,0.9*ma,'Model Pii');
% text(90,1.05*ma,'Model PreWUR Pii');
text(0.5*ma,90,'Val Pii 10 Fold');
set(gcf,'Position',[50 250 160 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;

RMSEFold=RMSEFold(RMSEFold~=0);
NRMSEFold=NRMSEFold(NRMSEFold~=0);

disp(['Self validation ' Mask])
% disp(['R2mean=' num2str(round(mean(R2Fold),1)) '+-' num2str(round(std(R2Fold),1))])
disp(['RMSEmean=' num2str(round(mean(RMSEFold),2)) '+-' num2str(round(std(RMSEFold),2))])
disp(['NRMSEmean=' num2str(round(mean(NRMSEFold),3)*100) '+-' num2str(round(std(NRMSEFold),3)*100) '%'])

ConfMartRMSE(k,1)=mean(RMSEFold(RMSEFold~=0));
ConfMartNRMSE(k,1)=mean(NRMSEFold(RMSEFold~=0));

%% Self validation WUR
% Mask='_WUR_Fold'; k=3;
Mask='_TLPii_WUR_Fold'; k=4;
FoldN=10;

figure; hold on;
R2Fold=zeros(FoldN,1);
RMSEFold=zeros(FoldN,1);
NRMSEFold=zeros(FoldN,1);
ma=0; mi=10000;
for Fold_i=1:FoldN
    ResFileName=['Lettuce' Mask num2str(Fold_i) '_Res.csv'];
    if ~isfile([DataFolder ResFileName])
        continue;
    end
    T=readtable([DataFolder ResFileName]);
    FWPredAll=table2array(T(:,2));
    FWRefAll=table2array(T(:,3));
    [RMSEFold(Fold_i),NRMSEFold(Fold_i)]=RMSE_N(FWPredAll,FWRefAll);
    plot(FWPredAll,FWRefAll,'.b');
    ma=max([ma max(FWPredAll)]); mi=min([mi min(FWPredAll)]);
%     subplot(3,4,Fold_i);
%     plot(FreshWeightEstAll,FreshWeightRefAll,'.b');
%     plot([min(FreshWeightEstAll) max(FreshWeightEstAll)],[min(FreshWeightEstAll) max(FreshWeightEstAll)],'g');
end
plot([mi ma],[mi ma],'g');
% text(20,0.9*ma,'Model WUR');
text(10,0.99*ma,'Model PrePii WUR');
text(0.2*ma,40,'Val WUR 10 Fold');
set(gcf,'Position',[50 250 160 120]); xlabel('FW measured [g]'); ylabel('FW preficted [g]'); %axis tight;

RMSEFold=RMSEFold(RMSEFold~=0);
NRMSEFold=NRMSEFold(NRMSEFold~=0);

disp(['Self validation ' Mask])
% disp(['R2mean=' num2str(round(mean(R2Fold),1)) '+-' num2str(round(std(R2Fold),1))])
disp(['RMSEmean=' num2str(round(mean(RMSEFold),1)) '+-' num2str(round(std(RMSEFold),1))])
disp(['NRMSEmean=' num2str(round(mean(NRMSEFold),3)*100) '+-' num2str(round(std(NRMSEFold),3)*100) '%'])

ConfMartRMSE(k,2)=mean(RMSEFold(RMSEFold~=0));
ConfMartNRMSE(k,2)=mean(NRMSEFold(RMSEFold~=0));

% %% Confusion matrix
% DrawReciprocalValidationMatrix(ConfMartRMSE',1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('RMSE, [g]');
% DrawReciprocalValidationMatrix(ConfMartNRMSE'*100,1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('NRMSE, [%]');

%% Pii Exp1, Exp2, Exp3
TrainDataName={'Pii','Pii_Exp1','Pii_Exp2','Pii_Exp3'};
ValidDataName={'Pii','Pii_Exp1','Pii_Exp2','Pii_Exp3'};
TrainN=length(TrainDataName);
ValidN=length(ValidDataName);
% ConfMartR2=zeros(TrainN,ValidN);
ConfMartRMSE=zeros(TrainN,ValidN);
ConfMartNRMSE=zeros(TrainN,ValidN);

% close all;
t=0;
for i_train=1:TrainN
    for i_valid=1:ValidN
        t=t+1;
        ResFileName=['Lettuce' '_Train' TrainDataName{i_train} '_Valid' ValidDataName{i_valid} '_Res.csv'];
        if ~isfile([DataFolder ResFileName])
            continue;
        end
        T=readtable([DataFolder ResFileName]);
        FWPredAll=table2array(T(:,2));
        FWRefAll=table2array(T(:,3));
        [rmse,nrmse]=RMSE_N(FWPredAll,FWRefAll);
%         [b,k,R2,RMSE,NRMSE]=LinRegression(FreshWeightEstAll,FreshWeightRefAll,0,Draw);
        subplot(TrainN,ValidN,t); hold on;
        plot([min(FWPredAll) max(FWPredAll)],[min(FWPredAll) max(FWPredAll)],'g');
        plot(FWPredAll,FWRefAll,'.b');
%         ConfMartR2(i,j)=R2;
        ConfMartRMSE(i_train,i_valid)=rmse;
        ConfMartNRMSE(i_train,i_valid)=nrmse;
        disp(['Tr ' TrainDataName{i_train} ', val ' ValidDataName{i_valid} ': RMSE(NRMSE)=' num2str(round(rmse,1)) ' (' num2str(round(nrmse*100,1)) '%)']);
    end
end

% DrawReciprocalValidationMatrix(ConfMartRMSE',1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('RMSE, [g]');
% DrawReciprocalValidationMatrix(ConfMartNRMSE'*100,1:TrainN,strrep(ValidDataName,'_',' '),strrep(TrainDataName,'_',' '));
% xlabel('Validation'); ylabel('Training'); title('NRMSE, [%]');

%% Robustness
disp('  ');
disp('ResNet Robustness Ratio Pii');
disp(['RMSE Ratio ' num2str(ConfMartRMSE(3,1)/ConfMartRMSE(1,1))]);
disp(['NRMSE Ratio ' num2str(ConfMartNRMSE(3,1)/ConfMartNRMSE(1,1))]);
disp('ResNet Robustness Ratio WUR');
disp(['RMSE Ratio ' num2str(ConfMartRMSE(1,2)/ConfMartRMSE(3,2))]);
disp(['NRMSE Ratio ' num2str(ConfMartNRMSE(1,2)/ConfMartNRMSE(3,2))]);
