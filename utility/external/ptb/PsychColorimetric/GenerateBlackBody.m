function [spd] = GenerateBlackBody(T,wls_in)
% [spd] = GenerateBlackBody(T,wls_in)
%
% Generate spectral power distributions for black body radiators.
% Generated according to formula in W+S, pp. 11-12.
% We compute output as radiant exitance in units of W m-2 nm-1.
% 
% INPUT
%   T - row vector of desired temperaturs in Kelvin.
%   wls_in - column vector of wavelengths.
%
% OUTPUT
%   spd - the spectral power distributions are in the columns.

% Allocate space
[null,n] = size(T);
[m,null] = size(wls_in);
spd = zeros(m,n);

% Fundamental constants
h = 6.626176e-34;			% J - sec
c = 2.99792458e8;		 % M - sec
k = 1.380662e-23;	  % J - K^-1

% Convert wavelengths to meters
wls = wls_in * 1e-9;

% Compute exponential term
expterm = 1 ./ (exp( ((h/k)*c) ./ (wls*T) ) - 1);

% Compute leading term
leadterm = 8*pi*h*c*(wls * ones(1,n)).^(-5);

% Compute output
spd = leadterm .* expterm;

% Convert from radiant energy to radiant exitance
spd = (c/4) * spd;

% Convert spectral density from m-1 to nm-1
spd = spd * 1e-9;

