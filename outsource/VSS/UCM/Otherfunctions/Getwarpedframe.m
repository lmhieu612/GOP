function imagetoreturn=Getwarpedframe(flows,cim,frame,howmany,useinterp,noFrames,printonscreen,ratios)

if ( (~exist('frame','var')) || (isempty(frame)) )
    frame=10;
end
if ( (~exist('noFrames','var')) || (isempty(noFrames)) )
    noFrames=numel(flows.whichDone);
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=false;
end
if ( (~exist('howmany','var')) || (isempty(howmany)) )
    howmany=2;
end
if ( (~exist('useinterp','var')) || (isempty(useinterp)) )
    useinterp=false;
end
if ( (~exist('ratios','var')) || (isempty(ratios)) )
    ratios=zeros(1,howmany+1);
    multcount=1;
    for i=howmany+1:-1:1
        ratios(i)=multcount;
        multcount=multcount*1.5; %or 2, meaning a more central frame is counted multcount time the adjacent
    end
%     sratios=ratios(1)+2*sum(ratios(2:end));
        %sum of the ratios
end


image=cim{frame};

rows=size(image,1);
cols=size(image,2);



warpedimages=cell(1,howmany*2+1);
allvalid=false(rows,cols,howmany*2+1);
allratios=zeros(rows,cols,howmany*2+1);

warpedimages{1}=double(cim{frame});
allvalid(:,:,1)=true(rows,cols);
allratios(:,:,1)=ones(rows,cols).*ratios(1);


for i=1:howmany
    
    fp=frame+i;
    fm=frame-i;
    fpr=fp-1;
    fmr=fm+1;
    
    whichp=i*2;
    whichm=i*2+1;
    
    if (fp>noFrames)
        Ccp=zeros(rows,cols,3);
        validtop=false(rows,cols);
    else
        Ccp=double(cim{fp});
        validtop=true(rows,cols);
        for ff=fp:-1:frame+1
            fpr=ff-1;

            if (useinterp)
                [Ccp,validtop]=Getwarpedimagewithinterp(fpr,flows,Ccp,true,validtop);
            else
                [Ccp,validtop]=Getwarpedimage(fpr,flows,Ccp,true,validtop);
            end
        end
    end
    warpedimages{whichp}=Ccp;
    allvalid(:,:,whichp)=validtop;
    allratios(:,:,whichp)=double(validtop).*ratios(i+1);
    
    if (fm<1)
        Ccm=zeros(rows,cols,3);
        validtom=false(rows,cols);
    else
        Ccm=double(cim{fm});
        validtom=true(rows,cols);
        for ff=fm:+1:frame-1
            fmr=ff+1;

            if (useinterp)
                [Ccm,validtom]=Getwarpedimagewithinterp(fmr,flows,Ccm,false,validtom);
            else
                [Ccm,validtom]=Getwarpedimage(fmr,flows,Ccm,false,validtom);
            end
        end
    end
    warpedimages{whichm}=Ccm;
    allvalid(:,:,whichm)=validtom;
    allratios(:,:,whichm)=double(validtom).*ratios(i+1);

end


oneimage=zeros(rows,cols,3);
for c=1:3
    oneimage(:,:,c)=warpedimages{1}(:,:,c).*allratios(:,:,1);
end
oneratio=allratios(:,:,1);

for i=1:howmany
    whichp=i*2;
    whichm=i*2+1;
    
    for c=1:3
        oneimage(:,:,c)=oneimage(:,:,c)+warpedimages{whichp}(:,:,c).*allratios(:,:,whichp);
        oneimage(:,:,c)=oneimage(:,:,c)+warpedimages{whichm}(:,:,c).*allratios(:,:,whichm);
    end
    oneratio=oneratio+allratios(:,:,whichp);
    oneratio=oneratio+allratios(:,:,whichm);
end

for c=1:3
    oneimage(:,:,c)=oneimage(:,:,c)./oneratio;
end
    

if (printonscreen)
    figure(51), imshow(uint8(oneimage))
    set(gcf, 'color', 'white');
    title( ['Image at frame ',num2str(frame),' with all warped flows'] );
    figure(52), imshow(cim{frame})
    set(gcf, 'color', 'white');
    title( ['Original image at frame ',num2str(frame)] );

    diffimage=abs(double(cim{frame})-oneimage);
    figure(53), imagesc(sum(diffimage,3)/3)
    set(gcf, 'color', 'white');
    title( ['Image at frame ',num2str(frame),' with all warped flows'] );
end

imagetoreturn=uint8(round(oneimage));

% figure(52), imshow(uint8(warpedimages{whichp}))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );
% figure(53), imshow(cim{frame})
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame)] );
% figure(54), imshow(allvalid(:,:,whichp))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );
% figure(55), imshow(allratios(:,:,whichp))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );
% 
% figure(56), imshow(uint8(warpedimages{whichm}))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );
% figure(57), imshow(cim{frame})
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame)] );
% figure(58), imshow(allvalid(:,:,whichm))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );
% figure(59), imshow(allratios(:,:,whichm))
% set(gcf, 'color', 'white');
% title( ['Image at frame ',num2str(frame),' warped with flow'] );


% [tmp,tmp,velUp,velVp]=GetUandV(flows.flows{fp});
% [velUm,velVm,tmp,tmp]=GetUandV(flows.flows{fm});


% if frame>1
%     imagem=cim{frame-1};
%     imagem=ToDblGray(imagem);
% else
%     imagem=image;
% end
% if frame<noFrames
%     imagep=cim{frame+1};
%     imagep=ToDblGray(imagep);
% else
%     imagep=image;
% end
% if (~flows.whichDone(frame))
% 
%     [U,V]=meshgrid(1:cols,1:rows); %pixel coordinates
% 
%     if frame>1
%         flowMinus=TV(image,imagem);
%         Um=U+flowMinus(:,:,1);
%         Vm=V+flowMinus(:,:,2);
%     else
%         Um=U;
%         Vm=V;
%     end
%     if frame<noFrames
%         flowPlus=TV(image,imagep);
%         Up=U+flowPlus(:,:,1);
%         Vp=V+flowPlus(:,:,2);
%     else
%         Up=U;
%         Vp=V;
%     end
%     
%     flows.flows{frame}.Um=Um;
%     flows.flows{frame}.Vm=Vm;
%     flows.flows{frame}.Up=Up;
%     flows.flows{frame}.Vp=Vp;
% end
% 
% flows.whichDone(frame)=1; %sets the flag to not repeat the operation
% 



