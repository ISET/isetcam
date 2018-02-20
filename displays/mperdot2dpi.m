function dpi = mperdot2dpi(mpd,unit)
% Convert dots per inch to size in microns per dot
%
%    dpi = mperdot2dpi(mpd,[unit])
%
% Both dpi and microns are commonly used to specify display pixel size.
% We make it easy to convert from dots per inch to meters per dot.  
%
% By specifying the unit, you can also have values returned as mm per dot or
% microns per dot.  The units are 'mm','um','m','cm'
%
% Example:
%   dpi = mperdot2dpi(254,'mm')
%   dpi = mperdot2dpi(300,'um')
%   dpi = mperdot2dpi(.300,'cm')
%   dpi = mperdot2dpi(.300,'mm')
%   dpi = mperdot2dpi(.300,'um')
%
% See also dpi2mperdot
%

if ieNotDefined('unit'), unit = 'meters'; end

% 1/mpd is dots per micron
% 2.54*1e4 is microns per inch
% 2.54*1e-2 ~ (1/39.37007874015748) is meters per inch
dpi = (1 /mpd) * (1/39.37007874015748); 

dpi = ieUnitScaleFactor(unit)*dpi;

return