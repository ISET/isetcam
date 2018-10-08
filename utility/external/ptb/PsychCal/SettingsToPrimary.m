function [primary] = SettingsToPrimary(cal,settings)
% [primary] = SettingsToPrimary(cal,settings)
% 
% Convert from device settings coordinates to
% primary coordinates by inverting
% the gamma correction.
%
% INPUTS:
%   calibration globals
%   settings -- column vectors in device settings

% 9/26/93    dhb   Added calData argument.
% 10/19/93   dhb   Allow gamma table dimensions to exceed device settings.
% 11/11/93   dhb   Update for new calData routines.
% 8/4/96     dhb   Update for stuff bag routines.
% 8/21/97    dhb   Update for structure.
% 4/5/02     dhb, ly  New calling interface.
% 8/3/07     dhb   Fix for [0-1] world.

% Get gamma table
gammaTable = cal.gammaTable;
gammaInput = cal.gammaInput;
if (isempty(gammaTable))
	error('No gamma table present in calibration structure');
end

% Check dimensions and table sizes
[m,n] = size(settings);
[mg,ng] = size(gammaTable);
if (m > ng)
  error('Mismatch between primary coordinate dimensions and gamma table');
end

% Use a search routine to find the best gamma function
primary = zeros(m,n);
for i = 1:m
  [primary(i,:)] = SearchGammaTable(settings(i,:),gammaTable(:,i),gammaInput);
end

return

% This is the old OS 9 code, which doesn't work in the 0-1 world.

% Convert settings scale from [0:max-1] to [1:max]
%settings = settings+ones(m,n);

% Invert the gamma correction:  the settings happen to be the 
% indices into the gamma table.  Inverting the gamma correction 
% amounts to returning the elements of the gamma table corresponding
% to the settings.
%primary = zeros(m,n);
%for i = 1:m
%  primary(i,:) = gammaTable(settings(i,:),i)';
%end
