function figNum = macbethEvaluationGraphs(L,sensorRGB,idealRGB,sName)
% Evaluate linear fit L from sensor rgb to the ideal rgb of an MCC
%
%   figNum = macbethEvaluationGraphs(L,sensorRGB,idealRGB,sName)
%
% L: Linear transform that maps the sensor rgb into the linear rgb
%    values of the MCC.  If L is identity, the person already did the
%    computation and we are just running this routine for the graphic
%    evaluation.
% sensorRGB: Sensor RGB of the MCC in standard order where gSeries is
%            4:4:24.  Data are passed in as XW format.
% idealRGB:  Should get this from macbethIdealColor.  In XW format.
% sName:     Name of the sensor
%
% We convert the linear sRGB to sRGB and do the evaluations of the observed
% and predicted RGB, various CIELAB error terms, and chromaticity values.
%
% Key data in the graph are stored in the figure and can be acquired u sing
% get(gcf,'userData')
%
% See also: sensorCCM, macbethSensorValues
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Arguments
if ieNotDefined('L'), L = eye(3,3); end
if ieNotDefined('sensorRGB'), error('No sensor RGB data'); end
if ieNotDefined('idealRGB'),  idealRGB = macbethIdealColor('d65','lrgb'); end
if ieNotDefined('sName'),     sName = 'sensor'; end

%% Linear sensor rgb to estimated linear RGB representation of the MCC

% Figure out XYZ of the transformed sensor RGB data
rgbL     = sensorRGB*L;
rgbLSRGB = lrgb2srgb(ieClip(rgbL,0,1));

rgbLSRGB = XW2RGBFormat(rgbLSRGB,4,6);
rgbLXYZ  = srgb2xyz(rgbLSRGB);
% vcNewGraphWin; image(xyz2srgb(rgbLXYZ))

%% Convert the linear RGB to sRGB

idealSRGB = lrgb2srgb(idealRGB);
idealSRGB = XW2RGBFormat(idealSRGB,4,6);
idealXYZ  = srgb2xyz(idealSRGB);
% vcNewGraphWin; image(xyz2srgb(idealXYZ))

%% Put back into XW format, select white point

rgbLXYZ = RGB2XWFormat(rgbLXYZ);
idealXYZ = RGB2XWFormat(idealXYZ);
whiteIndex = 4;
whiteXYZ   = idealXYZ(whiteIndex,:);

%% Delta E calculation

dE = deltaEab(rgbLXYZ,idealXYZ,whiteXYZ);

%% Prepare the figure and plot
figNum =  vcNewGraphWin([],'tall');
set(figNum,'name',sName);

% Observed and predicted linear RGB
subplot(2,1,1), plot(rgbL(:),idealRGB(:),'o');
xlabel('Observed (r,g,b)'); ylabel('Desired (r,g,b)');
grid on

% CIELAB error histogram
subplot(2,1,2)
hist(dE,15);
title('Color error');
xlabel('Delta E_{ab}'); ylabel('Count');
str = sprintf('Mean dE_{ab} %.02f',mean(dE(:)));
plotTextString(str,'ur');
grid on

% Stuff the data into userData
userData.idealXYZ = RGB2XWFormat(idealXYZ);
userData.rgbLXYZ  = RGB2XWFormat(rgbLXYZ);
userData.idealRGB = idealRGB;
userData.rgbL     = rgbL;
userData.dE = dE(:);
set(gcf,'userdata',userData);

return;