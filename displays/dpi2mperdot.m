function mpd = dpi2mperdot(dpi,unit)
% Convert dots per inch to meters format (microns)
%
%    mpd = dpi2mperdot(dpi,[unit])
%
% Both dpi and microns are commonly used to specify display pixel size.
% We make it easy to convert from dots per inch to microns per dot.
%
% Default output is microns per dot.  For meters or cm use the optional
% unit argument (e.g., 'cm', 'm').
%
% Example:
%   dpi = 120;
%   mpd = dpi2mperdot(dpi)
%   mpd = dpi2mperdot(dpi,'um')
%   mpd = dpi2mperdot(dpi,'meters')
%   cmpd= dpi2mperdot(dpi,'cm')
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
mpd = mpd*1e-6;  % Meters per dot
mpd = mpd*ieUnitScaleFactor(unit);

return