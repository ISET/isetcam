function  [integrationTime,maxSignalVoltage,smallOI] = autoExposure(oi,sensor,level,aeMethod,varargin)
% Gateway routine to auto-exposure methods
%
% TODO: ***
%   There is an issue when using the IMX363 sensor (and thus maybe the
%   IMX490 sensor).  See comments in isetvalidation/iset/sensor
%   scripts.  Adjusted for aeLuminance here, but not for the other
%   methods.
%
% Syntax:
%   [integrationTime,maxSignalVoltage,smallOI] = autoExposure(oi,sensor,[level = 0.95],[aeMethod='default'],varargin)
%
% Brief Description:
%  Find an integration time (sec) for the optical image and sensor. The
%  default method produces a voltage level at a fraction (0 < level < 1) of
%  the voltage swing.  The data used to set the level are from the signal
%  current image plus the dark current image.
%
%  There are additional exposure methods that can be specified using the
%  aeMethod argument.
%
% Inputs:
%  oi:       The optical image
%  sensor:   The sensor
%  level:    Fraction of the voltage swing (default is 0.95)
%  aeMethod: Which method, default is 'luminance'.  See full set of
%            options below.
%
% Optional key/value pairs
%  centerrect:  Central rectangle for 'center' method
%
% Outputs:
%   integrationTime:  In seconds
%   maxSignalVotage:
%   smallOI:
%
%  The currently implemented methods are
%
%     'default'     - The default method finds the signal voltage
%                     for a one sec exposure of the portion of the
%                     optical image with peak illuminance.  The
%                     exposure routine then returns an integration
%                     time that produces a value of "level" times the
%                     voltage swing. (aeLuminance)
%     'luminance'   - Same as default (aeLuminance)
%     'full'        - Finds the maximum signal voltage for a one sec
%                     exposure, and then returns an integration time
%                     that produces a value of 'level' times the
%                     voltage swing (aeFull)
%     'specular'    - Make the mean voltage level a fraction of
%                     voltage swing. (aeSpecular)
%     'cfa'         - Compute separately for each color filter type
%     'mean'        - Finds the sensor intergration time to achieve
%                     the desired mean voltage level expressed as a
%                     fraction of the voltage swing (aeMean). For example
%                     setting level of 0.3 means that
%
%                     mean(signalVoltage(:)) = 0.3*voltageSwing
%
%      'weighted'   - Set the exposure duration as in 'luminance', but
%                     using a rect from the center of the image
%                     (aeWeighted).
%      'video'      - Same as weighted, but a maximum exposure time
%                     sent in by a videomax parameter (default 1/60 s)
%                     aeVideo).
%      'hdr'        - Like Specular, but clips from high and low to
%                     possibly provide a better baseline for hdr processing
%
% See also
%    sensorCompute

% Examples:
%{
scene = sceneCreate; 
oi = oiCreate; oi = oiCompute(oi,scene); 
% oiWindow(oi); ieROISelect(oi);
rect = [50   35   28   19];
sensor   = sensorCreate;
sensor   = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
eTime  = autoExposure(oi,sensor,0.90,'weighted','center rect',rect);
sensor = sensorSet(sensor,'exp time',eTime);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);
sz = sensorGet(sensor,'size');
sensorPlot(sensor,'volts hline',[1, sz(1)]);
%}
%{
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
sensor   = sensorCreate;
eTime  = autoExposure(oi,sensor,0.90,'video');
%}
%{
scene  = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate;
rect = [50   35   28   19];
eTime  = autoExposure(oi,sensor,0.90,'video','center rect',rect,'video max',1/60);
sensor = sensorSet(sensor,'exp time',eTime);
sensor = sensorCompute(sensor,oi);
sz     = sensorGet(sensor,'size');
sensorPlot(sensor,'volts hline',[1, sz(1)]);
%}

%% Parse arguments          

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addRequired('sensor',@(x)(isequal(x.type,'sensor')));
p.addRequired('level',@isscalar);
p.addRequired('aemethod',@ischar)

% Optional Key/val Parameters
p.addParameter('centerrect',[],@isvector);
p.addParameter('videomax',1/60,@isscalar);   % Maximum exposure duration sec
p.addParameter('numframes',1,@isscalar);   % 

p.parse(oi,sensor,level,aeMethod,varargin{:});
centerRect = p.Results.centerrect;
videoMax   = p.Results.videomax;
numFrames  = p.Results.numframes; % for autohdr

