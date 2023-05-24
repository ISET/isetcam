function microns = wvfDefocusDioptersToMicrons(diopters, pupilSizeMM)
% Convert defocus in diopters to defocus in microns
%
% Syntax:
%   microns = wvfDefocusDioptersToMicrons(diopters, pupilSizeMM)
%
% Description:
%    This function is one line long, and converts defocus in diopters to
%    defocus in microns, suitable for adding into the defocus Zernike
%    coefficient But we have a lot of comments here.
%
%    The pupil size should be that used to normalize the radius of the
%    Zernike coefficients; that is the size with respect to which the
%    measurements were made.  In the wavefront code, you get this using
%      wvfGet(wvf,'measured pupil size');
%
%    The sign convention is that a positive number in diopters leads to a
%    positive number in microns. Some care is required when using this
%    routine with wvfLCAFromWavelengthDifference, which has a sign
%    convention in which increased power corresponds to a negative
%    refractive error in diopters.
%
%    About this conversion, Heidi Hofer says:
%
%       The last equation converts between the Zernike defocus coefficient
%       to a dioptric value (actually the other way), which is not specific
%       in any way to LCA.
%
%       The main consideration in doing this is that the Zernike
%       coefficients are normalized so that they have unit rms across the
%       pupil- while the dioptric value is just related to the curvature, 
%       so this makes it work out that the Zernike defocus term in microns
%       depends on pupil size for a fixed dioptric power. Larry Thibos
%       probably explains this in one of his papers, I had to sit down and
%       draw parabolas with various pupils to work it out.
%
% Inputs:
%    diopters    - Defocus, in diopters
%    PupilSizeMM - Pupil size, in millimeters
%
% Outputs:
%    microns     - Defocus, in microns
%
% Optional key/value pairs:
%    None.
%
% References:
%    This formula is also available at the following two sites.
%       http://www.telescope-optics.net/monochromatic_eye_aberrations.htm
%       http://arapaho.nsuok.edu/~salmonto/vs2_lectures/Lecture4.pdf
%
%    The first source doesn't explicitly give units of pupil diameter, but
%    it uses mm elsewhere so this is probably correct. The same formula is
%    in the second source, except for a sign difference. We assume the sign
%    to be solely a matter of convention.
%
% See Also:
%    wvfDefocusMicronsToDiopters.

% History:
%    06/05/12  dhb  Wrote this as separate function.
%    11/10/17  jnm  Formatting
%    01/10/18  jnm  Formatting update to match Wiki

% Examples:
%{
    micr = wvfDefocusDioptersToMicrons(15, 4)
%}

% Here is the forward formula from the web site listed above.
%
% diopters = (16 * sqrt(3)) * microns / (pupilSizeMM^2)

microns = diopters * (pupilSizeMM^2) / (16 * sqrt(3));

end