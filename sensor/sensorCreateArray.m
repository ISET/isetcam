function sensorArray = sensorCreateArray(arrayType,varargin)
% Create a sensor array
%
% Synopsis
%   sensorArray = sensorCreateArray(arrayType, varargin)
%
% Brief:
%   Some image systems use a coordinated array of sensors, such as
%   split pixel and ideal.  Probably more in the future.  Make the
%   array here.  Should it be a standard array, or a cell array?
%   Currently a standard array.
%
% Input
%   arrayType - 'split pixel','idea', ...
%
% Optional key/val pairs
%   A list of sensor parameters that apply to ALL of the sensors in
%   the array.  Or maybe we code ('N param',val) for Nth sensor,
%   parameter, value.
%
% Return
%   sensorArray - Array of sensor structs.  Not a cell array, just an
%      array, sensorArray()
%
% ieExamplesPrint('sensorCreateArray');
%
% See also
%   sensorCreate, sensorCreateSplitPixel
%

% Example:
%{
%  Split pixel, and possibility of adjusting various parameters in
%  common to the two sensors.
   sensors = sensorCreateArray('split pixel','pixel size same fill factor',1.4e-6);
%}
%{
%  Straight XYZ sensor array.  Only photon noise.
   sensors = sensorCreateArray('ideal','ideal type','xyz');
%}
%{
%  Match the ideal to the example sensor.  No noise and XYZ filters.
   sensor = sensorCreate;
   sensors = sensorCreateArray('ideal','ideal type','matchxyz','sensor example',sensor);
%}
%{
% Only one sensor returned.  So not really an array.  No example
% allowed.
sensors = sensorCreateArray('ideal','ideal type','monochrome');
%}
%% Params

varargin = ieParamFormat(varargin);
arrayType = ieParamFormat(arrayType);

p = inputParser;
p.KeepUnmatched = true;

validArrayTypes = {'splitpixel','ideal'};
p.addRequired('arrayType',@(x)(ismember(x,validArrayTypes)));

% The ideal sensors are typically arrays, though not the monochrome
% case.  They often need a sensor example, though.
validIdealTypes = {'match','matchxyz','xyz','monochrome'};
p.addParameter('idealtype','xyz',@(x)(ismember(x,validIdealTypes)))
p.addParameter('sensorexample',[],@(x)(isstruct(x) && isequal(x.type,'sensor')));

p.parse(arrayType,varargin{:});

%% Switch to various implementations

switch arrayType
    case 'splitpixel'
        % varargins that work with sensorSet.  If they start with
        % 'pixel', they need to have a space following pixel. We
        % eliminated spaces above.  So we put it back here.
        sensorArray = sensorCreateSplitPixel(varargin{:});
    case 'ideal'
        % Not sure what varargins are permitted
        sensorArray = sensorCreateIdeal(p.Results.idealtype,p.Results.sensorexample,varargin{:});
    otherwise
        error('Unknown array type: %s',arrayType);
end

end