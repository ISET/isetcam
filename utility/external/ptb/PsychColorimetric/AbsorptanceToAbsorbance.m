function [absorbanceSpectra, absorbanceSpectraWls] =...
    AbsorptanceToAbsorbance(absorptanceSpectra, absorptanceSpectraWls, axialOpticalDensities, NORMALIZE)
% [absorbanceSpectra, absorbanceSpectraWls] =...
%   AbsorptanceToAbsorbance(absorptanceSpectra, absorptanceSpectraWls, axialOpticalDensities, [NORMALIZE])
%
% This code inverts AbsorbanceToAbsorptance.  You might want to do this if you were trying
% to take cone fundamentals and back down all the way to the component parts, so that you
% could for example vary the axial density and recompute the fundamentals.
%
% The absorbance/absorptance terminology is described at the
% CVRL web page, http://cvrl.ucl.ac.uk.  Wyszecki and Stiles refere to absorbance
% the absorption coefficient (p. 588).
%
% Both absorptance spectra and absorbance spectra describe quantal absorption.
%
% Absorbance spectra are normalized to a peak value of 1.
% Absorptance spectra are the proportion of quanta actually absorbed.
%
% Equation: absorptanceSpectra = 1 - 10.^(-OD * absorbanceSpectra)
%
% Multiple spectra may be passed in the rows of absorbanceSpectra.  If
% so, then the same number of densities should be passed in the vector
% axialOpticalDensities, and multiple answers are returned in the rows
% of absorptanceSpectra.
%
% NORMALIZE (default true) causes this routine to normalize the returned absorbances to
% have a maximum of 1.
%
% Note, we now have ways of building up most fundamentals that we care about
% from constituant parts, and thus probably don't need to do that.  See
%   CIEConeConeFundamentlsTest, ComputeCIEConeFundamentals, DefaultPhotoreceptors, FillInPhotoreceptors,
%   IsomerizationsInEyeDemo.
%
% Originally written by HH, Copyright HH, Vista Lab, 2010
%
% 8/11/13  dhb  Moved into PTB, modified comments so as not to refer to non-PTB routines.
%          dhb  That this actually inverts is tested in IsomerizationsInEyeDemo.
% 12/02/13 dhb  Fix spelling of "absorptance" in routine names and throughout.


% Some arg checks
if ~exist('absorptanceSpectra','var'); help AbsorptanceToAbsorbance; return; end
if ~exist('axialOpticalDensities','var'); disp('axialOpticalDensities is required.'); return; end
if ~exist('absorptanceSpectraWls','var'); absorptanceSpectraWls = []; end
if ~exist('NORMALIZE','var'); NORMALIZE = true; end

% Convert each entry
for i = 1:size(absorptanceSpectra,1)
    % Normalize absorptanceSpectance so that returned absorbance has peak of 1, no matter what
    % normalization was applied to the absorptance spectrum.  
    if (NORMALIZE)
        absorptanceSpectra(i,:) = absorptanceSpectra(i,:) ./ max(absorptanceSpectra(i,:)) * (1-10^-axialOpticalDensities(i));
    end
    
    % Invert the absorbance to absorptance computation
    absorbanceSpectra(i,:) = (- 1 ./ axialOpticalDensities(i)) .* log10(absorptanceSpectra(i,:) - 1);
end

% Deal with some possible numerical error
absorbanceSpectra = real(absorbanceSpectra); % remove small value of imaginary number

% Pass wavelengths back through
absorbanceSpectraWls = absorptanceSpectraWls;

