function [t,tnorm]=BallFretting(tetr,p,r)
%Given a uniform sampled filled point cloud returns a tight triangulation.
%
%Input:
%          tetr: a set of tetraedrons, nx4 array. If the colud is not tesselated
%                yet you need to call a delaunay triangulator prior calling 
%                this function.
%          p   : nx3 array, 3D set of points.
%          r   : the only parameter of the algorithm, the radius of the fretting
%                ball
% 
%                
% Output:
% 
%          t   : traingles ids, nx3 array
%          tnorm: nomrmals of triangles with outwards orientation
%          
% For bugs,infos: giaccariluigi@msn.com
% Visit: http://giaccariluigi.altervista.org/blog/
% 
% This work is free thanks to users gratitude. If you find it usefull please 
% consider making a donation on my website.


%Errors check
[np,m]=size(p);
if m ~=3
    error('Only 3D points supported')
end

[m]=size(tetr,2);
if m ~=4
    error('tetr must be a nx3 array')
end


if r<=0
    error('ball radius r must be positive')
end

m=max(tetr(:));
if m ~=np
    error('Invalid triangles array')
end


% tetr=int32(tetr);%save memory

%get circumcenter
ntetr=size(tetr,1);
cutsize=100000;
i1=1;i2=cutsize;
rtetr=zeros(ntetr,1);

tic
while i2<ntetr
[rtetr(i1:i2)]=CCTetra(p,tetr(i1:i2,:));
i1=i1+cutsize;
i2=i2+cutsize;
end
%last is special
[rtetr(i1:end)]=CCTetra(p,tetr(i1:end,:));
fprintf('CircumCenters time: %4.4f s\n',toc);


%squre the radius and run the comparison
deleted=rtetr>r*r;

tetr(deleted,:)=[];%delete tetraedrons

if size(tetr,1)<1
    t=[];
    return
end
tic
t=BoundaryTriangles(tetr);
fprintf('Boundary Triangles: %4.4f s\n',toc);

tic
[t,tnorm]=ManifoldExtraction(t,p);
fprintf('Manifold extraction: %4.4f s\n',toc);
end
%% Circumcenters Tetra
function [r]=CCTetra(p,tetr)
%returns the squared radius for a set of tetraedrons




% %points of tetraedron
p1=(p(tetr(:,1),:));
p2=(p(tetr(:,2),:));
p3=(p(tetr(:,3),:));
p4=(p(tetr(:,4),:));

%vectors of tetraedrom edges
v21=p1-p2;
v31=p3-p1;
v41=p4-p1;




%Solve the system using cramer method
d1=sum(v41.*(p1+p4)*.5,2);
d2=sum(v21.*(p1+p2)*.5,2);
d3=sum(v31.*(p1+p3)*.5,2);

det23=(v21(:,2).*v31(:,3))-(v21(:,3).*v31(:,2));
det13=(v21(:,3).*v31(:,1))-(v21(:,1).*v31(:,3));
det12=(v21(:,1).*v31(:,2))-(v21(:,2).*v31(:,1));

Det=v41(:,1).*det23+v41(:,2).*det13+v41(:,3).*det12;



detx=d1.*det23+...
    v41(:,2).*(-(d2.*v31(:,3))+(v21(:,3).*d3))+...
    v41(:,3).*((d2.*v31(:,2))-(v21(:,2).*d3));

dety=v41(:,1).*((d2.*v31(:,3))-(v21(:,3).*d3))+...
    d1.*det13+...
    v41(:,3).*((d3.*v21(:,1))-(v31(:,1).*d2));

detz=v41(:,1).*((v21(:,2).*d3)-(d2.*v31(:,2)))...
    +v41(:,2).*(d2.*v31(:,1)-v21(:,1).*d3)...
    +d1.*(det12);



%preallocation
cc=zeros(size(tetr,1),3);
%Circumcenters
cc(:,1)=detx./Det;
cc(:,2)=dety./Det;
cc(:,3)=detz./Det;



%Circumradius
r=(sum((p1-cc).^2,2));




end


%% Manifold Extraction

function [t,tnorm]=ManifoldExtraction(t,p)
%Given a set of trianlges,
%Buils a manifolds surface with the ball pivoting method.



% building the etmap

numt = size(t,1);
vect = 1:numt;                                                             % Triangle indices
e = [t(:,[1,2]); t(:,[2,3]); t(:,[3,1])];                                  % Edges - not unique
[e,j,j] = unique(sort(e,2),'rows');                                        % Unique edges
te = [j(vect), j(vect+numt), j(vect+2*numt)];
nume = size(e,1);
e2t  = zeros(nume,2,'int32');

