function [Ccp,validtop]=Getwarpedimage(fpr,flows,imagep,istoup,validtoppp)

rows=size(imagep,1);
cols=size(imagep,2);

Ccp=zeros(rows,cols,3);
flowtop=flows.flows{fpr};
Cp=zeros(rows,cols);

if (istoup)
    U=flowtop.Up;
    V=flowtop.Vp;
else
    U=flowtop.Um;
    V=flowtop.Vm;
end

for c=1:3
    imagepc=double(imagep(:,:,c));
    Cp(:)=imagepc( sub2ind(size(imagepc),max(1,min(rows,round(V(:)))),max(1,min(cols,round(U(:))))) );
    Ccp(:,:,c)=Cp(:,:);
end

validtop=true(rows,cols);
if ( (exist('validtoppp','var')) && (~isempty(validtoppp)) )
    validtop(:)=validtoppp( sub2ind(size(validtop),max(1,min(rows,round(V(:)))),max(1,min(cols,round(U(:))))) );
end
validtop= validtop & ( (V<=rows)&(U<=cols)&(V>=1)&(U>=1) ) ;



% Ccp=zeros(rows,cols,3);
% Ccm=zeros(rows,cols,3);
% flowtop=flows.flows{fp-1};
% flowtom=flows.flows{fm+1};
% Cp=zeros(rows,cols);
% Cm=zeros(rows,cols);
% for c=1:3
%     imagep=double(cim{fp}(:,:,c));
%     Cp(:)=imagep( sub2ind(size(imagep),max(1,min(rows,round(flowtop.Vp(:)))),max(1,min(cols,round(flowtop.Up(:))))) );
%     Ccp(:,:,c)=Cp(:,:);
% 
%     imagem=double(cim{fm}(:,:,c));
%     Cm(:)=imagem( sub2ind(size(imagem),max(1,min(rows,round(flowtom.Vm(:)))),max(1,min(cols,round(flowtom.Um(:))))) );
%     Ccm(:,:,c)=Cm(:,:);
% end
% 
% validtop= (flowtop.Vp<=rows)&(flowtop.Up<=cols)&(flowtop.Vp>=1)&(flowtop.Up>=1);
% validtom= (flowtom.Vm<=rows)&(flowtom.Um<=cols)&(flowtom.Vm>=1)&(flowtom.Um>=1);
