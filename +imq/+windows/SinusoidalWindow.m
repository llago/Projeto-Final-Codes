function [ w ] = SinusoidalWindow(a, b, phi, L, S, varargin)
%SINUSOIDALWINDOW 
%
% "Signal Estimation from Modified Short-Time Fourier Transform"
% by Daniel W. Griffin and Jae S. Lim
% Equation (9) and (11)

if(L/S ~= 4)
    error('It is necessary that L = 4*S');
end

wr = sqrt(S/L) * ones(L, 1);

w = 2*wr./sqrt(4*a^2 + 2*b^2).*(a + b*cos(2*pi.*(0:(L-1))/L + phi))';
    
end