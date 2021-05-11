function vci = displaySetMaxLuminance(vci)
% Set simulated display SPD to match a peak luminance
%
%   vci = displaySetMaxLuminance(vci)
%
%   The peak luminance is set separately.  Perhaps they should never be
%   inconsistent.
%
% Example:
%  vci = displaySetMaxLuminance;
%  vci = displaySetMaxLuminance(vci)
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO:
% These should be part of displaySet() and displayGet()

if notDefined('vci'), [~, vci] = vcGetSelectedObject('VCIMAGE'); end

Yw = ipGet(vci, 'maxdisplayluminance');

maxLum = ieReadNumber('Enter desired max display luminance (Y): ', Yw, '%.2f');
if isempty(maxLum), return; end

sFactor = maxLum / Yw;
spd = ipGet(vci, 'spd');
vci = vcimageClearData(vci);
vci = imageSet(vci, 'spd', spd*sFactor);

return;
