function [ affinity_matrix,iqrTruncation ] = compute_affinitymatrix( sp,splist,edge,img,options)
%COMPUTE_AFFINITYMATRIX
% sp: sp map 1:splist(i)
% splist=[400,420,400...]
% edge h*w*numi
cumspn = [0,cumsum(splist)];
numsp = sum(splist);
numi = size(img,4);

h= size(img,1);w= size(img,2);
tic
k=max(splist);
seeds_geo = -ones(numi,k,k);

if options.useSpatialGrid == 1
    %devide into k1xk2 grid
    k1=options.Grid(1);
    k2=options.Grid(2);
    
    mask = cell(k1*k2,1);
    h_anchors = uint32(0:floor(h/k1):h);
    w_anchors = uint32(0:floor(w/k2):w);
    for i=1:k1*k2
        mask{i} = zeros(h,w);
        ind = myind2sub([k1,k2],i,2);
        start_point_h = h_anchors(ind(1))+1;
        end_point_h = h_anchors(ind(1)+1);
        
        start_point_w = w_anchors(ind(2))+1;
        end_point_w = w_anchors(ind(2)+1);
        mask{i}(start_point_h:end_point_h,start_point_w:end_point_w) =1;
    end
    grid_weight = 1/(k1*k2);
    grid_area = cell(k1*k2,1);
    
end

for ii=1:numi
    nsp = splist(ii);
    %  seeds_geo{ii} = zeros(nsp,nsp);
    seeds_color{ii} = zeros(nsp,1);
    seeds{ii} = 1:nsp;
    pos =zeros(nsp,2);
    Z = spAffinities_vu(sp(:,:,ii),edge(:,:,ii));
    Z(Z<0) =0 ;Z = sparse(double(Z));
    
    area{ii} =zeros(1,nsp);
    grimg = rgb2gray(img(:,:,:,ii));
    for k =1:nsp
        area{ii}(k) = sum(sum(sp(:,:,ii) == k))/(h*w);
    end
    
    if options.useSpatialGrid == 1
        
        for i=1:size(mask,1)
            grid_area{i}{ii}= zeros(1,nsp);
            for k =1:nsp
                grid_area{i}{ii}(k) = sum(sum((sp(:,:,ii) == k).*mask{i}))/(h*w);
            end
            
        end;
    end
    
    
    for i=1:length(seeds{ii})
        
        seeds_geo(ii,i,1:nsp) = geocompute(Z,seeds{ii}(i));
        seeds_color{ii}(i) = rgb_mean(grimg,sp(:,:,ii),i);
        pos(i,:) = computesppos(sp(:,:,ii),i);
    end;
    if (options.phi > 0)
        gaussiandis{ii} = pdist2(pos,pos,'euclidean');
        gaussiandis{ii} = exp(-gaussiandis{ii}/options.phi);
    else
        gaussiandis{ii} = ones(length(seeds{ii}),length(seeds{ii}));
    end;
end

if options.maxGeo ==0
    %% truncation point computation by the IQR rule
    q3 = prctile(seeds_geo(:), 75);
    myIQR = iqr(seeds_geo(:));
    iqrTruncation = q3+1.5*myIQR;  %try to make 1.5 into 3 and see what happens.
    options.maxGeo= iqrTruncation ;
end

if length(options.metric) == 0
    switch options.type
        case '2d'
            options.metric = 'chisq2d';
        case '1d'
            options.metric = 'chisq';
    end;
end;

display(['Metric: ',options.metric]);
affinity_matrix = affinity_extract(numi,numsp,seeds, seeds_geo,splist,seeds_color,area,gaussiandis,options );

if options.useSpatialGrid == 1
    for i=1:size(mask,1)
        aff = grid_weight* affinity_extract(numi,numsp,seeds, seeds_geo,splist,seeds_color,grid_area{i},gaussiandis,options );
        affinity_matrix = affinity_matrix + aff;
    end
    
end
a=toc;
display(['Features computed in ',num2str(a)]);
end




