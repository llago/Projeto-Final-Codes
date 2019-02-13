[original, fs_o] = audioread('\Dataset\original_5_mais_curto.mp3');
[copy, fs_c] = audioread('\Dataset\Gururani\Copied\05.mp3');
[s, r] = size(original);

dur = fs_c*40;
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

[Bo, Ho] = nnmf(V, k);

n=12;
L = 20;
N = numel(Bo(:,1));
Bo_cell = cell(n,1);
Ho_hypo_cell = cell(n,1);
for i=-6:5
    t1 = 1:N;
    t2 = (t1)/(2^(-i/12));
    B_shift = interp1(t1, Bo, t2,'spline');
    if t1(end)<t2(end)
        B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
    end
    Bo_cell{i+7} = B_shift;
    [~, Ho_hypo_cell{i+7}, ~, ~, err] = PfNmf(X, B_shift, [], [], [], L, 0);

end


% for i = 1:k
%     Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
%     Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
% end
toc;

% Ho_gm = geomean(Ho,1);
% Ho_hypo_gm = geomean(Ho_hypo,1);
% 
% Ho_gm = Ho_gm./max(Ho_gm);
% Ho_hypo_gm = Ho_hypo_gm./max(Ho_hypo_gm);

% Ho_gm = Ho_gm./norm(Ho_gm,2);
% Ho_hypo_gm = Ho_hypo_gm./norm(Ho_hypo_gm,2);

% cor = xcorr(Ho_gm, Ho_hypo_gm);
% figure;
% plot(cor)

pflag = 1;

% d_dtw2 = dtw_2(Ho_hypo_gm, Ho_gm);
% [Dist,D,k,w,rw,tw] = dtw_3(Ho_gm, Ho_hypo_gm, pflag);
save('.\Results\DTW\PFNMF_Gururani_5_complete.mat', 'Wo', 'Ho', 'Ho_hypo_cell', 'copy_size', 'orig_size')