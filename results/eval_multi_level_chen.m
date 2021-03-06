function [ stat ] = eval_multi_level_chen( set_of_sv_map,path_gt )

addpath(genpath('../code/eval_code'));
numlv = size(set_of_sv_map,2);k=0;
stat=[];

s = zeros(numlv,4);
parfor i=1:numlv
    
    
    
    sv_map = double(set_of_sv_map{i});
    [I_h, I_w, frame_num] = size(sv_map);
    % read the ground-truth file
    [gt_map, gt_list] = read_gt_chen(path_gt, I_w, I_h);
    accu_3D = measure_accuracy_3D(gt_map, sv_map, gt_list(1,1))*100;
    ue_3D = measure_underseg_3D(gt_map, sv_map, gt_list(1,1));
    [br_3D, bp_3D, br_map_3D] = measure_boundaryrecall_3D(gt_map, sv_map);
    
    %stat = [sv_num; accu_2D; ue_2D; br_2D; accu_3D; ue_3D; br_3D; bp_3D];
    s(i,:) = [accu_3D, ue_3D, br_3D, bp_3D];
end;
if isempty(stat) stat= s;
else
    stat=[stat;s];
end;

end

