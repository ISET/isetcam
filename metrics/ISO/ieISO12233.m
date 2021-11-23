function [mtfData, lsf] = ieISO12233(ip,sensor,plotOptions,masterRect)
%Calculate ISO12233 MTF from an image processor and sensor
%
% Syntax
%   [mtfData, lsf] = ieISO12233(ip,sensor,plotOptions);
%
% Required inputs
%   ip - ISET image processor structure containing a slanted edge .
%   This routine tries to automatically find a good rectangular region for
%   the edge.  It then applies the ISO12233 function to the data from the
%   edge.
%
% Optional inputs
%   sensor - ISET sensor structure. Only the pixel size is needed from the
%            sensor.
%   plotOptions - 'all', 'luminance', or 'none'
%
% Returns
%  mtfData    - a structure with several slots that includes the MTF
%      data, the LSF data, the rect used for tha analysis, and some
%      summary statistics
%  lsf        - line spread function
%
% Description:
%
%  This routine tries to find a good rectangular region for the slanted
%  bar MTF calculation. It then applies the ISO12233 function to the
%  data from the edge.  The routine fails when it cannot automatically
%  identify an appropriate slanted bar region.
%
%  The sensor pixel size is needed.  If the sensor is not sent in as a
%  parameter, then we look for the currently selected sensor in the
%  database. In the future, we should allow a dx in millimeters to be
%  sent in, rather than the whole structure.  Also, we should allow a
%  rect to be selected visually by the user.
%
% See also:  
%   ISO12233, ISOFindSlantedBar, s_metricsMTFSlantedBar
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
if ~exist('ip','var') || isempty(ip)
    ip = vcGetObject('vcimage');
    if isempty(ip), error('No ip found.');
    else, fprintf('Using selected ip\n');
    end
end
if ~exist('sensor','var') || isempty(sensor)
    sensor = vcGetObject('sensor');
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
mtfData = ISO12233(barImage, dx, [], plotOptions);
mtfData.rect = masterRect; % [masterRect(2) masterRect(1) masterRect(4) masterRect(3)];

end

