function [absorbtanceSpectra, absorbtanceSpectraWls] =...
	AbsorbanceToAbsorbtance(absorbanceSpectra, absorbanceSpectraWls, axialOpticalDensities)
% [absorbtanceSpectra, absorbtanceSpectraWls] =...
%   AbsorbanceToAbsorbtance(absorbanceSpectra, absorbanceSpectraWls, axialOpticalDensities)
%
% Obsolete.  Use AbsorbanceToAbsorptance, so that we can all learn to spell.
%
% This will go away sooner or later, but is here now for backwards compatibility.
%
% 12/02/13  dhb, ms  Made this a call through so that it can go away eventually.

[absorbtanceSpectra, absorbtanceSpectraWls] = ...
	AbsorbanceToAbsorptance(absorbanceSpectra, absorbanceSpectraWls, axialOpticalDensities)
