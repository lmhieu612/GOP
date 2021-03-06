function [allthesegmentations]=Clustervideosegmentation(similarities,labelledlevelunique,options,filenames,mergesegmoptions,plmultiplicity,newlabelcount,plseed,seeds)

%labelledlevelunique should correspond to similarities

%Debug assignments:
% similarities=twreducedsimilarities;
% labelledlevelunique=(1:size(twreducedsimilarities,1));



if ( (~exist('plmultiplicity','var')) || (isempty(plmultiplicity)) )
    plmultiplicity=false; %plmultiplicity false (default) implies equal weights to data points in k-means, independently from the multiplicity
end
if ( (~exist('plseed','var')) || (isempty(plseed)) )
    plseed=false; %plseed false (default) implies random initialization for k-means
end
if ( (~exist('newlabelcount','var')) || (isempty(newlabelcount)) )
    newlabelcount=[];
end
if ( (~exist('seeds','var')) || (isempty(seeds)) )
    seeds=[];
end



%Parameter setup
n_size=mergesegmoptions.n_size; %default is 7, 0 when neighbours have already been selected, (includes self-connectivity)
saveyre=mergesegmoptions.saveyre; %The option also controls the loading
%Define the clustering and number of cluster method:
% - 'manifoldcl'
%   - 'numberofclusters','logclusternumber','adhoc', [1,2,3,...] referring to k-means,
%       [1,2,3,...] used to determine the divisive coefficients for dbscan or the requested clusters for optics
% - 'distances'
%   - 'linear','log','distlinear','distlog' refer to the merging based on the distances or manifold distances
setclustermethod=mergesegmoptions.setclustermethod; %'manifoldcl', 'distances'
clusternumbermethod=mergesegmoptions.clusternumbermethod; %'linear','log','distlinear','distlog','numberofclusters','logclusternumber','adhoc', [1,2,3,...]
numberofclusterings=mergesegmoptions.numberofclusterings; %Desired number of hierarchical levels, not used if 'adhoc' or actual cluster numbers are defined
includethesuperpixels=mergesegmoptions.includethesuperpixels; %include oversegmented video into allthesegmentations and newucm2
manifoldmethod=mergesegmoptions.manifoldmethod; %'iso','isoii','laplacian'
dimtouse=mergesegmoptions.dimtouse;

manifoldclustermethod=mergesegmoptions.manifoldclustermethod; %'km','km3','litekm','yaelkm','dbscan','optics', used in combination with 'manifoldcl'
if ( (~isfield(mergesegmoptions,'manifolddistancemethod')) || (isempty(mergesegmoptions.manifolddistancemethod)) ) %[option for setclustermethod='distances'] 'origd','euclidian'(default),'spectraldiffusion'
    manifolddistancemethod='euclidian'; %default option
else
    manifolddistancemethod=mergesegmoptions.manifolddistancemethod;
end

noallsuperpixels=size(similarities,1);
% if (noallsuperpixels~=max(labelledlevelunique(:))), error('Number of superpixels in Clustervideosegmentation'); end



tmpfilenames.the_isomap_yre=[filenames.filename_directory,'Videopicsidx',filesep,'yretmp.mat'];
tmpfilenames.the_tree_structure=[filenames.filename_directory,'Videopicsidx',filesep,'treestructuretmp.mat'];

[Y,alldistances, mapping]=Getmanifoldandprogressivedistances(similarities,setclustermethod,dimtouse,n_size,manifoldmethod,tmpfilenames,saveyre,manifolddistancemethod);
numberofdistances=numel(alldistances);



if ( ischar(clusternumbermethod) )
    mergesteps=Definemergesteps(numberofdistances,numberofclusterings,clusternumbermethod,alldistances,noallsuperpixels);
else
    mergesteps=clusternumbermethod;
end

if ( (strcmp(setclustermethod,'manifoldcl')) )
    numberofclusterings=numel(mergesteps);
elseif ( (strcmp(setclustermethod,'distances')) )
    numberofclusterings=numel(mergesteps)-1;
   %merge proceeds from mergesteps(i)+1 to mergesteps(i+1) (extrema included) with 1<=i<=(numberofclusterings)
else
    error('setclustermethod in Clustervideosegmentation');
end

