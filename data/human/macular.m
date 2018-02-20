function t = macular(macDensity,wave)
% Returns several measures of the macular pigment
%
%     t = macular(macDensity,wave)
%
%  The human retina contains a pigment that covers the central (macular) region. 
%  This macular pigment passes certain wavelengths of light more than
%  others.  The pigment varies in density from central vision, where it is
%  highest, to increasingly peripheral vision.
%  
%  This function returns several measures of the macular pigment wavelength
%  properties as a function of macular pigment density (high in the fovea,
%  lower in the near fovea).
%
% The returned structure, t, includes a variety of derived terms.
% This should help to keep the relationship between entities straight.
%
% macDensity is the estimated (average) peak density of the pigment across
% a variety of observers.  They estimate the average (across observers)
% peak density to be 0.28, with a range of 0.17 to 0.48.
%
% t.unitDensity:   The spectral density function with a maximum value of 1.0
% t.density:       The spectral density times macDensity
% t.absorption:    The fraction of light absorbed by the pigment as a function of wavelength
% t.transmittance: The fraction of light transmitted, i.e., 1 - t.absorption
%
%  The macular densities values were taken from the Stockman site.  Go to
%  http://cvision.ucsd.edu, then click on Prereceptoral filters.
%
%  The densities were derived by Sharpe and Stockman based on some data from Bone.
%  The paper describing why they like these is in Vision Research; I
%  have downloaded the paper to Vision Science/Reference PDF/cone sensitivities
%
% Examples:
%   t = macular(0.35);
%   figure; plot(t.wave,t.transmittance)
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('wave'), wave = [400:700]'; end
t.wave = wave;
t.density  = ieReadSpectra('macularPigment.mat',wave);

% Typical peak macular density, Estimated by Sharpe in VR paper, 1999 is
% 0.28.  Yet, the data they provide are at 0.3521.  It is probably not
% important to return the unit density, but we do.
if ~exist('macDensity','var'), macDensity = 0.3521; end 

% I don't understand this, but the download from the web site has a peak
% spectral density at 460 of 0.3521, not the average estimated in the
% paper, which is 0.28. I use their value to make the data unit density.
t.unitDensity = t.density / 0.3521;

% Here is the density, given the macular density passed in.
t.density = t.unitDensity*macDensity;

% Here is the fraction transmitted through the macular pigment
t.transmittance = 10.^(-t.density);

% Here is the fraction of light absorbed by the macular pigment
t.absorption = 1 - t.transmittance;

return;


