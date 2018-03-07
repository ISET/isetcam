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

% Examples:
%{
oi = oiCreate('raytrace');
relillum = oiGet(oi,'optics rtrifunction');
wave = oiGet(oi,'optics rtriwavelength')
% Function is: relillum(fieldHeight,wave)
assert(length(wave) == size(relillum,2));  % Wave is 2nd dim
%}
%{
% Plot the curve
% surf is (X,Y,Z)
rtPlot(oi,'relative illumination');
%}

%% Retrieve the relative illumination data at this wavelength

ri = [];

% relillum(distanceMM,wave)
relillum = opticsGet(optics,'rtri function');   %mm
if isempty(relillum), return; end

% Interpolate using a nearest neighbor method.  We could interpolate, I
% suppose
wave = opticsGet(optics,'rtri wavelength');
[~,waveIdx] = min(abs(wavelength - wave));

ri = relillum(:,waveIdx);

end