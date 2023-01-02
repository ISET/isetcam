function OTF2D = dlCore(rho,inCutFreq)
% Compute 2D diffraction limited optical transfer function
%
%    OTF2D = dlCore(rho,inCutFreq)
%
% This routine calculates the 2D optical transfer function (OTF) of a
% diffraction limited optical system.
%
% The 2D OTF depends only a few parameters.  These are the radial distance
% (rho) of each spatial frequency  from the origin, and the input cutoff
% frequency (inCutFreq) at which wavelength. The inCutFreq, in turn, only
% depends on the f# of the diffraction limited system.
%
% The variable rho is a matrix defining the frequency of each entry (cycles
% per meter).  The vector inCutFreq is the incoherent cutoff frequency as a
% function of wavelength.
%
% A little more formally, an aberration-free diffraction-limited system
% with a circular exit pupil can be described as:
%
%   di     = distance between aperture and detector (meters)
%   A      = aperture diameter  (meters)
%   lambda = wavelength of incident light (meters)
%   rho    = frequency        (cycles per meter)
%   rho0   = (A/2*lambda*di)  (cycles per meter)
%
% The formula for the OTF at frequency rho and wavelength lambda is
%
%  H(rho,lambda)
%         =(2/pi)*(acos(rho/(2*rho0)) - (rho/2*rho0)*sqrt(1-(rho/(2*rho0)^2)))
%         =(2/pi)*(acos(rho/inCutF)   - (rho/inCutF)*sqrt(1- (rho/inCutF))^2))
%      or  0                 if rho >= 2*rho0, which is rho/inCutFreq >= 1
%
% This can be simplified because 2*rho0 is the spatial cutoff frequency
%
%   inCutFreq = (A /(di * wavelength)) = 2*rho0
%
% Define the normalized frequency, rho/inCutF.
%
%    normF = rho / (A/(di*wavelength))
%
% In that case, the OTF formula becomes
%
%   H(normF,lambda) = (2/pi)*(acos(normF) - normF*sqrt((1-normF)^2))
%
% In this form, we must convert normalized frequency OTF back to real units
%
%
% Sources:
%  http://ao.osa.org/ViewMedia.cfm?id=38173&seq=0
%  Muralidhara Subbarao, APPLIED OPTICS / Vol. 29, No. 4 / 1 February 1990
%  Optical transfer function of a diffraction-limited system for polychromatic illumination
%  Also, http://www.microscopyu.com/articles/optics/mtfintro.html
%
% See also: dlMTF
%
% Copyright ImagEval Consultants, LLC, 2003.

% Number of spatial frequency and wavelength samples
[r,c] = size(rho); nWaves = length(inCutFreq);

% Pre-allocate the OTF2D.
OTF2D = zeros(r,c,nWaves);

% The OTF formula used here places DC in the center of the matrix.  We want
% DC to be in the (1,1) position, so we apply an fftshift at the last step.
for ii=1:nWaves
    normalizedFreq = rho/inCutFreq(ii);
    otf = (2/pi)*(acos(normalizedFreq) - (normalizedFreq .* sqrt(1 - normalizedFreq.^2)));
    exclude = (normalizedFreq >= 1);
    otf(exclude) = 0;
    OTF2D(:,:,ii) = ifftshift(otf); % previously OTF2D(:,:,ii) = fftshift(otf); not correct.
end

% If there is only one wavelength, return the data as a single image.
if nWaves == 1, OTF2D = squeeze(OTF2D); end

return;