function [feature_matrix, steps] = featureExtract_Lucas3(costs, locs, paths, sample_size)
        
    for i = 1:size(paths,2)
        
        path = paths{i};
        path_start(i) = path(2,2);
        slope = (path(end,1) - path(1,1))/(path(end,2) - path(1,2));
        cum_dev = sum(abs(path(2:end-1,1) - path(2:end-1,2)*slope + path(2,2)*slope)/sqrt(1+slope*slope)); 

        slopes(i) = slope;
        cum_dev = cum_dev/size(path,1);
        slope_dev(i) = cum_dev;
    end

% Get the minima in each step
locs_diff = diff([0, path_start]);
% locs_diff = [1 locs_diff];
steps = path_start(locs_diff~=0);
% steps = [steps, numel(path_start)];
locs_idx = 1:numel(locs);
locs_step_idx = locs_idx(locs_diff~=0);
locs_step_idx = [locs_step_idx, numel(path_start)];
locs_step_idx(end) = locs_step_idx(end) + 1;
length_steps = diff(steps);

length_steps(end) = length_steps(end)+1;

%Normalize length of steps
norm_length_steps = length_steps / max(length_steps);

min_cost = ones(1, numel(steps))*-1;
av_cost = ones(1, numel(steps))*-1;
std_cost = ones(1, numel(steps))*-1;
length_min_path = ones(1, numel(steps))*-1;
slope_min = ones(1, numel(steps))*-1;
dev_min = ones(1, numel(steps))*-1;
av_length = ones(1, numel(steps))*-1;
av_slope = ones(1, numel(steps))*-1;
av_dev = ones(1, numel(steps))*-1;
std_length = ones(1, numel(steps))*-1;
std_slope = ones(1, numel(steps))*-1;
std_dev = ones(1, numel(steps))*-1;
size_step = ones(1, numel(steps))*-1;

diff_length_min = ones(1, numel(steps))*-1;
av_diff_length = ones(1, numel(steps))*-1;
std_diff_length = ones(1, numel(steps))*-1;

% Extract features
for i = 1:numel(steps)
    local_slope = slopes(locs_step_idx(i):locs_step_idx(i+1)-1);
%     local_slope = local_slope/max(local_slope);
    
    local_paths = paths(locs_step_idx(i):locs_step_idx(i+1)-1);
    local_paths_length = cellfun(@(el) numel(el)/2, local_paths);
    local_paths_length_diff = abs(local_paths_length - sample_size);
    
    local_paths_length_diff = local_paths_length_diff/sample_size;
    local_paths_length = local_paths_length/sample_size;
    
    local_paths_length_diff = local_paths_length_diff/max(local_paths_length_diff);
    local_paths_length = local_paths_length/max(local_paths_length);

    local_costs = costs(locs_step_idx(i):locs_step_idx(i+1)-1);
    local_costs = local_costs/max(local_costs);
    
    local_dev = slope_dev(locs_step_idx(i):locs_step_idx(i+1)-1);
    local_dev = local_dev/max(local_dev);
    
    if (numel(local_slope) > 5)
        [min_cost(i), idx_min] = min(local_costs);
        av_cost(i) = mean(local_costs);
        std_cost(i) = std(local_costs);

%         length_min_path(i) = local_paths_length(idx_min); 
%         slope_min(i) = local_slope(idx_min);
%         dev_min(i) = local_dev(idx_min)/length_min_path(i);
%         diff_length_min(i) = diff_length_min(idx_min);

        length_min_path(i) = min(local_paths_length); 
        slope_min(i) = min(local_slope);
        dev_min(i) = min(local_dev)/length_min_path(i);
        diff_length_min(i) = min(local_paths_length_diff);

        av_length(i) = mean(local_paths_length);
        av_slope(i) = mean(local_slope);
        av_dev(i) = mean(local_dev);
        av_diff_length(i) = mean(local_paths_length_diff);

        std_length(i) = std(local_paths_length);
        std_slope(i) = std(local_slope);
        std_dev(i) = std(local_dev);
        std_diff_length(i) = std(local_paths_length_diff);


        size_step(i) = numel(local_slope);
    end
end

steps(size_step == -1) = [];

min_cost(min_cost == -1) = [];
av_cost(av_cost == -1) = [];
std_cost(std_cost == -1) = [];
length_min_path(length_min_path == -1) = [];
slope_min(slope_min == -1) = [];
dev_min(dev_min == -1) = [];
av_length(av_length == -1) = [];
av_slope(av_slope == -1) = [];
av_dev(av_dev == -1) = [];
std_length(std_length == -1) = [];
std_slope(std_slope == -1) = [];
std_dev(std_dev == -1) = [];
size_step(size_step == -1) = [];

diff_length_min(diff_length_min == -1) = [];
av_diff_length(av_diff_length == -1) = [];
std_diff_length(std_diff_length == -1) = [];


feature_matrix = zeros(16, numel(size_step));

feature_matrix(1,:) = min_cost;
feature_matrix(2,:) = av_cost;
feature_matrix(3,:) = std_cost;

feature_matrix(4,:) = length_min_path;
feature_matrix(5,:) = av_length;
feature_matrix(6,:) = std_length;

feature_matrix(7,:) = slope_min;
feature_matrix(8,:) = av_slope;
feature_matrix(9,:) = std_slope;

feature_matrix(10,:) = dev_min;
feature_matrix(11,:) = av_dev;
feature_matrix(12,:) = std_dev;

feature_matrix(13,:) = diff_length_min/max(diff_length_min);
feature_matrix(14,:) = av_diff_length;
feature_matrix(15,:) = std_diff_length;

feature_matrix(16,:) = size_step/max(size_step);
end