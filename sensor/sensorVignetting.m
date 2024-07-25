function sensor = sensorVignetting(sensor,pvFlag,nAngles)
% Gateway routine for compute pixel vignetting structure
%
%   sensor = sensorVignetting(sensor,pvFlag)
%
% This is a gateway routine to mlAnalyzeArrayEtendue.  The pixel vignetting
% information from the microlens structure is attached to the image sensor
% array.
%
% Vignetting and in this case etendue refers to the loss of light
% sensitivity that depends on the location of the pixel with respect to the
% principal axis of the imaging lens.  The effects of vignetting are
% calculated in the microlens (ml) functions.
%
% See also: called from sensorCompute.
%           ml<TAB>, mlAnalyzeArrayEtendue(), mlGet/Set/Create, and
%           MicrolensWindow
%
% Copyright ImagEval Consultants, LLC, 2006.
%
%Examples:
%   foo = sensorVignetting; plotSensorEtendue(foo);
%   foo = sensorVignetting([],3); plotSensorEtendue(foo);
%
%   sensor = vcGetObject('sensor'); sensor = sensorSet(sensor,'vignetting',1);
%   foo = sensorVignetting(sensor); plotSensorEtendue(foo);
%
% See also
%

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('pvFlag'), pvFlag = sensorGet(sensor,'vignetting'); end
if ieNotDefined('nAngles'),nAngles=5; end

if isempty(pvFlag), pvFlag = 0; end

switch pvFlag
    case {0, 'skip'}    %skip, so set etendue to 1s
        sz  = sensorGet(sensor,'size');
        sensor = sensorSet(sensor,'etendue',ones(sz));
    case 1   %bare, nomicrolens
        sensor = mlAnalyzeArrayEtendue(sensor,'no microlens',nAngles);
    case 2   %centered
        sensor = mlAnalyzeArrayEtendue(sensor,'centered',nAngles);
    case 3  %optimal
        sensor = mlAnalyzeArrayEtendue(sensor,'optimal',nAngles);
    otherwise
        error('Unknown pvFlag %s\n',pvFlag);
end

return;