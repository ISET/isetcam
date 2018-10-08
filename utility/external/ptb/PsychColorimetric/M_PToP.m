function [M,dest] = M_PToP(Psource,Pdest,T,source)
% [M] = M_PToP(Psource,Pdest,T)
% [M,dest] = M_PToP(Psource,Pdest,T,source)
%
% Compute the conversion matrix between two color
% spaces with known primaries.
% The transformation requires a set of color matching
% functions to describe the observer.
%
% M - the conversion matrix
%  (n_chromacy by n_chromacy)
%
% Psource - source color primary spectral power distributions
%   (n_wavelengths by n_chromacy)
% Pdest - destination primary spectral power distributions
%   (n_wavelengths by n_chromacy)
% T - a set of color matching functions
%   (n_chromacy by n_wavelengths)
%
% OPTIONAL
% source - source tristimulus vectors
%  (n_chromacy by n_lights)
% dest - destination tristimulus vectors
%  (n_chromacy by n_lights)
%
% 8/2/94		dhb		Fixed bug in optional arg handling.

M1 = M_PToT(Psource,T);
M2 = M_TToP(T,Pdest);
M = M2*M1;

if ( nargin == 4)
  dest = M*source;
else
  dest = [];
end
