[original, fs_o] = audioread('\Dataset\DTW\PFNMF_queen_4sec.wav');
[copy, fs_c] = audioread('\Dataset\DTW\PFNMF_secos_2x.wav');
[s, r] = size(original);

dur = fs_c*60;
tic;
original = mean(original, 2);
copy = mean(copy, 2);
% copy = copy(1: dur);

[orig_size, ~] = size(original);
[copy_size, ~] = size(copy);

% hop = 128;
% sizeFrame = 512;
% sizeSTFT = 4096;


window = 4096;
hop = 1024;
Vst = spectrogram(original, window, window-hop);
V = abs(Vst);
Xst = spectrogram(copy, window, window-hop);
X = abs(Xst);


k = 10;
L = 20;
N = numel(Bo(:,1));
n = 12;
Bo = cell{n};

for i=1:12
    t1 = 1:N;
    t2 = (t1)/(2^(-i/12));
    B_shift = interp1(t1, Bo, t2,'spline');
    if t1(end)<t2(end)
        B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
    end
    Bo_cell{i} = B_shift;
    

    [Wo, Ho] = nnmf(V, k);
    [~, Ho_hypo, ~, ~, err] = PfNmf(X, Wo, [], [], [], L, 0);

end


% for i = 1:k
%     Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
%     Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
% end
toc;

Ho_gm = geomean(Ho,1);
Ho_hypo_gm = geomean(Ho_hypo,1);
% 
% Ho_gm = Ho_gm./max(Ho_gm);
% Ho_hypo_gm = Ho_hypo_gm./max(Ho_hypo_gm);

% Ho_gm = Ho_gm./norm(Ho_gm,2);
% Ho_hypo_gm = Ho_hypo_gm./norm(Ho_hypo_gm,2);

cor = xcorr(Ho_gm, Ho_hypo_gm);
figure;
plot(cor)

pflag = 1;

% d_dtw2 = dtw_2(Ho_hypo_gm, Ho_gm);
% [Dist,D,k,w,rw,tw] = dtw_3(Ho_gm, Ho_hypo_gm, pflag);
save('.\Results\DTW\PFNMF_queen_seco.mat', 'Wo', 'Ho', 'Ho_hypo', 'copy_size', 'orig_size')