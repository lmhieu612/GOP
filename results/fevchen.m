function []=  fevchen(id,g,p1,p2,p3,p4,motion)
addpath(genpath('../code/eval_code'));
addpath(genpath('../code/affinitysp'));
names ={'bus_fa','container_fa','garden_fa','ice_fa','paris_fa','soccer_fa','salesman_fa','stefan_fa'};
if nargin ==1
    display('default');
    typea = [1,2]; %1: 1d,2: 2d
    ga=[50,100];
    p1 = 9;
    p2a = [5,13];
    p3a = [0,5];
    p4 = 255;
    motiona = [0,1];
    siz = [length(names),length(typea),length(ga),...
    length(p2a),length(p3a),length(motiona)];
    i = myind2sub(siz,id,6)
end;

name = names{i(1)}
type = typea(i(2))
gt = ['../video/chen/input/PPM/', name,'/frames/'];
g = ga(i(3))
p2=p2a(i(4))
p3=p3a(i(5))
motion=motiona(i(6))

switch type
case 2

    fname =['VSS_chen_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'/',name,'.mat'];
    if exist(fname)
        display('eval 2d histogram')
        fname
        load(fname);
        ev = eval_ev_multi_level(allthesegmentations(1:end-1),gt)
        save(['matresult/evchen_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'_',name],'ev');
    end;
case 0
    display('baseline');
    load(['VSS_chen/',name]);
    ev = eval_ev_multi_level(allthesegmentations(1:end-1),gt)
    save(['matresult/evchen_baseline_',name],'ev');
case 1
    fname = ['VSS_1d_chen_',num2str(g),'_',num2str(p1),'_',num2str(p2),'/',name,'.mat']
    if exist(fname)
        load(fname);
        fname
        display('eval 1d histogram')
        ev = eval_ev_multi_level(allthesegmentations(1:end-1),gt)
        save(['matresult/evchen_1d_',num2str(g),'_',num2str(p1),'_',num2str(p2),'_',name],'ev');
    end
end

end
%s= [stat1,stat2,stat3]
    %l=[l1,l2,l3];
%m=[m1,m2,m3];
%save(['rchen_',num2str(p1),'_',num2str(p2),'_',num2str(p3),'_',num2str(p4),'_',num2str(motion),'_',name]end
