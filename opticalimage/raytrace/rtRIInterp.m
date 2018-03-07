function ri = rtRIInterp(optics,wavelength)
% Interpolate the relative illumination data
%
%   ri = rtRIInterp(optics,wavelength)
%
% Description:
%  Return the relative illumination function at the specified wavelength.
%  These values are stored in the optics.rayTrace.geometry subfields.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  rtGeometry

ri = [];

% relillum(distance,wave)
relillum = opticsGet(optics,'rtrifunction');   %mm
if isempty(relillum), return; end

% Uterpolate using a nearest neighbor method.  We could interpolate, I
% suppose
wave = opticsGet(optics,'rtriwavelength');
[~,waveIdx] = min(abs(wavelength - wave));

% Hunh?  The comments here are odd.
ri = relillum(:,waveIdx);    % Incorrect
% ri = relillum(waveIdx,:);  %Corrected

end