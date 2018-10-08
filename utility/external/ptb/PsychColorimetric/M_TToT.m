function [M,dest] = M_TToT(Tsource,Tdest,source)
% [M] = M_TToT(Tsource,Tdest)
% [M,dest] = M_TToT(Tsource,Tdest,source)
%
% Compute the conversion matrix between two color
% spaces with known color matching functions.
%
% M - the conversion matrix
%  (n_chromacy by n_chromacy)
%
% Tsource - source color matching functions
%   (n_wavelengths by n_chromacy)
% Tdest - destination color matching functions
%   (n_wavelengths by n_chromacy)
%
% OPTIONAL
% source - source tristimulus vectors
%  (n_chromacy by n_lights)
% dest - destination tristimulus vectors
%  (n_chromacy by n_lights)

% Find M by solving Tdest = M Tsource
% This is equivalent to solving Tdest' = Tsource' M'
% In Matlab, X = A \ B provides the solution to A X = B
M = (Tsource' \ Tdest')';

if (nargin == 3)
  dest = M*source;
else
  dest = [];
end


