function [rmse,nrmse]=RMSE_N(y,y_pred)
rmse=sqrt(mean((y_pred-y).^2));
nrmse=sqrt(mean((y_pred-y).^2))./sqrt(mean(y.^2));