function settingsE = ExpandSettings(settings,nBases)
% settingsE = ExpandSettings(settings,nBases)
%
% Expand device coordinates to handle the fact that
% the device spectrum may be characterized by a 
% linear model.
%
% 10//20/93    dhb   Wrote it.

settingsE = settings;
for i = 2:nBases
  settingsE = [settingsE ; settings];
end
 
