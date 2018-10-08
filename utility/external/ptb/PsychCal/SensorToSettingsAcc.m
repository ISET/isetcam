function [finalSettings,badIndex,quantized,perError,settings] = SensorToSettingsAcc(cal,sensor)
% [finalSettings,badIndex,quantized,perError,settings] = SensorToSettingsAcc(cal,sensor)
%
% Convert from sensor color space coordinates to device
% setting coordinates.  This routine makes use of the
% full basis function information to compensate for spectral
% shifts in the device primaries with input settings.
%
% This depends on the standard calibration globals.
%
% 11/12/93   dhb      Wrote it.
% 3/30/94	 dhb, jms Fixed logic bug in error computation.
%					  Return finalSettings as best during iteration
% 8/4/96     dhb      Update for stuff bag routines.
% 8/21/97    dhb      Update for structures.
% 3/10/98	 dhb      Change nBasesOut to nPrimaryBases.
% 4/5/02     dhb, ly  New calling interface.
% 1/26/04    ly, dhb  Get rid of unused variable called "error".
% 11/22/09   dhb      Check basis dimension and do the simple fast thing if it is 1.
%                     This will speed things up when there is no point in trying the
%                     iterative algorithm.

% Algorithm parameters
nIterations = 10;
dampingFactor = 1.0;

% Determine sizes
[nLinear,nTargets] = size(sensor);
if (nTargets ~= 1)
	error('Only handles one sensor target at a time');
end
settings = zeros(nLinear,nIterations);
quantized = zeros(nLinear,nIterations);

% Get basis information
nPrimaryBases = cal.nPrimaryBases;
if (isempty(nPrimaryBases))
	error('No nPrimaryBases field present in calibration structure');
end

if (nPrimaryBases == 1)
    [finalSettings,badIndex] = SensorToSettings(cal,sensor);
    quantized = [];
    perError = [];
    settings = [];
else
    % THINK ABOUT OUT OF GAMUT ISSUE.  THIS COMMENTED
    % OUT CODE WAS AN INITIAL STAB AT IT.
    %primary = SensorToPrimary(cal,sensor);
    %[nDevice,null] = size(primary);
    %gamut = PrimaryToGamut(cal,primary);
    %target = PrimaryToSensor(cal,gamut);
    target = sensor;
    aimfor = target;
    for i = 1:nIterations
        primary = SensorToPrimary(cal,aimfor);
        [gamut,badIndex] = PrimaryToGamut(cal,primary);
        settings(:,i) = GamutToSettings(cal,gamut);
        [tmpQuantized,primaryE] = SettingsToSensorAcc(cal,settings(:,i));
        quantized(:,i) = tmpQuantized;
        calError(:,i) = quantized(:,i) - aimfor;
        perError(:,i) = quantized(:,i) - target;
        aimfor = target - dampingFactor*calError(:,i);
    end
    
    % Find minimum error that was encountered and return those settings
    summaryError = diag(perError'*perError);
    [null,minIndex] = min(summaryError);
    finalSettings = settings(:,minIndex);
end
