function mtfData = ieISO12233(ip,sensor,plotOptions,masterRect,varargin)
% Calculate ISO12233 MTF from image processor data and sensor
% specification
%
% Syntax
%   mtfData = ieISO12233(ip,sensor,plotOptions,varargin);
%
% Input
%   ip - ISET image processor structure containing a slanted edge.
%      This routine tries to automatically find a good rectangular region
%      for the edge.  It then applies the ISO12233 function to the data
%      from the edge.
%
% Optional main inputs (i.e., they can be empty)
%   sensor - ISET sensor structure. Only the pixel size is needed from the
%            sensor.
%   plotOptions - 'all', 'luminance', or 'none'
%   masterRect - Use this rect from the ip data rather than trying to find
%                a rect with the ISOFindSlantedBar method.
%
% Key/val pairs
%  weight - Three weights for RGB -> Luminance ([0.213   0.715   0.072])
%  npoly - Number of polynomial coefficients for the edge approximation
%
% Output
%  mtfData - a struct with multiple slots
%        mtfData.freq and mtfData.mtf
%        mtfData.lsfx and mtfData.lsf
%        mtfData.rect the rect used for the analysis, 
%        various summary statistics (aliasing Percentage, nyquist, mtf50)
%
% Description:
%  This routine calls the ISO12233 method to calculate the MTF of the
%  system (optics and sensor).  The method can be applied to an image
%  processing window (ip), trying to find a good rectangular region for the
%  slanted bar MTF calculation. Alternatively, the rect can be sent in.
%
%  The system needs to use the pixel spacing from the sensor, which it
%  normally gets from the sensor struct.  If the sensor is not sent in,
%  then it looks in the ISET database for the currently selected sensor.
% 
%  Having the dx and the rect, it calls the ISO12233 function with the
%  plotOptions set.
%
%  In the future, we should allow a dx in millimeters to be sent in, rather
%  than the whole structure.  Also, we should allow a rect to be selected
%  visually by the user.
%
% See also:  
%   ISO12233, ISOFindSlantedBar, s_metricsMTFSlantedBar, ieISO12233v1
%

% Examples:
%{
  % Create an ip with the slanted bar and compute MTF
  scene = sceneCreate('slanted edge',512);
  scene = sceneSet(scene,'fov',5);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate;
  
  % Black edge.
  sensor = sensorSetSizeToFOV(sensor,1.5*sceneGet(scene,'fov'), oi);
  sensor = sensorCompute(sensor,oi);
  ip = ipCreate; ip = ipCompute(ip,sensor);
  ipWindow(ip);

  % Compute the MTF
  mtfData = ieISO12233(ip,sensor);
  ieDrawShape(ip,'rectangle',mtfData.rect);
  % mtfData = ieISO12233(ip,sensor);

  ieNewGraphWin; 
  plot(mtfData.lsfx*1000, mtfData.lsf);
  xlabel('Position (um)'); ylabel('Relative intensity');
  grid on;

  % If the sensor is in the database, it will be used.
  ieAddObject(sensor);
  mtf = ieISO12233(ip);
  ipWindow; h = ieDrawShape(ip,'rectangle',mtf.rect);

%}

%% Input

% These are required
if ~exist('ip','var') || isempty(ip)
    ip = ieGetObject('vcimage');
    if isempty(ip), error('No ip found.');
    else, fprintf('Using selected ip\n');
    end
end
if ~exist('sensor','var') || isempty(sensor)
    sensor = ieGetObject('sensor');
    if isempty(sensor), error('No sensor found.');
    else, fprintf('Using selected sensor\n');
    end
end
if ~exist('plotOptions','var') || isempty(plotOptions)
    plotOptions = 'all';
end

% We need to keep checking this routine.  It isn't always right, and that
% can create problems.
if ~exist('masterRect','var')
    masterRect = ISOFindSlantedBar(ip);
    if isempty(masterRect), return; end
end

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('ip',@(x)(isstuct(x) && isequal(x.type,'vcimage')));
p.addRequired('sensor',@(x)(isstuct(x) && isequal(x.type,'sensor')));
p.addRequired('plotOptions',@ischar);
p.addRequired('masterRect',@isvector);

p.addParameter('weight',[0.213   0.715   0.072],@(x)(isvector(x) && isequal(numel(x),3)));
p.addParameter('npoly',1,@isinteger);

%% Get the bar image ready.

% These data are demosaicked but not processed more.
barImage = vcGetROIData(ip,masterRect,'sensor space');
c = masterRect(3)+1;
r = masterRect(4)+1;
barImage = reshape(barImage,r,c,[]);
% ieNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray(64));

% Run the ISO 12233 code.
dx = sensorGet(sensor,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
[mtfData, fitme, esf, h]  = ISO12233(barImage, dx, [], plotOptions);

% Add the parameters to the return structure
mtfData.rect = masterRect; % [masterRect(2) masterRect(1) masterRect(4) masterRect(3)];
mtfData.esf = esf;         % Edge spread function, finely sampled, I think
mtfData.fitme = fitme;
mtfData.win = h;
end

