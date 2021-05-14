function oi = oiAdjustIlluminance(oi,newLevel,stat)
%Scale optical image mean illuminance to meanL
%
%  oi = oiAdjustIlluminance(oi,newLevel,[stat='mean'])
%
%Purpose:
%   Adjust the (mean or max) photon level in the optical structure so that
%   the  mean illuminance level is newLevel, rather than the current level.
%   The fields oi.data.illuminance and oi.data.newLevel are updated as well.
%
% Example:
%   OI = oiAdjustIlluminance(OI,10);
%   OI = oiAdjustIlluminance(OI,100,'max');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('stat'), stat = 'mean'; end

% Get current OI illuminance
illuminance = oiGet(oi,'illuminance');

switch lower(stat)
    case {'mean'}
        currentLevel = mean(illuminance(:));
    case {'max','peak'}
        currentLevel = max(illuminance(:));
    otherwise
        errordlg('Unknown statistic');
end
s = newLevel/currentLevel;

photons = oiGet(oi,'photons');
oi = oiSet(oi,'photons',photons*s);
oi = oiSet(oi,'illuminance',illuminance*s);

end