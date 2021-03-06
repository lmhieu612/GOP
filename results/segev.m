function [s]=  evaseg(g,p1,p2,p3,p4,motion)
addpath(genpath('../code/eval_code'));
names ={'bird_of_paradise','birdfall','bmx','cheetah','drift','frog','girl','hummingbird','monkey','monkeydog','parachute','penguin','soldier','worm'};
%p1 = 9;
%p2 = 13;
%p3 = 5;
%p4 = 255;
%motion = 1;
%g=100
s= zeros(36,4);
c = 0;
switch nargin
case 6 %2d histogram
    for i=1:14
        name = names{i};
        load(['matresult/rseg_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'_',name],'stat','l','m');
        stat;
        while ~isempty(stat)
           c=c+1;
           s = s+ stat(1:36,:);
           stat(1:36,:) = [];
        end
    end;
    s=s/c;s
    save(['rallseg_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'_',name],'s');
case 0
    for i=1:14
        name = names{i}
        load(['matresult/rseg_baseline_',name],'stat','m','l');
        stat;
        while ~isempty(stat)
            c=c+1;
            s = s+ stat(1:36,:);
            stat(1:36,:) = [];
        end;
    end;
    s = s/c;
    s
    save('rallseg_baseline','s');
case 3
    display('1d');
    for i=1:14
        name = names{i}
        load(['matresult/rseg_1d_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',name]);
        stat
         while ~isempty(stat)
            c=c+1;
            s = s+ stat(1:36,:);
            stat(1:36,:) = [];
        end;
    end;
    s = s/c;
    s
    save(['rallseg_1d_',num2str(g),'_',num2str(p1),'_',num2str(p2)],'s');
end

%g=50
%load(['VSS_Segtrack_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'/',name]);
%stat2 = eval_multi_level_seg(allthesegmentations(1:end-1),gt)
%[l2,m2]= avglensv(allthesegmentations(1:end-1))

%baseline
%load(['VSS_Segtrack/',name]);
%stat1 = eval_multi_level_seg(allthesegmentations(1:end-1),gt)
%[l1,m1] = avglensv(allthesegmentations(1:end-1));


%s= [stat1,stat2,stat3]
%l=[l1,l2,l3];
%m=[m1,m2,m3];
%save(['rseg_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'_',name]);
end
