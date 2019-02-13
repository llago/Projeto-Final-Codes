function [ w ] = ModifiedHammingWindow(L, S, varargin)
%MODIFIEDHAMMINGWINDOW - Proposed by Griffin&Lim
%
% L [samples] - size of window
% S [samples] - hop size
%
       
    w = imq.windows.SinusoidalWindow(0.54, -0.46, pi/L, L, S, varargin{:});
end