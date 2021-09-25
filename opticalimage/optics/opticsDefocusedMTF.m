function OTF = opticsDefocusedMTF(s,alpha)
% Diffraction-limited MTF without aberrations but with defocus
%
%    OTF = opticsDefocusedMTF(s,alpha)
%
% The diffraction-limited MTF of a lens with a circular aperture, without
% aberrations when (a) focused (alpha = 0) and (b) defocused (alpha ~= 0).
%
% The vector s is the reduced spatial frequency, which ranges from 0 to 2.
% In the routine dlCore this is called normalizedFreq and in that routine
% it ranges from 0 to 1.  Here it ranges from 0 to 2 but otherwise appears
% to be the same.
%
% The parameter alpha is the defocus parameter; it is related to the
% defocus w20 of Hopkins. The vector alpha varies with spatial frequency.
% The formula is defined in the Marimont and Wandell paper.
%
% This function is used when calculating
%   * the effects of human chromatic aberration,
%   * understanding defocus and depth-of-field (opticsDepthDefocus).
%
% This routine is called from defocusMTF via opticsDefocusCore.
%
% See also: humanCore,opticsDefocusParameters (NYI), opticsDepthDefocus
%
% See also:  opticsDefocusCore, s_opticsDefocus
%
% See paper by Marimont and Wandell for definitions and functions.
%
% Particularly the material in  Appendix A.
%    These calculations come from the optics literature and particularly
%    Hopkins.
%
%    Other useful references are
%
%    "On the depth  information in the point spread function of a defocused
%    optical system (Subbarao, 1999)" The Subbarao paper claims there is an
%    error in the formula, but I don't think he is right.  He complains
%    about the external scale factor.  We do have a problem.  But I am not
%    sure his solution is right.
%
%    Levi and Austing, Tables of the Modulation Transfer ... (1968)
%    We should compare tables therein with this some day.
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('s'), error('Reduced spatial frequency required'); end
if ieNotDefined('alpha'), error('Alpha required'); end

% Normalized spatial frequency from reduced SF
% We always have a problem
nf = abs(s)/2;
beta = sqrt(1-(nf).^2);

% Allocate size.
OTF = zeros(size(nf));

% Calculate perfect spatial frequencies of OTF (alpha = 0)
ii = (alpha == 0);
% if sum(ii) > 0, warning('alpha zero case detected'); end
OTF(ii) = (2/pi)*(acos(nf(ii))- (nf(ii)) .* beta(ii));

% Calculate defocused spatial frequencies of OTF (alpha ~= 0)
ii = (alpha ~= 0);
H1 = (beta(ii).*besselj(1,alpha(ii)) + ...
    1/2*sin(2*beta(ii)) .* (besselj(1,alpha(ii)) - besselj(3,alpha(ii)))...
    - 1/4*sin(4*beta(ii)) .* (besselj(3,alpha(ii)) - besselj(5,alpha(ii))));

H2 =     (sin(beta(ii)) .* (besselj(0,alpha(ii)) - besselj(2,alpha(ii)))...
    + 1/3*sin(3*beta(ii)).*(besselj(2,alpha(ii)) - besselj(4,alpha(ii)))...
    - 1/5*sin(5*beta(ii)).*(besselj(4,alpha(ii)) - besselj(6,alpha(ii))));

OTF(ii) = ...
    (4./(pi*alpha(ii))).*cos(alpha(ii).*nf(ii)).*H1 - ...
    (4./(pi*alpha(ii))).*sin(alpha(ii).*nf(ii)).*H2;

% Normalize? Assuming the first entry is basically DC?
OTF = OTF/OTF(1);


return




