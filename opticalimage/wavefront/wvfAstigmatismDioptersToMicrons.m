function microns = wvfAstigmatismDioptersToMicrons(diopters, pupilSizeMM)
% Convert astigmatism in diopters to wavefront microns .
%
% Syntax:
%   microns = wvfAstigmatismDioptersToMicrons(diopters, pupilSizeMM)
%
% Description:
%    This function is one line long, and converts astigmatism in diopters
%    to astigmatism in microns.  
%
%    The pupil size should be that used to normalize the radius of the
%    Zernike coefficients; that is the size with respect to which the
%    measurements were made.
%
% References:
%    This formula is the inverse of the forward formula available at the following site.
%    https://www.telescope-optics.net/monochromatic_eye_aberrations.htm
% 
%
% Inputs:
%    diopters    - The wavefront astigmatism (oblique and vertical), in diopters
%    pupilSizeMM - The pupil size, in millimeters
%
% Outputs
%    microns    - The astigmatism, in microns
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfAstigmatismMicronsToDiopters.

% History:
%    08/05/26  NPC  Wrote it

% Examples:
%{
    microns = wvfAstigmatismDioptersToMicrons(2, 3.0)
%}

% Here is the inverse of the forward formula from the web site listed above
microns = diopters / (8*sqrt(6)) * (pupilSizeMM ^ 2);
end