function [ affinity_matrix ] = compute_affinitymatrix( sp,splist,edge,img,options)
%COMPUTE_AFFINITYMATRIX 
% sp: sp map 1:splist(i)
% splist=[400,420,400...]
% edge h*w*numi

numi = size(img,4);
cumspn = [0,cumsum(splist)];
numsp = sum(splist);
h= size(img,1);w= size(img,2);
tic
for ii=1:numi
    nsp = splist(ii);
    seeds_geo = zeros(nsp,nsp);
    seeds_color = zeros(nsp,1);
    seeds = 1:nsp;
    pos =zeros(nsp,2);
    Z = spAffinities_vu(sp(:,:,ii),edge(:,:,ii));
    Z(Z<0) =0 ;Z = sparse(double(Z));
    
    area{ii} =zeros(1,nsp);
    grimg = rgb2gray(img(:,:,:,ii));
    for k =1:nsp
        area{ii}(k) = sum(sum(sp(:,:,ii) == k))/(h*w);
    end
    
    for i=1:length(seeds)
        seeds_geo(i,:) = geocompute(Z,seeds(i));
        seeds_color(i) = rgb_mean(grimg,sp(:,:,ii),i);
        pos(i,:) = computesppos(sp(:,:,ii),i);
    end;
    if (options.phi > 0)
        gaussiandis = pdist2(pos,pos,'euclidean');  gaussiandis = exp(-gaussiandis/options.phi);
    else
        gaussiandis = ones(length(seeds),length(seeds));
    end;
    for i=1:length(seeds)
      %  geo_hist{ii}(i,:)=histwc(seeds_geo{ii}(i,:),area{ii}.*gaussiandis(i,:),geo_hist_bin,max(max(seeds_geo{ii})));
       % geo_hist2d{ii}(i,:,:)=histwc2D(seeds_geo(i,:)',seeds_color(i,:)',area{ii}.*gaussiandis(i,:),9,13,5,255);
        geo_hist2d{ii}(i,:,:)=histwc2D(seeds_geo(i,:)',seeds_color,area{ii}.*gaussiandis(i,:),options.nGeobins,options.nIntbins,options.maxGeo,options.maxInt);
    
    end
    
end
a=toc;
display(['features computed in ',num2str(a)]);
affinity_matrix = sparse(zeros(numsp,numsp));
tic
for i=1:numi-1
    hist_dist_o = mypdist2(geo_hist2d{i},geo_hist2d{i+1},'chisq2d');
  %  hist_dist_n = exp(-hist_dist_o/0.05);
    affinity_matrix((cumspn(i)+1) : cumspn(i+1),(cumspn(i+1)+1) : cumspn(i+2)) = hist_dist_o;
    affinity_matrix((cumspn(i+1)+1) : cumspn(i+2),(cumspn(i)+1) : cumspn(i+1)) = hist_dist_o';
end
toc
tic
for i=1:numi
    hist_dist_o = mypdist2(geo_hist2d{i},geo_hist2d{i},'chisq2d');
  %  hist_dist_n = exp(-hist_dist_o/0.05);
    affinity_matrix((cumspn(i)+1) : cumspn(i+1),(cumspn(i)+1) : cumspn(i+1)) = hist_dist_o;
end
toc
end




