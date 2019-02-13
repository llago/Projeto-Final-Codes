function [R] = Look4Matches2_lucas(musicTrackBuffer)
%
%
%
% Inputs:
%   - mixture              : mixture (reference signal) with supposed presence of an excerpt of the soundtrack
%   - musicTrackBuffer     : the soundtrack signal after being buffered, i.e, 'soundtrackBuffer' is matrix where each column has a 
%                            segment of the full soundtrack signal. The last column is concatenated with zeros.
%
%   - parameters
%        - minLandmarkMatch     : the query has to have at least "minMatchTresh" number of landmarks matched with the mixture in the 
%                                 hashtable in order to be considered 'present' in the mixture
%        - Fs                   : sampling frequency of the signals
% Output:
%   - D                    : matrix with delay information. Each row is organized as follows: 
%                                                           <index_excerpt>    <t_begin_excerpt>    <t_begin_mixture>    <excerpt_size>
%                                                           
%                                                          
%                                                           
%
% Created by: Carlos Lordelo
% Last Modified: August 2018


%% Loading Parameters
global global_Fs max_dist_between_matches_sec min_excerpt_length_sec min_excerpt_matches_perc

[~, nWindows] = size(musicTrackBuffer);
% R = zeros(nWindows,6);
R=[];
specWindow = 512; % The window size of the spectogram used in 'match_query'
overlap = 256;    % the overlap used in the spectogram
hop = specWindow - overlap;

max_dist_between_matches = max_dist_between_matches_sec*global_Fs/hop;
min_excerpt_length = min_excerpt_length_sec*global_Fs;

for i = 1:nWindows
    [r,Lh,Ld] = match_query(musicTrackBuffer(:,i),global_Fs);
    % Ld is <t1_query>      <f1_query>  <f2_query>             <t2-t1_query>
    % Lh is <t1_htable>     <f1_htable> <f2_htable>            <t2-t1_h_table>
    % r  is <songID(zero)>  <nMatches>  <t1_htable - t1_query>
    if ~isempty(r)
        
%         R(i,1) = r(2);
%         tmin_d = min(Ld(Ld(:,1) > 0,1));
%         tmin_h = min(Lh(Lh(:,1) > 0,1));
        sortedLd = sort(Ld(:,1));
%         sortedLh = sort(Lh(:,1));
        tmax_d = max(Ld(:,1));
%         tmax_h = max(Lh(:,1));
        diffLdIdx = find(diff(sortedLd) > max_dist_between_matches);
%         diffLhIdx = find(diff(sortedLh) > max_dist_between_matches);
        
        excerptsLd = [];
        excerptsLd(1,1) = sortedLd(1);
        for j = 1:size(diffLdIdx,1)
            if j == 1
                excerptsLd(j,3) = diffLdIdx(j);
            else
                excerptsLd(j,3) = diffLdIdx(j) - diffLdIdx(j-1);
            end
            excerptsLd(j,2) = sortedLd(diffLdIdx(j),1);
            excerptsLd(j+1,1) = sortedLd(diffLdIdx(j)+1,1);
        end
        
        excerptsLd(end,2) = tmax_d;
        
        if size(diffLdIdx,1) > 0
            excerptsLd(end,3) = size(Ld,1) - diffLdIdx(j);
        else
            excerptsLd(end,3) = size(Ld,1);
        end
        
%         R = [R; [zeros(size(excerptsLd,1),1)+r(2), excerptsLd(:,1), excerptsLd(:,2), excerptsLh(:,1), excerptsLh(:,2), zeros(size(excerptsLd,1),1)+i]];

% %     Convertendo de quadros para amostras
        excerptsLd(:,1) = (excerptsLd(:,1) - 1)*hop + 1;
        excerptsLd(:,2) = (excerptsLd(:,2) - 1)*hop + specWindow;
        excerptsLd = excerptsLd(excerptsLd(:,2)-excerptsLd(:,1) > min_excerpt_length,:);
        
        min_excerpt_matches = min_excerpt_matches_perc*size(Ld,1);
        excerptsLd = excerptsLd(excerptsLd(:,3) > min_excerpt_matches,:);

        %         R = [R; [zeros(size(excerptsLd,1),1)+r(2), excerptsLd(:,1), excerptsLd(:,2), zeros(size(excerptsLd,1),1)+i]];
        if size(excerptsLd,1) > 0
            R = [R; [excerptsLd, zeros(size(excerptsLd,1),1) + size(Ld,1), zeros(size(excerptsLd,1),1)+i]];
        end
    end
end

if isempty(R)
    R = zeros(1,5);
end