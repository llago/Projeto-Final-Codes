function [ E] = detecthfc( S,a )

% params:
% x: input
% a: linearity (0=const, 1=linear, 2=square etc)

if nargin < 2, a = 1; end

% S = spectrogram(x,round(length(x)/(L/2)));

% S = spectrogram(x,512,512-512/4);

% S = myspectro(x,L,100);

% S = myspectro2(x,512,4);

% well, almost - adjust L
% get K frequency slots
[K L] = size(S)

% weighted energy measure

W = (linspace(1,K,K).^a)/K;
W(1) = 0; % according to Masri - to remove DC
E = zeros(1,L);

for n=1:L
    t = 0;
    for k=1:K
        t = t + W(k) * abs(S(k,n)).^2;
    end
    E(n) = t/L;
  
end

E = log(E+1);

% E = diff(E);


end

