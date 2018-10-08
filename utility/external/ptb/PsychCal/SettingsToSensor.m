function [sensor] = SettingsToSensor(cal,settings)
% [sensor] = SettingsToSensor(cal,settings)
%
% Convert from device setting coordinates to
% sensor color space coordinates.
%
% 9/26/93    dhb   Added cal argument.
% 4/5/02     dhb, ly  Update for new interface.

primary = SettingsToPrimary(cal,settings);
sensor = PrimaryToSensor(cal,primary);
