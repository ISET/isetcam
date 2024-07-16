function sensorArray = sensorCreateArray(varargin)
% Create a sensor array
%
% Synopsis
%   sensorArray = sensorCreateArray(varargin)
%
% Brief:
%   Some image systems use a coordinated array of sensors, such as
%   split pixel and ideal.  Probably more in the future.  Make the
%   array here.  Should it be a standard array, or a cell array?
%   Currently a standard array.
%
% Input
%   arrayType - 'split pixel','ideal', ...
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
   sensors = sensorCreateArray('array type','imx490','pixel size same fill factor',1.4e-6);
%}
%{
   sensors = sensorCreateArray('array type','ovt','pixel size same fill factor',3e-6);
%}
%{
%  Straight XYZ sensor array.  Only photon noise.
   sensors = sensorCreateArray('array type','xyz');
%}
%{
%  Match the ideal to the example sensor.  No noise and XYZ filters.
   sensor = sensorCreate;
   sensors = sensorCreateArray('array type','matchxyz','sensor example',sensor);
%}
%{
% Only one sensor returned.  So not really an array.  No example
% allowed.
sensors = sensorCreateArray('array type','monochrome');
%}
%% Params

varargin = ieParamFormat(varargin);

p = inputParser;
p.KeepUnmatched = true;

validArrayTypes = {'ovt','imx490','match','matchxyz','xyz','monochrome'};

p.addParameter('arraytype','ovt',@(x)(ismember(x,validArrayTypes)));
p.addParameter('sensorexample',[],@(x)(isstruct(x) && isequal(x.type,'sensor')));

p.parse(varargin{:});

arrayType = p.Results.arraytype;

%% Switch to various implementations

% varargins that work with sensorSet.  If they start with
% 'pixel', they need to have a space following pixel. We
% eliminated spaces above.  So we put it back here.

switch arrayType
    case 'ovt'
        sensorArray = sensorCreateSplitPixel('array type','ovt',varargin{:});
    case 'imx490'
        sensorArray = sensorCreateSplitPixel(varargin{:});
    case {'match','matchxyz','xyz','monochrome'}
        % Not sure what varargins are permitted
        sensorArray = sensorCreateIdeal(arrayType,p.Results.sensorexample,varargin{:});
    otherwise
        error('Unknown array type: %s',arrayType);
end

end