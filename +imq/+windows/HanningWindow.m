function [ w ] = HanningWindow(L, S, varargin)
%HANNINGWINDOW
%
% L - size of window
%
    zeroPhase = 1;
  
    if nargin == 3 && varargin{1} == true
        zeroPhase = -1;
    end
        
    w = 0.5.*(1-zeroPhase.*cos(2.*pi*(0:L-1)'/(L-1)));
    
    
end