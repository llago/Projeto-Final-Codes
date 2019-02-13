function [feature_matrix] = featureExtract_Lucas(costs, paths)

    paths_size_mat = [];
    slope_right = [];
    straightness = [];
    for i = 1:size(paths,2)
        paths_size_mat(i) = size(paths{i},1); 
        
        path = paths{i};
        x_path_size = path(end,2) - path(2,2);
%         size_dif(i) = abs(sample_size - x_path_size)/sample_size;
        slope = (path(end,1) - path(1,1))/(path(end,2) - path(1,2));
%         cum_start = floor(size(path,1)*0.3);
%         cum_end = floor(size(path,1)*0.7);
        cum_dev = sum(abs(path(2:end-1,1) - path(2:end-1,2)*slope + path(2,2)*slope)/sqrt(1+slope*slope)); 
%         cum_dev = sum(abs(path(cum_start:cum_end,1) - path(cum_start:cum_end,2)*slope + path(cum_start,2)*slope)/sqrt(1+slope*slope)); 

        cum_dev = cum_dev/size(path,1);
        straightness(i) = cum_dev;
        slope_right(i) = slope;
        x_init(i) = path(2,2);
        x_final(i) = path(end,2);
        y_final(i) = path(end,1);
    end

    feature_matrix = zeros(4, numel(costs));

    feature_matrix(1,:) = -costs./paths_size_mat;
    feature_matrix(2,:) = paths_size_mat;
    feature_matrix(3,:) = slope_right;
    feature_matrix(4,:) = straightness;
%     feature_matrix(5,:) = size_dif;

%     feature_matrix(5,:) = mean(-costs);
%     feature_matrix(6,:) = std(-costs);
%     feature_matrix(7,:) = mean(slope_right);
%     feature_matrix(8,:) = std(slope_right);
%     feature_matrix(9,:) = mean(straightness);
%     feature_matrix(10,:) = std(straightness);

%     feature_matrix(1,:) = costs;
%     feature_matrix(2,:) = slope_dev;
%     feature_matrix(3,:) = slopes;
%     feature_matrix(4,:) = paths_size_mat;
%     feature_matrix(5,:) = slope_right;
%     feature_matrix(6,:) = straightness;
%     feature_matrix(7,:) = x_init;
%     feature_matrix(8,:) = x_final;
%     feature_matrix(9,:) = y_final;
    
end