function [PacX,PacY,Stats]=PointCloudToSurface_VacuumPackage(x,y,z,CX,CY,CZ,Dmin)
% Dmin=1*(max(x)-min(x))/PacN;
MaxGap=5*Dmin;
NeibN=6;
FilterN=3;
ddmin=zeros(FilterN,1);
Draw=0;
% if Draw
% %     figure;
%     cla; hold on; axis equal;
%     plot3(x,y,z,'.');
% %     plot3(CX,CY,CZ,'*');
% end
R=sqrt((x-CX).^2+(y-CY).^2+(z-CZ).^2);
Rmax=max(R);

PackagePointX=[];
PackagePointY=[];
PackagePointZ=[];

fn=ceil(Rmax*pi/Dmin);
df=linspace(pi/2,-pi/2,fn);
for i=1:length(df)
    r=Rmax*cos(df(i));
    tn=ceil(r*2*pi/Dmin);
    dt=linspace(0,2*pi,tn);
    x=r*cos(dt);
    y=r*sin(dt);
    z=Rmax*sin(df(i))*zeros(length(dt),1);
    PackagePointX=[PackagePointX; x];
    PackagePointY=[PackagePointY; y];
    PackagePointZ=[PackagePointZ; z];
end

plot3(PackagePointX,PackagePointY,PackagePointZ,'o');

PacN=length(PackagePointX);

PointNeib=zeros(PacN,NeibN);
for i=1:PacN
    d=(PackagePointX(i)-PackagePointX).^2+(PackagePointY(i)-PackagePointY).^2+(PackagePointZ(i)-PackagePointZ).^2;
    d(i)=Rmax;
    for j=1:NeibN
        [a,k]=min(d);
        PointNeib(i,j)=k;
        d(k)=Rmax;
    end
end


a=atan2(y-CY,x-CX);

% Stats.HoleN=0;
% Stats.HoleSize=[];

for j=1:FilterN
    [rmax,krmax]=max(R);
    R(krmax)=0;
%     plot(x(krmax),y(krmax),'ro');
end
% [rmax,krmax]=max(R);
for j=1:FilterN
    [amin,kamin]=min(a);
    a(kamin)=7;
%     plot(x(kamin),y(kamin),'bo');
end
a=atan2(y-CY,x-CX);
% [amin,kamin]=min(a);
for j=1:FilterN
    [amax,kamax]=max(a);
    a(kamax)=-7;
%     plot(x(kamax),y(kamax),'go');
end
% [amax,kamax]=max(a);

PacA=linspace(amin,amax,PacN);

FixedPoint=zeros(PacN,1);
FixedPoint(1)=1;
PacX(1)=x(kamin); PacY(1)=y(kamin);
FixedPoint(PacN)=1;
PacX(PacN)=x(kamax); PacY(PacN)=y(kamax);
k=find(PacA>a(krmax),1);
if k-1<10 || PacN-k<10
    k=round(PacN/2);
    [w,krmax]=min(abs(PacA(k)-a));
end
FixedPoint(k)=1;
PacX(k)=x(krmax); PacY(k)=y(krmax);

k1=1; k2=k;
cx=(PacX(k1)+PacX(k2))/2;
cy=(PacY(k1)+PacY(k2))/2;
r1=sqrt((PacX(k2)-PacX(k1)).^2+(PacY(k2)-PacY(k1)).^2)/2;
a1=atan2(PacY(k2)-PacY(k1),PacX(k2)-PacX(k1));
PacX(k1:k2)=cx+r1*cos(linspace(a1-pi,a1,k2-k1+1));
PacY(k1:k2)=cy+r1*sin(linspace(a1-pi,a1,k2-k1+1));
k1=k; k2=PacN;
cx=(PacX(k1)+PacX(k2))/2;
cy=(PacY(k1)+PacY(k2))/2;
r1=sqrt((PacX(k2)-PacX(k1)).^2+(PacY(k2)-PacY(k1)).^2)/2;
a1=atan2(PacY(k2)-PacY(k1),PacX(k2)-PacX(k1));
PacX(k1:k2)=cx+r1*cos(linspace(a1-pi,a1,k2-k1+1));
PacY(k1:k2)=cy+r1*sin(linspace(a1-pi,a1,k2-k1+1));
% if Draw
%     plot(PacX(1),PacY(1),'ro');
%     plot(PacX(PacN),PacY(PacN),'ro');
%     plot(PacX(k),PacY(k),'ro');
%     plot(PacX,PacY,'r.');
% end
    
