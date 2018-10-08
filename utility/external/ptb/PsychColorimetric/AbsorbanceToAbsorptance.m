function [absorptanceSpectra, absorptanceSpectraWls] =...
	AbsorbanceToAbsorptance(absorbanceSpectra, absorbanceSpectraWls, axialOpticalDensities)
% [absorptanceSpectra, absorptanceSpectraWls] =...
%   AbsorbanceToAbsorptance(absorbanceSpectra, absorbanceSpectraWls, axialOpticalDensities)
%
% Convert pigment absorbance spectra into absorptance spectra, using the peak axial
% optical density.  The absorbance/absorptance terminology is described at the
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
% Wavelength information may be in any of the available Psychtoolbox representations,
% and the returned wavelength information is in the same format as passed.
%
% A useful fact about this conversion is the following.  For small axial optical densities
% the absorptance spectrum is a scaled version of the absorbance spectrum.  This follows
% if we take the Taylor expansion of 1 - 10.^(-x) for small values of x.  We find that
% that is 1 - (10^0 + (-ln(10)*x) = ln(10)*x.  Plugging in OD*absorbanceSpectra for x
% we get the absorptanceSpectra = ln(10)*OD*absorbanceSpectra.
%
%
% 04/29/03 lyin 	Wrote wrote with advice from dhb
% 04/30/03 lyin 	Reorganize the variable
% 06/12/03 lyin 	Change the way variable being passed
% 06/23/03 dhb		Check dimensions of spectra and density.
% 06/30/03 dhb      Change to toolbox convention, put sensitivity like stuff in rows.
% 08/11/13 dhb      Fix comment to reflect row convention change made in 2003.  Slowly but surely we fix things up.
% 10/29/13 dhb, ms  Add commment about absorptance for low OD.
% 12/02/13 dhb      Fix spelling of "absorptance" in routine names and throughout.

% Check that dimensions match properly
if (size(absorbanceSpectra,1) ~= length(axialOpticalDensities))
	error('Number of spectra does not match number of densities');
end

% Equation: absorptanceSpectra = 1 - 10.^(-OD * absorbanceSpectra)
absorptanceSpectra = 1 - 10.^(-diag(axialOpticalDensities)*absorbanceSpectra);

% Wls of absorptanceSpectra
absorptanceSpectraWls = absorbanceSpectraWls;
