function ri = rtRIInterp(optics,wavelength)
%Interpolate the relative illumination data
%
%   ri = rtRIInterp(optics,wavelength)
%
% Return the relative illumination function at the specified wavelength.
% These values are stored in the optics.rayTrace.geometry subfields.
%
% Copyright ImagEval Consultants, LLC, 2003.

ri = [];

relillum = opticsGet(optics,'rtrifunction');   %mm
if isempty(relillum), return; end
wave = opticsGet(optics,'rtriwavelength');

% Use a nearest neighbor method.  We could interpolate, I suppose
[~,waveIdx] = min(abs(wavelength - wave));

ri = relillum(:,waveIdx); %Incorrect
% ri = relillum(waveIdx,:);  %Corrected

end