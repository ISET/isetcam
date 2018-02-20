function  [integrationTime,maxSignalVoltage,smallOI] = autoExposure(OI,sensor,level,aeMethod)
%Gateway routine to auto-exposure methods
%
%     [integrationTime,maxSignalVoltage,smallOI] = autoExposure(OI,sensor,[level = 0.95],[aeMethod])
%
%  Find an integration time (sec) that will produce a voltage at a
%  fraction (0 < level < 1) of the voltage swing.  The data used to set
%  the level are from the signal current image plus the dark current
%  image.
%
%   The currently implemented methods are
%
%     {'default'}     - Calculate only for point with highest luminance
%     {'luminance'}   - Full computation of the response
%     {'aeFull'}      - 
%     {'aeCFA'}       - 
%     {'aeSpecular'}  - A certain percentage can be saturated
%
% The default method finds the signal voltage for a one sec exposure of the
% portion of the optical image with peak illuminance.  The exposure routine
% then returns an integration time that produces a value of "level" times
% the voltage swing.  
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO: This routine needs to be expanded to include the other methods.
% Good opportunities for matrix-metering with weighted matrices, and
% perhaps other ideas.

if ieNotDefined('level'), level = 0.95; end
if ieNotDefined('aeMethod'), aeMethod = 'default'; end

switch lower(aeMethod)
    case 'default'
        [integrationTime,maxSignalVoltage,smallOI] = aeLuminance(OI,sensor,level);
    case 'luminance'
        [integrationTime,maxSignalVoltage] = aeFull(OI,sensor,level);
    case 'cfa'
        [integrationTime,maxSignalVoltage] = aeCFA(OI,sensor,level);  
    case 'specular'
        [integrationTime,maxSignalVoltage] = aeSpecular(OI,sensor,level);  
    otherwise
        error('Unknown auto-exposure method')
end

return;

%---------------------------
function [integrationTime,maxSignalVoltage] = aeFull(OI,sensor,level)
% Finds the maximum signal voltage for a one sec exposure, and then returns
% an integration time that produces a value of level times the voltage
% swing. 
%
% This is not as useful as aeSpecular, below, we think.

% Sensor may come in with a different itegration time than 1 second, so we
% need to re-set it.
sensor = sensorSet(sensor,'integrationTime',1);
voltageSwing = sensorGet(sensor,'pixel voltage swing');

signalVoltage = sensorComputeImage(OI,sensor);
maxSignalVoltage = max(signalVoltage(:));
integrationTime = (level * voltageSwing )/ maxSignalVoltage;

return;

%---------------------------
function [integrationTime,maxSignalVoltage,smallOI] = aeLuminance(OI,sensor,level)
% This method extracts the brightest part of the image and sets the
% integration time so that the brightest part is at a fraction of
% saturation.
%
% Because this method only calculates using a small portion of the image,
% it is a lot faster than computing the full image.  It is, however, not
% possible to use with real imagers.  We will be writing other algorithms
% to evaluate auto-exposure routines that can be implemented in real
% hardware.

voltageSwing = sensorGet(sensor,'pixel voltage swing');

% Find the brightest pixel in the optical image
smallOI = oiExtractBright(OI);

% The number of sensors must match the CFA format of the color sensor
% arrays.  So we choose a size that is an 8x multiple of the cfa pattern.
smallISA = sensorSet(sensor,'size',8*sensorGet(sensor,'cfaSize'));

% We clear the data as well.
smallISA = sensorClearData(smallISA);
smallISA = sensorSet(smallISA,'integrationTime',1);     % Exposure is 1 sec

sensorFOV = sensorGet(smallISA,'fov',[],OI);
% Now, treat the small OI as a large, uniform field that covers the sensor
smallOI = oiSet(smallOI,'wangular',2*sensorFOV);

% Compute the signal voltage for this small part of the image sensor array,
% using the brightest part of the opticl image, and a 1 sec exposure
% duration. (Generally, the voltage at 1 sec is larger than the voltage
% swing.)
%

signalVoltage = sensorComputeImage(smallOI,smallISA);
maxSignalVoltage = max(signalVoltage(:));

% Determine the integration time by figuring how large the voltage was. The
% voltage swing is in volts. We figure out how to set the integration time
% so that the maximum signal voltage will be level*voltageSwing.
integrationTime = (level * voltageSwing )/ maxSignalVoltage;

return;

%-------------------------
function [integrationTime,maxSignalVoltage] = aeCFA(OI,sensor,level)
% Based on aeFull. Finds the maximum signal voltage for a one sec exposure
% for each filter type in the CFA and returns integration times that 
% produces a value of level times the voltage swing for each position 

PIXEL = sensorGet(sensor,'pixel');
voltageSwing  = pixelGet(PIXEL,'voltageSwing');

filterOrder   = sensorGet(sensor,'pattern');
[nRows,nCols] = size(filterOrder);

integrationTime  = zeros(nRows,nCols);
maxSignalVoltage = zeros(nRows,nCols);

sensor = sensorSet(sensor,'integrationTime',1);

signalVoltage = sensorComputeImage(OI,sensor);

% Find maximum voltage and integration time separately for each position in
% the CFA
for jj = 1:nRows
    for kk = 1:nCols
                
        tmp = signalVoltage(jj:nRows:end, kk:nCols:end);
                
        maxSignalVoltage(jj,kk) = max(tmp(:));
        integrationTime(jj,kk)  = (level*voltageSwing)/maxSignalVoltage(jj,kk);
        
    end
end

return

%-------------------------
function [integrationTime,maxSignalVoltage] = aeSpecular(oi,sensor,level)
% When a scene has a small region with a specular highlight, say
% comprising a small fraction of the total pixels, we want to set
% the exposure without worrying about the specular image region.
%
% This algorithm allows you to ignore a percentage of the pixels
% and set the exposure duration so that the remaining pixels
% reach near the voltage swing.
%
% To allow 5 percent to be saturated, set level to 0.95.
%
% iTime = autoExposure(oi,sensor,0.95,'specular');

voltageSwing = sensorGet(sensor,'pixel voltage swing');

% No noise and one sec exposure
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorSet(sensor,'exp time',1);

% Not clipped
signalVoltage = sensorComputeImage(oi,sensor);

% Percentile level is between 0 and 100
targetVoltage = prctile(signalVoltage(:),level*1e2);

integrationTime = (voltageSwing/targetVoltage);

maxSignalVoltage = max(signalVoltage(:));

return

