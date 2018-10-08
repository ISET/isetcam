function intensity = AiryPattern(angles,pupil,nm)
%AIRYPATTERN  Comptue the radial Airy pattern
%   intensity = AiryPattern((angles,pupil,nm)
% 
%   Compute the radial Airy pattern for diffraction by
%   a circular aperature.
%
%   "angles" visual angle in radians
%   "pupil" diameter in mm
%   "nm" is wavelength in nm
%
%   Intensity is normalized to max of 1.
%
%   Formulae from Hecht, Optics, 2cd edition, p. 419.
%
%   See also DIFFRACTIONMTF, PSYCHOPTICSTEST.

% 1/13/04  dhb  Wrote it.
% 12/27/04 dhb	Deal with case of input == 0.

% Compute radius in nm
a = (pupil/2)*10^6;

% Compute wavenumber
k = 2*pi/nm;

% Compute out airy pattern
besselarg = k*a*sin(angles);
intensity = ones(size(angles));
index = find(besselarg ~= 0);
if (~isempty(index))
		intensity(index) = abs((2*besselj(1,besselarg(index))./besselarg(index))).^2;
end
