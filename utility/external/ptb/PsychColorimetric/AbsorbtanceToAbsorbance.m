function [absorbanceSpectra, absorbanceSpectraWls] =...
    AbsorbtanceToAbsorbance(absorbtanceSpectra, absorbtanceSpectraWls, axialOpticalDensities, NORMALIZE)
% [absorbanceSpectra, absorbanceSpectraWls] =...
%   AbsorbtanceToAbsorbance(absorbtanceSpectra, absorbtanceSpectraWls, axialOpticalDensities, [NORMALIZE])
%
% Obsolete.  Use AbsorptanceToAbsorbance, so that we can all learn to spell.
%
% This will go away sooner or later, but is here now for backwards compatibility.
%
% 12/02/13  dhb, ms  Made this a call through so that it can go away eventually.

% Some arg checks
if ~exist('absorbtanceSpectra','var'); help AbsorbtanceToAbsorbance; return; end
if ~exist('axialOpticalDensities','var'); disp('axialOpticalDensities is required.'); return; end
if ~exist('absorbtanceSpectraWls','var'); absorbtanceSpectraWls = []; end
if ~exist('NORMALIZE','var'); NORMALIZE = true; end

[absorbanceSpectra, absorbanceSpectraWls] =...
    AbsorptanceToAbsorbance(absorbtanceSpectra, absorbtanceSpectraWls, axialOpticalDensities, NORMALIZE)

