function [ w ] = ModifiedHanningWindow(L, S, varargin)
%MODIFIEDHANNINGWINDOW - Proposed by Griffin&Lim
%
% L [samples] - size of window
% S [samples] - hop size
%
    w = imq.windows.SinusoidalWindow(0.5, -0.5, pi/L, L, S, varargin{:});
    
end