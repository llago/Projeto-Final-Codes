function [Ho, Ho_hypo_cell] = get_Hos(sample, suspect, sample_no, suspect_no, fs1, fs2, contador) 

    tic;
    
    targetFS = 44100;
    if(fs1 ~= targetFS)
        sample = resample(sample,targetFS,fs1);
    end
    if(fs2 ~= targetFS)
        suspect = resample(suspect,targetFS,fs2);
    end
       
    sample = mean(sample, 2);
    suspect = mean(suspect, 2);
    
%     if nargin > 4
%         duration = fs*dur_sec;
%         if duration < size(suspect,2)
%             suspect = suspect(1: duration);
%         end
%     end
    
    window = 4096;
    hop = 1024;
    Vst = spectrogram(sample, window, window-hop);
    V = abs(Vst);
    Xst = spectrogram(suspect, window, window-hop);
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

    elapsedTime = toc;


    % for i = 1:k
    %     Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
    %     Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
    % end

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

    save(['.\Results\DTW\Complete_durations_PFNMF\', num2str(contador), '_Suspect_', num2str(suspect_no),  '_Sample_',  num2str(sample_no),  '.mat'], 'targetFS', 'Ho', 'Ho_hypo_cell', 'Bo_cell', 'window', 'hop', 'k', 'L', 'sample', 'suspect', 'suspect_no', 'sample_no', 'elapsedTime')
end