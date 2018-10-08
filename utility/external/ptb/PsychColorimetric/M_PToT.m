function [M,dest] = M_PToT(Psource,Tdest,source)
% [M] = M_PToT(Psource,Tdest)
% [M,dest] = M_PToT(Psource,Tdest,source)
%
% Compute the conversion matrix between a color
% space with known primaries and one with known
% color matching functions.
%
% M - the conversion matrix
%  (n_chromacy by n_chromacy)
%
% Psource - source primaries spectral power distributions
%  (n_chromacy by n_wavelengths)
% Tdest - destination color matching functions
%  (n_chromacy by n_wavelengths)
% 
% OPTIONAL
% source - source tristimulus vectors
%  (n_chromacy by n_lights)
% dest - destination tristimulus vectors
%  (n_chromacy by n_lights)
%
% 8/2/94		dhb		Fixed variable name bug.

M = Tdest*Psource;

if ( nargin == 3)
  dest = M*source;
else
  dest = [];
end