switch lower(aeMethod)
    case 'specular'
        [integrationTime,maxSignalVoltage] = aeSpecular(oi,sensor,level);
    case {'luminance', 'default'}
        % Extracts brightest part of the image and sets the exposure
        % duration to just below saturation for that part.
        [integrationTime,maxSignalVoltage,smallOI] = aeLuminance(oi,sensor,level);
    case 'full'
        [integrationTime,maxSignalVoltage] = aeFull(oi,sensor,level);
    case 'cfa'
        [integrationTime,maxSignalVoltage] = aeCFA(oi,sensor,level);
    case {'mean'}
        [integrationTime,maxSignalVoltage] = aeMean(oi,sensor,level);
    case {'weighted','center'}
        integrationTime = aeWeighted(oi,sensor,level,'centerrect',centerRect);
    case 'video'
        integrationTime = aeVideo(oi,sensor,level,'center rect',centerRect,'videomax',videoMax);
    case 'hdr' % Experimental to get base exposure for hdr scenes
        [integrationTime,maxSignalVoltage] = aeHDR(oi,sensor,level, numFrames);
        
    otherwise
        error('Unknown auto-exposure method')
end

end

%---------------------------
function [integrationTime,maxSignalVoltage,smallOI] = aeLuminance(OI,sensor,level)
% The default autoexposure method.
%
% Extracts the brightest part of the image (oiExtractBright) and sets the
% integration time so that the brightest part is at a fraction of voltage
% swing.
%
% Because this method only calculates the voltages for a small portion of
% the image (the brightest)), it is a lot faster than computing the full
% image. We are not sure if in practice only the brightest part can be
% extracted.
%
% See also
%   oiExtractBright

voltageSwing = sensorGet(sensor,'pixel voltage swing');

% Find the brightest pixel in the optical image.  Not a typical method.
smallOI = oiExtractBright(OI);

% The number of sensors must match the CFA format of the color sensor
% arrays.  So we choose a size that is an 8x multiple of the cfa pattern.
smallSensor = sensorSet(sensor,'size',8*sensorGet(sensor,'cfaSize'));

% We clear the data as well.
smallSensor = sensorClearData(smallSensor);
smallSensor = sensorSet(smallSensor,'integrationTime',1);     % Exposure is 1 sec

sensorFOV = sensorGet(smallSensor,'fov',[],OI);
% Now, treat the small OI as a large, uniform field that covers the sensor
smallOI = oiSet(smallOI,'wangular',2*sensorFOV);

% Compute the signal voltage for this small part of the image sensor array
% using the brightest part of the opticl image, and a 1 sec exposure
% duration. (Generally, the voltage at 1 sec is larger than the voltage
% swing.)

% {
 % For the IMX363 there is a difference between this method and the
 % sensorComputeImage method. Why?
 %
 % Allow the voltage to swing very high.  Calculate how high for 1
 % sec. Find the max and divide out.
 smallSensor   = sensorSet(smallSensor,'pixel voltage swing',1e6);
 smallSensor   = sensorCompute(smallSensor,smallOI);
 signalVoltage = sensorGet(smallSensor,'volts');
% }

% This has been standard for a long time.  But see above comment.
% signalVoltage = sensorComputeImage(smallOI,smallSensor);

maxSignalVoltage = max(signalVoltage(:));

% Determine the integration time by figuring how large the voltage was. The
% voltage swing is in volts. We figure out how to set the integration time
% so that the maximum signal voltage will be level*voltageSwing.
integrationTime = (level * voltageSwing )/ maxSignalVoltage;

end

%---------------------------
function [integrationTime,maxSignalVoltage] = aeFull(OI,sensor,level)
% Finds the maximum signal voltage for a one sec exposure, and then
% returns an integration time that produces a value of 'level' times
% the voltage swing.
%
% This is not as useful as aeSpecular, below, we think.

% Sensor may come in with a different itegration time than 1 second, so we
% need to re-set it.
sensor       = sensorSet(sensor,'integrationTime',1);
voltageSwing = sensorGet(sensor,'pixel voltage swing');

% These are the signal voltages and the max
signalVoltage    = sensorComputeImage(OI,sensor);
maxSignalVoltage = max(signalVoltage(:));

% With this integration time, the max voltage will be equal to a fraction
% (level) of the voltage swing.
integrationTime  = (level * voltageSwing )/ maxSignalVoltage;

end

%---------------------------
function [integrationTime, maxSignalVoltage] = aeMean(OI,sensor,level)
% Finds the sensor integration time to achieve the desired mean voltage
% level expressed as a fraction of the voltage swing. For example setting
% level of 0.3 means that mean(signalVoltage(:)) = 0.3*voltageSwing

% Sensor may come in with a different itegration time than 1 second, so we
% need to set it locally.
sensor = sensorSet(sensor,'integrationTime',1);
sensor = sensorSet(sensor,'analogGain',1);

% This is the peak voltage
voltageSwing = sensorGet(sensor,'pixel voltage swing');

% These are the voltages for this OI and sensor
signalVoltage = double(sensorComputeImage(OI,sensor));

% This is the mean
meanVoltage = mean(signalVoltage(:));

% With this integration time, the mean voltage will be a fraction (level)
% of the voltage swing.
integrationTime = (level * voltageSwing )/ meanVoltage;

if nargout == 2
    maxSignalVoltage = integrationTime*max(signalVoltage(:));
end