clear vect j
ne=size(e,1);
np=size(p,1);


count=zeros(ne,1,'int32');%numero di triangoli candidati per edge
etmapc=zeros(ne,4,'int32');
for i=1:numt

    i1=te(i,1);
    i2=te(i,2);
    i3=te(i,3);



    etmapc(i1,1+count(i1))=i;
    etmapc(i2,1+count(i2))=i;
    etmapc(i3,1+count(i3))=i;


    count(i1)=count(i1)+1;
    count(i2)=count(i2)+1;
    count(i3)=count(i3)+1;
end

etmap=cell(ne,1);
for i=1:ne

    etmap{i,1}=etmapc(i,1:count(i));

end
clear  etmapc

tkeep=false(numt,1);%all'inizio nessun trinagolo selezionato


%Start the front

%building the queue to store edges on front that need to be studied
efront=zeros(nume,1,'int32');%exstimate length of the queue

%Intilize the front


         tnorm=Tnorm(p,t);%get traingles normals
         
         %find the highest triangle
         [foo,t1]=max( (p(t(:,1),3)+p(t(:,2),3)+p(t(:,3),3))/3);

         if tnorm(t1,3)<0
             tnorm(t1,:)=-tnorm(t1,:);%punta verso l'alto
         end
         
         %aggiungere il ray tracing per verificare se il triangolo punta
         %veramente in alto.
         %Gli altri triangoli possono essere trovati sapendo che se un
         %triangolo ha il baricentro più alto sicuramente contiene il punto
         %più alto. Vanno analizzati tutto i traingoli contenenti questo
         %punto
         
         
            tkeep(t1)=true;%primo triangolo selezionato
            efront(1:3)=te(t1,1:3);
            e2t(te(t1,1:3),1)=t1;
            nf=3;%efront iterato
      

while nf>0


    k=efront(nf);%id edge on front

    if e2t(k,2)>0 || e2t(k,1)<1 || count(k)<2 %edge is no more on front or it has no candidates triangles

        nf=nf-1;
        continue %skip
    end
  
   
      %candidate triangles
    idtcandidate=etmap{k,1};

    
     t1=e2t(k,1);%triangle we come from
    
   
        
    %get data structure
%        p1
%       / | \
%  t1 p3  e1  p4 t2(idt)
%       \ | /  
%        p2
         alphamin=inf;%inizilizza
          ttemp=t(t1,:);
                etemp=e(k,:);
                p1=etemp(1);
                p2=etemp(2);
                p3=ttemp(ttemp~=p1 & ttemp~=p2);%terzo id punto
        
                
         %plot for debug purpose
%          close all
%          figure(1)
%          axis equal
%          hold on
%          
%          fs=100;
%         
%          cc1=(p(t(t1,1),:)+p(t(t1,2),:)+p(t(t1,3),:))/3;
%          
%          trisurf(t(t1,:),p(:,1),p(:,2),p(:,3))
%          quiver3(cc1(1),cc1(2),cc1(3),tnorm(t1,1)/fs,tnorm(t1,2)/fs,tnorm(t1,3)/fs,'b');
%                 
       for i=1:length(idtcandidate)
               t2=idtcandidate(i);
               if t2==t1;continue;end;
                
               %debug
%                cc2=(p(t(t2,1),:)+p(t(t2,2),:)+p(t(t2,3),:))/3;
%          
%                 trisurf(t(t2,:),p(:,1),p(:,2),p(:,3))
%                 quiver3(cc2(1),cc2(2),cc2(3),tnorm(t2,1)/fs,tnorm(t2,2)/fs,tnorm(t2,3)/fs,'r');
%                
%                

               
                ttemp=t(t2,:);
                p4=ttemp(ttemp~=p1 & ttemp~=p2);%terzo id punto
        
   
                %calcola l'angolo fra i triangoli e prendi il minimo
              
                
                [alpha,tnorm2]=TriAngle(p(p1,:),p(p2,:),p(p3,:),p(p4,:),tnorm(t1,:));
                
                if alpha<alphamin
                    
                    alphamin=alpha;
                    idt=t2;  
                    tnorm(t2,:)=tnorm2;%ripristina orientazione   
                     
                    %debug
