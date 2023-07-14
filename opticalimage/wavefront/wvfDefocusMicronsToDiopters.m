function diopters = wvfDefocusMicronsToDiopters(microns, pupilSizeMM)
% Convert defocus in wavefront microns to diopters.
%
% Syntax:
%   diopters = wvfDefocusMicronsToDiopters(microns, pupilSizeMM)
%
% Description:
%    This function is one line long, and converts defocus in microns to
%    defocus in diopters.  
%
%    The pupil size should be that used to normalize the radius of the
%    Zernike coefficients; that is the size with respect to which the
%    measurements were made.
%
%    The sign convention is that a positive number in diopters leads to a
%    positive number in microns.  Some care is required when using this
%    routine with wvfLCAFromWavelengthDifference, which has a sign
%    convention in which increased power corresponds to a negative
%    refractive error in diopters.
% 
%    See more comments in wvfDefocusDioptersToMicrons.
%
% Inputs:
%    microns     - The wavefront defocus, in microns
%    pupilSizeMM - The pupil size, in millimeters
%
% Outputs
%    diopters    - The defocus, in diopters
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    wvfDefocusDioptersToMicrons.

% History:
%    02/05/17  dhb  Wrote this as separate function.
%    11/18/17  jnm  Formatting update to match Wiki.

% Examples:
%{
    diop = wvfDefocusMicronsToDiopters(15, 4)
%}

% Here is the forward formula from the web site listed above in the
% comments to wvfDefocusDioptersToMicrons.
diopters = (16 * sqrt(3)) * microns / (pupilSizeMM ^ 2);

end