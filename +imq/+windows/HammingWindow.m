function [ w ] = HammingWindow(L, S, varargin)
%HAMMINGWINDOW
%
% L - size of window
%
    zeroPhase = 1;
    alpha = 0.53836;
    beta = 1 - alpha;
    
    if nargin == 3 && varargin{1} == true
        zeroPhase = -1;
    end
        
    w = alpha - zeroPhase*beta*cos(2.*pi*[0:L-1]'/(L-1));
end