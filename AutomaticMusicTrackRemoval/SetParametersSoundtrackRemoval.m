
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Set Parameters for Filter Coefficient %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% and Variable Gain Estimation %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% Author: Carlos Lordelo
% Last modified: Jun/2018

%% Defining the Audio Files and Sampling Frequency
%MIXTURE_FILE = './AudioFiles/AvenidaBrasil/testReal1.wav';
% MUSICTRACK_FILE = '\Dataset\PFNMF_cilor_puro_longo.wav';       
% MUSICTRACK_FILE = '\Dataset\Gururani\Originals\07.mp3';
% MIXTURE_FILE = '\Dataset\y2mate.com - beyonce_crazy_in_love_ft_jay_z_ViwtNLUqkMY.mp3';
% MIXTURE_FILE = '\Dataset\Gururani\Copied\07.mp3';
%DATA_FILE = '../AudioFiles/data.wav';                           
%MIXTURE_FILE = './AudioFiles/mixtureExcerptCompressedAlpha4_faixa10.WAV';
%MIXTURE_FILE = './AudioFiles/Cap1_begin_short.wav';
% [~, Fs1] = audioread(MIXTURE_FILE);
% [~, Fs2] = audioread(MUSICTRACK_FILE);

global global_Fs excerptWindowSize_sec overlapDetection_perc max_dist_between_matches_sec min_excerpt_length_sec min_excerpt_matches_perc

global_Fs = 48000;
totalIterations = 1;

%% Parameters used to detect the soundtrack on the mixture signal
excerptWindowSize_sec = 16;                         % size of the excerpt to be searched in the mixture file (in sec)
overlapDetection_perc = 0.5;                        % the whole soundtrack is divided in segments of this length

max_dist_between_matches_sec = 1.2; % em segundos   % maximum distance between matched landmarks to form a excerpt
min_excerpt_length_sec = 0.4; % em segundos           % minimum length of a excerpt
min_excerpt_matches_perc = 0.3;                     % porcentagem minima do total de landmarks encontrados por janela do buffer 
                                                    % que um trecho deve ter 
tolerance = 0.3;                                    % tolerancia para considerar um trecho encontrado como correto, em porcentagem 
                                                    % do tamanho do sample
amount_songs = 40;                                  % quantidade de musicas testadas      
                                               