end


%-------------------------
function [integrationTime,maxSignalVoltage] = aeCFA(OI,sensor,level)
% Finds the maximum signal voltage for a one sec exposure for each filter
% type in the CFA and return the integration times that produce a value of
% level times the voltage swing for each position
%
% Based on aeFull.

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

end

%-------------------------
function [integrationTime,maxSignalVoltage] = aeSpecular(oi,sensor,level)
% When a scene has a small region with a specular highlight, say
% comprising a small fraction of the total pixels, we want to set
% the exposure without worrying about the specular image region.
%
% This algorithm allows you to ignore a percentage of the pixels and
% set the exposure duration so that the remaining pixels reach near
% the voltage swing.
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

% Percentile level is between 0 and 100.  That is why we multiply level by
% 100.
targetVoltage = prctile(signalVoltage(:),level*1e2);

integrationTime = (voltageSwing/targetVoltage);

maxSignalVoltage = max(signalVoltage(:));

end

%-------------------------
function [integrationTime,maxSignalVoltage] = aeHDR(oi,sensor,level,numFrames)
% Try to find a way to estimate a good "base" exposure for scenes
% with much higher dynamic range than the sensor, for use with
% computational imaging approached such as burst and bracket
%
% iTime = autoExposure(oi,sensor,0.95,'hdr');

% voltageSwing = sensorGet(sensor,'pixel voltage swing');

% No noise and one sec exposure
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorSet(sensor,'exp time',1);

% Not clipped
signalVoltage = sensorComputeImage(oi,sensor);

% Percentile level is between 0 and 100.  That is why we multiply level by
% 100.
maxTargetVoltage = prctile(signalVoltage(:),level*1e2);
minTargetVoltage = prctile(signalVoltage(:),(1-level)*1e2);

% Limit our band to our target voltages
vSwing = maxTargetVoltage - minTargetVoltage;

if numFrames > 1
    minTime = vSwing/maxTargetVoltage;
    maxTime = vSwing/minTargetVoltage;
    % return an array of times
    integrationTime = minTime:round(maxTime-minTime/numFrames):maxTime;
else
    integrationTime = (vSwing/(maxTargetVoltage-minTargetVoltage));    
end

maxSignalVoltage = max(signalVoltage(:));

end


%-------------------------------
function [integrationTime, maxSignalVoltage] = aeWeighted(oi,sensor,level,varargin)
% Choose a region of the image, defined by the center rect.
% if rect is empty, the entire image is used.
%
% This default seems to apply to various exposure routines in this
% function.

varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;  % In video case, we have another parameter

p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addRequired('sensor',@(x)(isequal(x.type,'sensor')));
p.addRequired('level',@isscalar);
p.addParameter('centerrect',[],@(x)(isvector(x) || isempty(x)));

p.parse(oi,sensor,level,varargin{:});

% This is the selected part of the OI.
rect = p.Results.centerrect;
if isa(rect,'images.roi.Rectangle'), rect = int32(rect.Position); end
if isempty(rect), centerOI = oi;
else, centerOI = oiCrop(oi,rect);
end

% Cut down the sensor size, turn off noise and set to 1 s exposure time
smallSensor = sensorSetSizeToFOV(sensor,oiGet(centerOI,'fov'),oi);
smallSensor = sensorSet(smallSensor,'noise flag',0);
smallSensor = sensorSet(smallSensor,'exp time',1);
smallSensor = sensorClearData(smallSensor);

% Store the voltage swing
voltageSwing = sensorGet(smallSensor,'pixel voltage swing');

signalVoltage    = double(sensorComputeImage(centerOI,smallSensor));
maxSignalVoltage = max(signalVoltage(:));

% Find the integration time
integrationTime = (level*voltageSwing/maxSignalVoltage);

end

%-------------------------------
% http://hamamatsu.magnet.fsu.edu/articles/readoutandframerates.html
function integrationTime = aeVideo(oi,sensor,level,varargin)
% The video exposure time model treats the rolling shutter as irrelevant,
% rather acting as a global shutter. See the specialized scripts for
% simulating rolling shutter. 
%
% If the center rect is empty, the entire image is used.

% Force lower case and no spaces
varargin = ieParamFormat(varargin);

p = inputParser;
p.KeepUnmatched = true;  % In video case, we have another parameter

p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addRequired('sensor',@(x)(isequal(x.type,'sensor')));
p.addRequired('level',@isscalar);

% Empty means use the whole image
p.addParameter('centerrect',[],@(x)(isvector(x) || isempty(x)));
p.addParameter('videomax',1/60,@isscalar);   % Maximum exposure duration sec

p.parse(oi,sensor,level,varargin{:});

% This is the selected rect of the OI.
rect     = p.Results.centerrect;

% Longest permissible time
videomax = p.Results.videomax;

integrationTime = aeWeighted(oi,sensor,level,'center rect',rect);
integrationTime = min(videomax,integrationTime);

end