FixedPointN=3;
while FixedPointN<PacN
    k1=find(FixedPoint==0,1)-1;
    k2=find(FixedPoint(k1+1:end)==1,1)+k1;
%     cx=(PacX(k1)+PacX(k2))/2;
%     cy=(PacY(k1)+PacY(k2))/2;
%     r1=sqrt((PacX(k2)-PacX(k1)).^2+(PacY(k2)-PacY(k1)).^2)/2;
    a1=atan2(PacY(k2)-PacY(k1),PacX(k2)-PacX(k1));
    NewFixedPoint=0;
    gmax=MaxGap/2;
    while NewFixedPoint==0 && gmax<MaxGap && min(PacY(k1:k2))>=0
        PacX(k1:k2)=PacX(k1:k2)+Dmin*sin(linspace(0,pi,k2-k1+1))*cos(a1+pi/2);
        PacY(k1:k2)=PacY(k1:k2)+Dmin*sin(linspace(0,pi,k2-k1+1))*sin(a1+pi/2);
%         if Draw
%             plot(PacX,PacY,'b.');
%         end
    
        for i=(k1+1):(k2-1)
            d=sqrt((PacX(i)-x).^2+(PacY(i)-y).^2);
            
            g=max(d);
            for j=1:FilterN
                [ddmin(j),s]=min(d);
                d(s)=g;
            end
%             [dmin,s]=min(d);
%             if dmin<Dmin
            if mean(ddmin)<Dmin
                FixedPoint(i)=1;
                FixedPointN=FixedPointN+1;
                NewFixedPoint=1;
%                 if Draw
%                     plot(PacX(i),PacY(i),'ro');
%                 end
            end
        end

        g=sqrt((PacX(k1:k2-1)-PacX(k1+1:k2)).^2+(PacY(k1:k2-1)-PacY(k1+1:k2)).^2);
        gmax=max(g);
    end
    if gmax>=MaxGap || min(PacY(k1:k2))<0
        FixedPoint(k1:k2)=1;
        FixedPointN=FixedPointN+k2-k1-1;
%         NewFixedPoint=1;
%         plot(PacX(k1:k2),PacY(k1:k2),'go');
        Stats.HoleN=Stats.HoleN+1;
        Stats.HoleSize(Stats.HoleN)=sqrt((PacX(k1)-PacX(k2))^2+(PacY(k1)-PacY(k2))^2);

    end
end
% figure; hold on; plot(dx,r,'b');
r=sqrt((PacX-CX).^2+(PacY-CY).^2);
dx=cumsum([0 sqrt((PacX(1:PacN-1)-PacX(2:PacN)).^2+(PacY(1:PacN-1)-PacY(2:PacN)).^2)]);
% plot(dx,r,'r.');
r=FilterMovingAverage(r,5);
% plot(dx,r,'b');
[Amp,Len]=WaveCount(dx,r,0.001);
Stats.WaveN=length(Amp);
Stats.WaveAmp=Amp;
Stats.WaveLen=Len;

[w,kcenter]=min(abs(PacX));
[wleft,kleftpick]=max(PacY(1:kcenter));
[wright,krightpick]=max(PacY(kcenter:PacN));
krightpick=krightpick+kcenter-1;
[wcenter,kcenter]=min(PacY(kleftpick:krightpick));
Stats.CenterDippeningDepth=(wleft+wright-2*wcenter)/2;
Stats.CenterDippeningWidth=abs(PacX(krightpick)-PacX(kleftpick));
if Draw
    figure(2);
    cla; hold on; axis equal;
    plot(x,y,'.');
    plot(PacX,PacY,'r.');
    plot(PacX(kleftpick),PacY(kleftpick),'ro');
    plot(PacX(krightpick),PacY(krightpick),'bo');
    kcenter=kcenter+kleftpick-1;
    plot(PacX(kcenter),PacY(kcenter),'go');
end