if (strcmp(manifoldclustermethod,'dbscan'))
    options.kdbscan=10;
    chosend=Getchosend(Y,dimtouse);
    eps=Determinetheepsilon((Y.coords{chosend})',options.kdbscan);
    mergesteps=eps./mergesteps;
end
if (strcmp(manifoldclustermethod,'optics'))
    koptics=40;
    chosend=Getchosend(Y,dimtouse);
    [RD,CD,order]=Optics([Y.coords{chosend}]',koptics);

    options.thecorrtable=Clustertoreachability(mergesteps,RD,order,true);
    options.order=order;
    options.RD=RD;
end



%Initialization of a cell array with all segmentations
if (includethesuperpixels)
    allthesegmentations=cell(1,numberofclusterings+1);
else
    allthesegmentations=cell(1,numberofclusterings);
end
labelsfc=1:size(similarities,1);

for level=1:numberofclusterings
    
    if ( (strcmp(setclustermethod,'manifoldcl')) )
        tryonlinefirst=true; noreplicates=100; noGroups=mergesteps(level);
       
        [IDX,kmeansdone]=Clusterthepoints(Y,manifoldclustermethod,noGroups,dimtouse,noreplicates,tryonlinefirst,[],[],[],options,plmultiplicity,newlabelcount,plseed,seeds); %,offext,C
        valid=kmeansdone;
 
        [labelsfc]=Gettmandlabelsfcfromidx(IDX); 
    
  
    
    elseif ( (strcmp(setclustermethod,'distances')) )
        [labelsfc,valid]=Getthelabelsfromdistances(labelsfc, mapping,...
            (mergesteps(level)+1), mergesteps(level+1));
    else
        error('setclustermethod in Clustervideosegmentation');
    end

    if (~valid)
        fprintf('Not valid video segmentation for level %d\n',level);
        labelsfc=1:size(similarities,1);
    end

%     %From clusters to labelled frames (each pixel gets a cluster code,
%     %possibly permuted for visualisation purposes)
%     labelledvideo=Labelclusteredvideointerestframes(mapped,labelsfc,ucm2,Level,framerange,printonscreeninsidefunction);
% 
%     %output segmentations
%     allthesegmentations{level}=Uintconv(labelledvideo);
    
   
    %Output segmentation
    allthesegmentations{level}=Uintconv(labelsfc(labelledlevelunique));   
    
    %fprintf('Level %d (out of %d) processed\n', level, numberofclusterings);
end



if (includethesuperpixels)
    allthesegmentations{numberofclusterings+1}=Uintconv(labelledlevelunique);
end


if (false)
    %This additionally requests cim
    for level=1:numel(allthesegmentations) %#ok<UNRCH>
        Printthevideoonscreen(Doublebackconv(allthesegmentations{level}), true, 3, false,[],false,true);
        Printthevideoonscreensuperposed(Doublebackconv(allthesegmentations{level}), true, 3, true, [], false, true, cim,[]); %same as before but superpose, cim missing
    end
end



function Other_code() %#ok<DEFNU>

framesize=floor((size(ucm2{1})-1)/2); %#ok<USENS>
allthesegmentations=Initallsegmentations(framesize,numberofclusterings,includethesuperpixels,mapped,ucm2,Level,framerange); %#ok<NASGU> %[,labelledvideo]

fprintf('isequal %d, size %d,%d size %d,%d\n',all(Doublebackconv(allthesegmentations{level})==labelsfc), size(allthesegmentations{level},1), size(allthesegmentations{level},2), size(labelsfc,1), size(labelsfc,2) )


function Test_new_functions()

options.testthesegmentation=false; options.segaddname='Ucm'; %Berkeley benchmark and ours to test image segmentation parameters
options.testmanifoldclustering=true; options.clustaddname='TMPc'; %Our metric to plot global and average recall and precision
options.testbmetric=false; options.broxmetricsname='Bmcfstltifeff'; options.broxmetriccases=[1,2,3,4,5,6,7,8,9,10,20]; %Use the Brox benchmark on one video segmentation (default nclusters=10,20)
options.testnewsegmentation=true; options.newsegname='TMPsegm'; %Use the Berkeley benchmark for the superposed video segmentations
options.calibratetheparameters=false; options.calibrateparametersname='Paramcfstltifefff'; %Gather row values and test affinity transformations
options.evalhigherorder=true; options.higherorderdir='TMPh'; %Higher order segmentation of superpixel trajectories
options.mergehigherorder=true; options.mergehigherdir='TMPmerge'; %Merge higher order trajectories and large superpixels into the affinity matrix
options.proplabels=true; options.proplabelsdir='TMPprop'; options.segmspxtracks='TMPh'; %Propagate labels in video sequences
options.savefortraining=false; options.trainingdir='Traincfstltifefffssvlt'; %Gather raw values and ground truth
options.userf=false; options.rfaffinity='Trainedcfstltifefffssvlt.mat'; %Rf trained trees for affinity computation
options.saveaff=false; options.affaddname='Afffstltifeff'; %Computed affinity is saved, both 2-affinity and higher order



options.faffinityv=10;

partlength=min(options.faffinityv,numel(ucm2));
partucm2=ucm2(1:partlength);
partcim=cim(1:partlength);
partflows.whichDone=flows.whichDone(1:partlength);
partflows.flows=flows.flows(1:partlength);

ucm2=partucm2;
cim=partcim;
flows=partflows;
