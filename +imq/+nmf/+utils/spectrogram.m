function [ ] = spectrogram( Yw, L, S, F)

    M = size(Yw,1);
    N = size(Yw,2);
    n = (M-1)*S + L;
    K = ceil((N+1)/2);
    
    Y = zeros(M, K);
    
    %Only real part
    for m=1:size(Yw,1)
        Y(m, :) = abs(Yw(m, 1:K));
    end
    
    f = [0:(K-1)]*F/N;
    t = [L/2:S:n-L/2]/F;
    
    figure;
    imagesc(t, f, Y');
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
end