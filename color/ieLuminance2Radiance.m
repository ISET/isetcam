function [energy, photons] = ieLuminance2Radiance(lum,wave,varargin)
% Convert the luminance of a monochromatic light to radiance (energy or
% photons)
%
% Synopsis
%   [energy, photons] = ieLuminance2Radiance(lum,wave)
% 
% Inputs
%   lum:   Luminance of the light in cd/m2
%   wave:  Wavelength of the monochromatic light
%
% Optional key/val pairs
%   bin width:  How wide is the wavelength bin width (default is 10 nm)
%
% Returns
%   energy:   watts/sr/nm/m2
%   photons:  photons/sr/nm/m2
%
% Description
%   The radiance of a monochromatic light (watts/sr/nm/m2) is scaled by the
%   V(\lambda) function and some numerical constants to return the
%   luminance in cd/m2.  This function inverts the scaling to return
%   the radiance.
%  
%   The energy can be converted into photons as well.
%
% See also
%   s_humanSafety, ieLuminanceFromEnergy, ieLuminanceFromPhotons

% Examples:
%{
   energy = ieLuminance2Radiance(100,405);
%}
%{
   lum = 100; wave = 405;
   energy = ieLuminance2Radiance(100,wave,'bin width',10);
   assert(lum == ieLuminanceFromEnergy(energy,wave))
%}
%{

%}

%% 
p = inputParser;
varargin = ieParamFormat(varargin);
p.addRequired('lum',@isnumeric);
p.addRequired('wave',@isnumeric);
p.addParameter('binwidth',10,@isnumeric);

p.parse(lum,wave,varargin{:});
binwidth = p.Results.binwidth;

%% For this wave, calculate the scale factor from radiance to luminance

sFactor = ieLuminanceFromEnergy(1,wave);

energy = lum/sFactor * (binwidth/10);

if nargout == 2
    sFactor = ieLuminanceFromPhotons(1,wave);
    photons = lum/sFactor * (binwidth/10);
end

end

    