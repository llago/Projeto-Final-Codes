function [paths] = DTW_path_finder(C, DeltaP, loc_mins)
 
    % traceback from minimum cost element in last row of cost matrix
    iDec= [-1 -1; -1 0; 0 -1]; % compare DeltaP contents: diag, vert, hori
%     [~,loc] = min(C(end,:));
    last_row = size(C,1);
    paths = cell(1, size(loc_mins,2));

    for i=1:size(loc_mins,2)
        p   = [last_row, loc_mins(i)];
    %     p   = size(D);  % start with the last element
    %     n   = [size(D,1), size(D,2)]; %[n_A, n_B];
        n  = p;
        while ((n(1) > 1))
            n = n + iDec(DeltaP(n(1),n(2)),:);

            % update path (final length unknown)
            p   = [n; p];
        end   
        paths{i} = p;
    end

    % traceback from last element in matrix
%     iDec= [-1 -1; -1 0; 0 -1]; % compare DeltaP contents: diag, vert, hori
%     p   = size(D);  % start with the last element
%     n   = [size(D,1), size(D,2)]; %[n_A, n_B];
%     while ((n(1) > 1) || (n(2) > 1))
%         n = n + iDec(DeltaP(n(1),n(2)),:);
% 
%         % update path (final length unknown)
%         p   = [n; p];
%     end   
end