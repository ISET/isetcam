function [sensor,primaryE] = SettingsToSensorAcc(cal,settings)
% [sensor,primaryE] = SettingsToSensorAcc(cal,settings)
%
% Convert from device setting coordinates to
% sensor color space coordinates.  Uses full
% basis function measurements in doing
% conversions so that it can compensate for
% device primary spectral shifts.

% 11/12/93  dhb   Wrote it.
% 11/15/93  dhb   Added deviceE output.
% 8/4/96    dhb   Update for stuff bag routines.
% 8/21/97	dhb	  Update for structures.
% 3/10/98   dhb	  Change nBasesOut to nPrimaryBases.
% 4/5/02    dhb, ly  Update for new calling interface.
% 11/22/09  dhb   Check basis dimension and do the simple fast thing if it is 1.
%                 This will speed things up when there is no point in trying the
%                 fancier algorithm.

nPrimaryBases = cal.nPrimaryBases;
if (isempty(nPrimaryBases))
    error('No nPrimaryBases field present in calibration structure');
end

if (nPrimaryBases == 1)
    sensor = SettingsToSensor(cal,settings);
    primaryE = [];
else
    settingsE = ExpandSettings(settings,nPrimaryBases);
    primaryE = SettingsToPrimary(cal,settingsE);
    sensor = PrimaryToSensor(cal,primaryE);
end
