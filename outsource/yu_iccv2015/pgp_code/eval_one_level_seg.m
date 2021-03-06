function [ stat ] = eval_one_level_seg( sv_map,inputGT )

addpath(genpath('../../../code/eval_code'));
t = dir(inputGT);t(1:2) =[];
numGT = length(t);
stat=[];
for j=1:numGT    
        path_gt =[inputGT,'/', num2str(j), '/'];

        [I_h, I_w, frame_num] = size(sv_map);
        % read the ground-truth file
        [gt_map, gt_list] = read_gt_segtrack(path_gt, I_w, I_h);
        accu_3D = measure_accuracy_3D(gt_map, sv_map, gt_list(1,1))*100;
        ue_3D = measure_underseg_3D(gt_map, sv_map, gt_list(1,1));
        [br_3D, bp_3D, br_map_3D] = measure_boundaryrecall_3D(gt_map, sv_map);
        
        %stat = [sv_num; accu_2D; ue_2D; br_2D; accu_3D; ue_3D; br_3D; bp_3D];
        s = [accu_3D, ue_3D, br_3D, bp_3D];

    if isempty(stat) 
        stat= s;
    else
        stat=[stat;s];
    end;
end
end

