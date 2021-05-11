function dpi = mperdot2dpi(mpd)
% Convert microns per dot to dots per inch
%
% Syntax:
%    dpi = mperdot2dpi(mpd)
%
% Brief description:
%   Both dots per inch (dpi) and microns per dot (mpd) are commonly used to
%   specify display pixel size. We make it easy to convert from dots per
%   inch to meters per dot.
%
% Input:
%   mpd:   Microns per dot
%
% Example:
%   mpd = dpi2mperdot(100);   % Dots per inch to microns per dot
%   dpi = mperdot2dpi(mpd)    % Back again
%
% See also
%  dpi2mperdot
%

% 1/mpd is dots per micron
% 2.54*1e4 is microns per inch
dpi = (1 / mpd) * (2.54 * 1e4); % dots per micron * meters per inch

% dpi = (1 /mpd) * (1/39.37007874015748);   % dots per micron * meters per inch

end