function nearMask=Get_region_area_near_point(mask,pointxy,sigmax,factorGaussian,printonscreen,G)

if ( (~exist('sigmax','var')) || (isempty(sigmax)) ) %defining the Gaussian for spatial neighbouring
    sigmax=10;
end
if ( (~exist('factorGaussian','var')) || (isempty(factorGaussian)) ) %defining the spatial Gaussian size
    factorGaussian=2.5;
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=true; %The function displays images by default
end

dimIi=size(mask,1);
dimIj=size(mask,2);

%defining the Gaussian function
gsize=max(1,fix(sigmax*factorGaussian)); %gsize can be varied independently from sigmax
                            %2*sigma should infact be enough

if ( (~exist('G','var')) || (isempty(G)) ) %so as not to have to produce the same gaussian always
    G=fspecial('gaussian',gsize*2+1,sigmax);
end
% figure(21),imagesc(G)
% set(gcf, 'color', 'white');


if (printonscreen)
    figure(23)
    set(gcf, 'color', 'white');
    imagesc(mask);
    title ('Mask of selected area');
    hold on;
    plot(pointxy(1),pointxy(2),'w+');
    hold off;
end

nearMask=zeros(dimIi,dimIj);

firstMi=max(pointxy(2)-gsize,1);
firstGi=firstMi-pointxy(2)+gsize+1;
endMi=min(pointxy(2)+gsize,dimIi);
endGi=gsize+1+endMi-pointxy(2);
firstMj=max(pointxy(1)-gsize,1);
firstGj=firstMj-pointxy(1)+gsize+1;
endMj=min(pointxy(1)+gsize,dimIj);
endGj=gsize+1+endMj-pointxy(1);

nearMask(firstMi:endMi,firstMj:endMj)=G(firstGi:endGi,firstGj:endGj).*mask(firstMi:endMi,firstMj:endMj);
sumP=sum(nearMask(:));
if (sumP~=0)
    nearMask=nearMask./sumP;
else
    fprintf('Could not normalise mask\n');
end

if (printonscreen)
    figure(27)
    set(gcf, 'color', 'white');
    imagesc(nearMask);
    title ('Mask of predicted area');
end





