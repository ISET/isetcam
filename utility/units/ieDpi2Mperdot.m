function mpd = ieDpi2Mperdot(dpi,unit)
% Convert dots per inch microns per dot
%
%    mpd = ieDpi2Mperdot(dpi,[unit])
%
% Both dpi and microns are commonly used to specify display pixel size.
% We make it easy to convert from dots per inch to microns per dot.
%
% Example:
%   dpi = 120;
%   mpd = ieDpi2Mperdot(dpi,'um')
%   mpd = ieDpi2Mperdot(dpi)
%   mpd = ieDpi2Mperdot(dpi,'meters')
%
% See also: mperdot2dpi

if ieNotDefined('unit'), unit = 'um'; end

% (X dot/inch * inch/micron )^-1 yields microns/dot
% 2.54*1e4 microns/inch and (1/(2.54*1e4)) inch/micron
% So, dpi * inch/micron yields dots per micron
% Invert that for microns per dot
%
if ~isempty(dpi), mpd = 1 / (dpi * (1/(2.54*1e4)));
else mpd = []; 
end

% Put the value in meters and then scale according to the requested unit
mpd = mpd*10^-6;  % Meters per dot
mpd = mpd*ieUnitScaleFactor(unit);

return