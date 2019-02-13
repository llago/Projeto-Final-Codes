% clear all;
annotation_file = 'C:\Projeto Final\Dataset\Gururani\annotation.csv';
annotation = csvread(annotation_file);
tic

% for proeminence = 0:5:20

    for j = 1:80
        hos_file = ['C:\Projeto Final\Results\DTW\Complete_durations_PFNMF\', num2str(j), '_Suspect_', num2str(annotation(j,2)),  '_Sample_',  num2str(annotation(j,1)),  '.mat'];

        load(hos_file);
        for i= 1:size(Ho_hypo_cell,1)

            Ho_norm = normalize(Ho, 1);
            Ho_hypo_norm = normalize(Ho_hypo_cell{i}, 1);

            D = pdist2(Ho_norm', Ho_hypo_norm','correlation');
            [a,c,DeltaP] = DTW_sub_query(D);
            c_cell{i} = c;
            DeltaP_cell{i} = DeltaP;

%             [mins_cell{i}, loc_mins_cell{i}, widths, prominence] = findpeaks(-c(end,:),'MinPeakProminence', proeminence);
            mins_cell{i} = c(end,:);
            loc_mins_cell{i} = 1:size(Ho_hypo_cell{i},2);
            global_min(i) = min(c(end,:));

%             figure;
%             imagesc(c);
%             title(i);
        end

        % Finds best semi-tom 
        [~,best_index] = min(global_min);

        paths_cell = DTW_path_finder(c_cell{best_index}, DeltaP_cell{best_index}, loc_mins_cell{best_index});
        locs{j} = loc_mins_cell{best_index};
        costs_mat = cell2mat(mins_cell(best_index));

        costs{j} = costs_mat;
        paths{j} = paths_cell;
        best_index_cell{j} = best_index;

        figure;   
        imagesc(c_cell{best_index});
        title(best_index);
        for k = 1:size(paths_cell,2)
            hold on;
            plot(paths_cell{k}(:,2),paths_cell{k}(:,1), 'r')
        end

    
    end
toc
% save('.\Results\DTW\Costs_locs\all_points_last_row.mat', 'costs', 'locs', 'paths', 'best_index_cell', '-v7.3')
% end
