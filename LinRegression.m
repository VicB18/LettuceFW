function [b,k,R2,RMSE,NRMSE]=LinRegression(x,y,Ksigma,Draw) %en.wikipedia.org/wiki/Simple_linear_regression
q=~isnan(x) & ~isnan(y);
x=x(q); y=y(q);
xm=mean(x);
ym=mean(y);
Cov=mean(x.*y)-xm*ym;
Var=mean(x.^2)-mean(x)^2;
k=Cov/Var;
b=ym-k*xm;
R2=(Cov/sqrt(Var*(mean(y.^2)-mean(y)^2)))^2;
y_pred=b+k*x;
% SEE=sqrt(sum((y-b-k*x).^2)/(length(x)-2));
RMSE=sqrt(mean((y_pred-y).^2));
NRMSE=sqrt(mean((y_pred-y).^2))./sqrt(mean(y.^2));
if Draw>0
    hold on;
    plot(x,y,'.');
    plot([min(x) max(x)],b+k*[min(x) max(x)]);
    if Draw>1
        tx=min(x)+(max(x)-min(x))*0.1;
        tdy=(max(y)-min(y))/20*2;
        ty=max(y)-tdy*0.1;
        text(tx,ty-0*tdy,['y = ' num2str(k) 'x + ' num2str(b)]);
        text(tx,ty-1*tdy,['R^2 = ' num2str(R2)]);
        text(tx,ty-2*tdy,['RMSE = ' num2str(RMSE)]);
        text(tx,ty-3*tdy,['NRMSE = ' num2str(NRMSE*100) '%']);
    end
%     disp(['Line equation: y=' num2str(k) 'x+' num2str(b) ', R2=' num2str(R2) ', SEE=' num2str(SEE)])
end

if Ksigma~=0
    e=abs(x*k+b-y);
    s=std(e);
    q=e<Ksigma*s;
    x=x(q);
    y=y(q);
    if isempty(x)
        k=0;
        b=0;
        return;
    end
    xm=mean(x);
    ym=mean(y);
    Cov=mean(x.*y)-xm*ym;
    Var=mean(x.^2)-mean(x)^2;
    k=Cov/Var;
    b=ym-k*xm;
    R2=(Cov/sqrt(Var*(mean(y.^2)-mean(y)^2)))^2;
    y_pred=b+k*x;
    RMSE=sqrt(mean((y_pred-y).^2));
    NRMSE=sqrt(mean((y_pred-y).^2))./sqrt(mean(y.^2));
%     SEE=sqrt(sum((y-b-k*x).^2)/(length(x)-2));
    if Draw
        plot([min(x) max(x)],b+k*[min(x) max(x)]);
%         disp(['Line equation: y=' num2str(k) 'x+' num2str(b) ', R2=' num2str(R2) ', SEE=' num2str(SEE)])
% %         tx=min(x)+(max(x)-min(x))*0.1;
% %         tdy=(max(y)-min(y))/20;
% %         ty=max(y)-tdy*0.1;
        if Draw>1
            text(tx,ty-0*tdy,['y = ' num2str(k) 'x + ' num2str(b)]);
            text(tx,ty-1*tdy,['R^2 = ' num2str(R2)]);
            text(tx,ty-2*tdy,['RMSE = ' num2str(RMSE)]);
            text(tx,ty-3*tdy,['NRMSE = ' num2str(NRMSE*100) '%']);
        end
    end
end