%                      quiver3(cc2(1),cc2(2),cc2(3),tnorm(t2,1)/fs,tnorm(t2,2)/fs,tnorm(t2,3)/fs,'c');
                    
                end
                %in futuro considerare di scartare i trianoli con angoli troppi bassi che
                %possono essere degeneri
                
       end


   
   
    
    
   %update front according to idttriangle
          tkeep(idt)=true;
        for j=1:3
            ide=te(idt,j);
           
            if e2t(ide,1)<1% %Is it the first triangle for the current edge?
                efront(nf)=ide;
                nf=nf+1;
                e2t(ide,1)=idt;
            else                     %no, it is the second one
                efront(nf)=ide;
                nf=nf+1;
                e2t(ide,2)=idt;
            end
        end
        
     
        

         nf=nf-1;%per evitare di scappare avanti nella coda e trovare uno zero
end
t=t(tkeep,:);
tnorm=tnorm(tkeep,:);
end





%% TriAngle
function  [alpha,tnorm2]=TriAngle(p1,p2,p3,p4,planenorm)

%per prima cosa vediamo se il p4 sta sopra o sotto il piano identificato
%dalla normale planenorm e il punto p3

test=sum(planenorm.*p4-planenorm.*p3);



%Computes angle between two triangles
v21=p1-p2;
v31=p3-p1;

tnorm1(1)=v21(2)*v31(3)-v21(3)*v31(2);%normali ai triangoli
tnorm1(2)=v21(3)*v31(1)-v21(1)*v31(3);
tnorm1(3)=v21(1)*v31(2)-v21(2)*v31(1);
tnorm1=tnorm1./norm(tnorm1);



v41=p4-p1;
tnorm2(1)=v21(2)*v41(3)-v21(3)*v41(2);%normali ai triangoli
tnorm2(2)=v21(3)*v41(1)-v21(1)*v41(3);
tnorm2(3)=v21(1)*v41(2)-v21(2)*v41(1);
tnorm2=tnorm2./norm(tnorm2);
alpha=tnorm1*tnorm2';%coseno dell'angolo
%il coseno considera l'angolo fra i sempipiani e non i traigoli, ci dice
%che i piani sono a 180 se alpha=-1 sono concordi se alpha=1, a 90°

alpha=acos(alpha);%trova l'angolo

%Se p4 sta sopra il piano l'angolo è quello giusto altrimenti va maggiorato
%di 2*(180-alpha);

if test<0%p4 sta sotto maggioriamo
   alpha=alpha+2*(pi-alpha);
end

%         fs=100;
%          cc2=(p1+p2+p3)/3;
%        quiver3(cc2(1),cc2(2),cc2(3),tnorm1(1)/fs,tnorm1(2)/fs,tnorm1(3)/fs,'m');
%        cc2=(p1+p2+p4)/3;
%               quiver3(cc2(1),cc2(2),cc2(3),tnorm2(1)/fs,tnorm2(2)/fs,tnorm2(3)/fs,'m');

%vediamo se dobbiamo cambiare l'orientazione del secondo triangolo
%per come le abbiamo calcolate ora tnorm1 t tnorm2 non rispettano
%l'orientamento
testor=sum(planenorm.*tnorm1);
if testor>0 
    tnorm2=-tnorm2;
end



end


%% Tnorm

function tnorm1=Tnorm(p,t)
%Computes normalized normals of triangles


v21=p(t(:,1),:)-p(t(:,2),:);
v31=p(t(:,3),:)-p(t(:,1),:);

tnorm1(:,1)=v21(:,2).*v31(:,3)-v21(:,3).*v31(:,2);%normali ai triangoli
tnorm1(:,2)=v21(:,3).*v31(:,1)-v21(:,1).*v31(:,3);
tnorm1(:,3)=v21(:,1).*v31(:,2)-v21(:,2).*v31(:,1);

L=sqrt(sum(tnorm1.^2,2));

tnorm1(:,1)=tnorm1(:,1)./L;
tnorm1(:,2)=tnorm1(:,2)./L;
tnorm1(:,3)=tnorm1(:,3)./L;
end


%% Boundary Triangles
function t=BoundaryTriangles(tetr)
%given a set of tetraedrons returns the boundary triangles

t = [tetr(:,[1,2,3]); tetr(:,[2,3,4]); tetr(:,[1,3,4]);tetr(:,[1,2,4])];%triangles not unique
clear tetr;

nt=size(t,1);

t=sort(t,2);
t=sortrows(t);
%gets lonely and boundary triangles
lonely=false(nt,1);
lonely(2:end-1)=any( (t(2:nt-1,:)~=t(3:end,:)),2) &  any((t(2:nt-1,:)~=t(1:end-2,:)),2);

%first and last are special
lonely(1)=lonely(2);
lonely(nt)=lonely(nt-1);

%pick boundary triangles
%not all them will rally be bounary since slivers will fake results
t=t(lonely,:);


end