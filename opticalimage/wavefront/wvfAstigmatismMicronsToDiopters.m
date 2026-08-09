function diopters = wvfAstigmatismMicronsToDiopters(microns, pupilSizeMM)
% Convert astigmatism in wavefront microns to diopters.
%
% Syntax:
%   diopters = wvfAstigmatismMicronsToDiopters(microns, pupilSizeMM)
%
% Description:
%    This function is one line long, and converts astigmatism in microns to
%    astigmatism in diopters.  
%
%    The pupil size should be that used to normalize the radius of the
%    Zernike coefficients; that is the size with respect to which the
%    measurements were made.
%
% References:
%    This formula is also available at the following site.
%    https://www.telescope-optics.net/monochromatic_eye_aberrations.htm
% 
%
% Inputs:
%    microns     - The wavefront astigmatism (oblique and vertical), in microns
%    pupilSizeMM - The pupil size, in millimeters
%
% Outputs
%    diopters    - The astigmatism, in diopters
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfAstigmatismDioptersToMicrons.

% History:
%    08/05/26  NPC  Wrote it

% Examples:
%{
    diop = wvfAstigmatismMicronsToDiopters(1.5, 3.0)
%}

% Here is the forward formula from the web site listed above
diopters = (8 * sqrt(6)) * microns / (pupilSizeMM ^ 2);
end