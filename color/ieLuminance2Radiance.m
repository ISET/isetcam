function [energy, wave] = ieLuminance2Radiance(lum,thisWave,varargin)
% From a monochromatic LED luminance, compute the spectral radiance (energy)
%
% Synopsis
%   [energy, photons] = ieLuminance2Radiance(lum,thisWave,varargin)
% 
% Inputs
%   lum:       Luminance of the monochromatic light in cd/m2
%   thisWave:  Wavelength of the monochromatic light (between 350 and 720)
%
% Optional key/val pairs
%   sd:  Standard deviation of the Gaussian spread of the spectral radiance
%        (default is 10nm)
%
% Returns
%   energy:   watts/sr/nm/m2  (a vector)
%   wave:     wavelength samples (nm) of the energy vector
%
% Description
%   Many LEDs have a spectral radiance close to a Gaussian centered at some
%   wavelength. If we measure only the luminance of the LED, we can model
%   the radiance energy (watts/sr/nm/m2) as a Gaussian centered at that
%   wavelength.  We then scale the spectral radiance energy so that it has
%   the desired luminance (cd/m2).
%  
% See also
%   s_humanSafety, ieLuminanceFromEnergy, ieLuminanceFromPhotons,
%   Energy2Quanta

% Examples:
%{
   % These are unit tests.  Make a spectral radiance (energy)
   % with the peak wavelengty and Gaussian spread, as one might find for an
   % LED.  Then check that the energy of the LED model has a luminance that
   % equals the desired luminance. 

   lum = 10; thisWave = 360;
   [energy,wave] = ieLuminance2Radiance(lum,thisWave);
   assert(lum - ieLuminanceFromEnergy(energy,wave) < 1e-10)
   plotRadiance(wave,energy);
%}
%{
   lum = 100; thisWave = 425;
   energy = ieLuminance2Radiance(lum,thisWave,'sd',20);
   assert(lum - ieLuminanceFromEnergy(energy,wave) < 1e-10)
   plotRadiance(wave,energy);
%}

%% Check input parameters
p = inputParser;
varargin = ieParamFormat(varargin);
p.addRequired('lum',@isnumeric);
p.addRequired('thisWave',@(x)(x >= 350 && x <= 720));
p.addParameter('sd',10,@isnumeric);   % Standard deviation of the Gaussian radiance model

p.parse(lum,thisWave,varargin{:});
sd = p.Results.sd;

%% Model the radiance as a Gaussian centered at thisWave

wave   = 300:1:770;   % I chose a big range because we used for UV LEDs
energy = zeros(numel(wave),1);
energy(wave == thisWave) = 1;   % Set an impulse at the center wave

% Make the Gaussian and convolve the impulse
g = fspecial('gaussian',[8*sd,1],sd);
energy = conv(energy,g,'same');

% plotRadiance(wave,energy);

% Figure out the luminance of the LED model radiance
sFactor = ieLuminanceFromEnergy(energy,wave);

% Scale the model radiance to the right luminance
energy = energy * (lum/sFactor);

end

    