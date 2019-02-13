[original, fs_o] = audioread('D:\Faculdade\Mono\Gururani\Dataset\Originals\04.mp3');
[sample, fs_s] = audioread('D:\Faculdade\Mono\SD_Repository\Base Teste\PFNMF_s51_puro.wav');

window = 4096; % Play around with this
hop = 1024;

% Vst = imq.STFT(mean(original, 2), @imq.windows.HammingWindow, 1024, 256, 4096);
% V = abs(Vst);
% Xst = imq.STFT(mean(original, 2), @imq.windows.HammingWindow, 1024, 256, 2048);
% X = abs(Xst);

Xo = spectrogram(original, window, window-hop);
Xs = spectrogram(sample, window, window-hop);

% [M, N] = size(V);
min = min(size(Xo));
k = 10;

[Wo, Ho] = nnmf(V, k);
[~, Ho_hypo, ~, ~, err] = PfNmf(X, Wo, [], [], [], 0, 0);

for i = 1:k
    Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
end

for i = 1:k
    Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
end

Ho_gm = geomean(Ho,1);
Ho_hypo_gm = geomean(Ho_hypo,1);

% Ho_gm = Ho_gm/norm(Ho_gm,2);
% Ho_hypo_gm = Ho_hypo_gm/norm(Ho_hypo_gm,2);

cor = xcorr(Ho_gm, Ho_hypo_gm);
figure;
plot(cor)
