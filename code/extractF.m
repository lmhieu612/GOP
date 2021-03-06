profile on;
close all;
tic
clear;
addpath(genpath('../outsource/toolbox-master'));
addpath(genpath('../outsource/spDetect'));


allnum =[]
% video_name = 'v_Basketball_g01_c01.avi';
% input.path = 'v_Basketball_g01_c01.avi/';
% video_name = 'v_IceDancing_g01_c01.avi';
% input.path = 'v_IceDancing_g01_c01.avi/';
video_name_array = {'birdfall';'cheetah';'monkeydog';'girl';'penguin';'parachute';'bmx';'drift';'hummingbird';'monkey';
    'soldier';'bird_of_paradise';'frog';'worm';};
%input.numi=2;

for j=6:6
maxdist =0;
sp=[];
graph = [];geo_hist=[];
seeds_color=[];
seeds=[];area=[];
seeds_geo = [];
pos_dist =[];
pos =[];
oriedges =[];

    video_name = video_name_array{j};
    input.path  = ['../video/Seg/JPEGImages/' video_name '/'];
    gtpath = ['../video/Seg/GroundTruth/' video_name '/'];
    
    loadoption;
    
    parfor ii=1:input.numi
        ii
        %   iii = input.numi+1-ii;
        % if ii==2 iii=5;end;
        filename = [input.path,input.imglist(ii).name];
        % I(:,:,:,ii) = imread(filename);
        I(:,:,:,ii) = imresize(imread(filename),[240,NaN]);
        [E,~,~,segs]=edgesDetect(I(:,:,:,ii),model);
        E(E<0) = 0;
        [sp(:,:,ii),~] = spDetect(I(:,:,:,ii),E,opts);
       % sp(:,:,ii)= mex_ers(double(I(:,:,ii)),numSP);
        sp(:,:,ii)=sp(:,:,ii)+1;
        nsp = max(max(sp(:,:,ii)));
     %   c = spMerge(uint8(I(:,:,:,ii)), double(sp(:,:,ii)), percentile, lowerBound, colorSpace, modelSelection, optMethod, 0);
      %  c= convertspmap(c,[unique(c)',[1:numel(unique(c))]']);
      %  sp(:,:,ii) = convertspmap(sp(:,:,ii),[[1:nsp]',c']);
      %  nsp = max(max(sp(:,:,ii)));
        %    sp(:,:,ii) = convertspmap(sp(:,:,ii),[[1:nsp]',[randperm(nsp)]']);
        
        for k =1:nsp
            area{ii}(k) = sum(sum(sp(:,:,ii) == k))/(h*w);
        end
        sp_c = sp_c + nsp;
        splist(ii) = nsp;
        %  Z = spAffinities(sp(:,:,ii),E,segs,4);

       
      %  E2= imsharpen(E,'Radius',2,'Amount',5);
%         [Gx, Gy] = imgradientxy(rgb2gray(I(:,:,:,ii)));
%         [E2, Gdir] = imgradient(Gx, Gy);
%         E2 = E2 +1;
        Z = spAffinities_vu(sp(:,:,ii),E);
        Z(Z<0) =0 ;Z = sparse(double(Z));
        graph{ii} =Z;
        % graph(psp:sp_c,psp:sp_c) = Z;
        psp = splist(ii)+1;
        %  seed{ii}(:) = extract_seeds(nseeds,Z);
        tic;
        seeds{ii}(:) = 1:nsp;
        L_hist{ii} = zeros(nsp,nbins);
        A_hist{ii} = zeros(nsp,nbins);
        B_hist{ii} = zeros(nsp,nbins);
        geo_hist{ii} = zeros(nsp,geo_hist_bin);
        tic;
        hsvimage = rgb2hsv(I(:,:,:,ii));
        labimage = rgb2lab(I(:,:,:,ii));
        labimage = (labimage-LABnorm1).*LABnorm2;
        
        
        for i=1:length(seeds{ii})
            seeds_geo{ii}(i,:) = geocompute(Z,seeds{ii}(i));
            seeds_color{ii}(i,:) = rgb_mean(I(:,:,:,ii),sp(:,:,ii),i);
            
            [L_hist{ii}(i,:),A_hist{ii}(i,:),B_hist{ii}(i,:)] = ...
                lab_histogram(labimage,sp(:,:,ii),i);
            [H_hist{ii}(i,:),S_hist{ii}(i,:),V_hist{ii}(i,:)] = ...
                hsv_histogram(hsvimage,sp(:,:,ii),i);
            %  rgbhistogram{ii}(i,:) = rgb_histogram(I(:,:,:,ii),sp(:,:,ii),i);
            pos{ii}(i,:) = computesppos(sp(:,:,ii),i);
        end;
        toc;
        maxdist = max(maxdist,max(max(seeds_geo{ii})));
    end;
    
    tic;
    for ii=1:input.numi
        for i =1:length(seeds{ii})
            geo_hist{ii}(i,:)=histwc(seeds_geo{ii}(i,:),area{ii},geo_hist_bin,maxdist);
            %geo_hist2d{ii}(i,:,:)=histwc(seeds_geo{ii}(i,:),seeds_color{ii},area{ii},geo_hist_bin,maxdist);
        end;
        
    end;
    toc;
    save([video_name]);
    %test_best_matching;
   % onefr
end;
%current;
%testflow
%FindNeighbors;
%UnaryPotentials;
%naive_choose_best;
% for ii=2:input.numi
%     dist = pop_pair_wise_potentials(ii-1,ii,geo_hist,pos,L_hist,A_hist,B_hist);
%     sp = nchbest(ii,dist,sp,splist);
% end
%gen_color;

