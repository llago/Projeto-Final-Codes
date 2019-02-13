function [excerpts] = get_excerpts(suspect_file, original_file)

% tic;
% clear all; 

%% Loading some important parameters for the analysis
global global_Fs excerptWindowSize_sec overlapDetection_perc

%% Reading the Mixture and the Music-track Files
[mixture, Fs1] = audioread(suspect_file);
mixture = mean(mixture, 2);
[musicTrack, Fs2] = audioread(original_file);
musicTrack = mean(musicTrack, 2);

mixture = resample(mixture,global_Fs,Fs1);
musicTrack= resample(musicTrack,global_Fs,Fs2);

%% Saving the mixture landmarks in a HASH-Token Matrix used for delay estimation 
clear_hashtable;
H = landmark2hash(find_landmarks(mixture,global_Fs)); 
save_hashes(H);

%% Creating a buffered version of the filtered version of the music-track (dividing in small segments)
non_zero_idxs = find(musicTrack(end:-1:1) ~= 0);
last_non_zero = size(musicTrack,1) - non_zero_idxs(1,1) + 1;
musicTrack = musicTrack(1:last_non_zero);
excerptWindowSize = round(excerptWindowSize_sec*global_Fs);
overlapDetection  = round(overlapDetection_perc*excerptWindowSize);

musicTrackBuffer = buffer(musicTrack,excerptWindowSize, overlapDetection, 'nodelay');     % Do not use overlap   

%% Looking for segments of the filtered music-track with more than 'minLandmarkMatch' landmark matches with the mixture
excerpts = Look4Matches2_lucas(musicTrackBuffer);  
% toc;

% for i = 1:size(excerpts,1)
%     excerpt = musicTrackBuffer(excerpts(i,1):excerpts(i,2),excerpts(i,5));
%     soundsc(excerpt, 48000);
% end
% % Passando para amostras absolutas (removendo buffer)
buffer_hop = overlapDetection;
if overlapDetection == 0
    buffer_hop = excerptWindowSize;
end
excerpts(:,1) = excerpts(:,1)+(excerpts(:,5)-1)*buffer_hop;
excerpts(:,2) = excerpts(:,2)+(excerpts(:,5)-1)*buffer_hop;

% soundsc(musicTrack(excerpts(i,1):excerpts(i,2)), 48000);


end