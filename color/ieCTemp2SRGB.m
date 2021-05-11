function sRGB = ieCTemp2SRGB(cTemp, varargin)
% Convert spd in energy units into an sRGB value for a display
%
%    srgb = ieCTemp2RGB(cTemp,wave)
%
% Description:
%   Convert a blackbody radiator color temperature into an sRGB value.
%
% Inputs:
%   cTemp: The color temperature
%
% Optional key/value pairs
%   wave:  Wavelength samples, default is 400:10:700
%
% Returns:
%   sRGB:  Three RGB values
%
% Copyright SCIEN Stanford, 2018
%
% See also
%   ieXYZFromEnergy

% Examples:
%{
sRGB = ieCTemp2SRGB(8000)
sRGB = ieCTemp2SRGB(5000)
sRGB = ieCTemp2SRGB(3000)
%}
%{
wave = 400:10:700;
sRGB = ieCTemp2SRGB(3000,'wave',wave)
%}

%%
p = inputParser;
p.addRequired('cTemp', @isscalar);
p.addParameter('wave', (400:10:700), @isvector);
p.parse(cTemp, varargin{:});

wave = p.Results.wave;

%%
energy = blackbody(wave, cTemp, 'energy');
% vcNewGraphWin; plot(wave,energy);

XYZ = ieXYZFromEnergy(energy(:)', wave);
XYZ = XW2RGBFormat(XYZ, 1, 1);

sRGB = xyz2srgb(XYZ);
sRGB = RGB2XWFormat(sRGB);

end
