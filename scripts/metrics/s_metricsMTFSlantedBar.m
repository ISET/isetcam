%% The slanted Bar and ISO 12233 metric
%
% The ISO 12233 standard defines a modulation transfer function
% for assessing system acuity.
%
% This script also illustrates how to
% # define a scene
% # create an optical image from the scene
% # define a monochrome sensor
% # evaluate the sensor MTF
%
% We measure the system MTF properties using a simple slanted bar
% target along with the ISO 12233 standard methods.
%
% This script is an example of a complicated (but useful)
% calculation.  We suggest that you begin programming scripts
% using other, simpler routines.  We include this script because
% it shows many features of the scripting language and the
% ability to interact with the GUI from scripts.
%
% See also:  ISO12233, s_pixelSizeMTF, ISOFindSlantedBar,
% ieDrawShape, ipCompute
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
ieInit

%% First, create a slanted bar image.  Make the slope some uneven value
sz = 512;    %Row and col samples
slope = 7/3;
meanL = 100; % cd/m2
viewD = 1;   % Viewing distance (m)
fov   = 5;   % Horizontal field of view  (deg)

scene = sceneCreate('slantedBar',sz,slope);

% Now we will set the parameters of these various objects.
% First, let's set the scene field of view.
scene = sceneAdjustLuminance(scene,meanL);    % Candelas/m2
scene = sceneSet(scene,'distance',viewD);       % meters
scene = sceneSet(scene,'fov',fov);            % Field of view in degrees
% vcAddAndSelectObject(scene); sceneWindow;

%% Create an optical image with some default optics.
oi = oiCreate;

fNumber = 2;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'fnumber',fNumber);
oi = oiSet(oi,'optics',optics');

% Now, compute the optical image from this scene and the current optical
% image properties
oi = oiCompute(scene,oi);
% ieAddObject(oi); oiWindow;

%%  Create a default monochrome image sensor array
sensorM = sensorCreate('monochrome');   % Monocrhome sensor
sensorC = sensorCreate;                 % RGB sensor

sensorM = sensorSet(sensorM,'autoExposure',1);
sensorC = sensorSet(sensorC,'autoExposure',1);

% We are now ready to set sensor and pixel parameters to produce a variety
% of captured images. Set the rendering properties for the monochrome
% imager. The default does not color convert or color balance, so it is
% appropriate.
vci = ipCreate;

% To see the scene, optical image, sensor or virtual camera image in the
% GUI, use these commands
%    vcReplaceObject(scene); sceneWindow;
%    vcReplaceObject(oi); oiWindow;
%    vcReplaceObject(sensor); sensorWindow;
%    vcReplaceObject(vci); ipWindow;

% To determine the masterRect size, run this code and use the
% measured values of masterRect.
%
%    sensor = sensorCompute(sensor,oi);
%    vcReplaceObject(sensor);
%    vci = ipCompute(vci,sensor);
%    vcReplaceObject(vci); ipWindow;
%    [roiLocs,masterRect] = vcROISelect(vci);
%
%    masterRect = [ 27    13    35    53];   % October 2, 2010

%% Run the computation for the monochrome sensor

sensor = sensorCompute(sensorC,oi);
vcReplaceObject(sensor);
vci = ipCompute(vci,sensor);
vcReplaceObject(vci); ipWindow;

% Find a good rectangle
masterRect = ISOFindSlantedBar(vci);
h = ieDrawShape(vci,'rectangle',masterRect);

barImage = vcGetROIData(vci,masterRect,'results');
c = masterRect(3)+1;
r = masterRect(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray(64));

% Run the ISO 12233 code.  The results are stored in the window.
pixel = sensorGet(sensor,'pixel');
dx = pixelGet(pixel,'width','mm');
ISO12233(barImage, dx)

%% Should be the same, but from the ie routine

ieISO12233(vci);

%% Now for a monochrome sensor

sensor = sensorCompute(sensorM,oi);
vcReplaceObject(sensor);

vci = ipCompute(vci,sensor);
vcReplaceObject(vci); ipWindow;
h = ieDrawShape(vci,'rectangle',masterRect);
% To get rid of the bar, use:  delete(h)
% or just refresh

barImage = vcGetROIData(vci,masterRect,'results');
c = masterRect(3)+1;
r = masterRect(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray(64));

% Run the ISO 12233 code.  The results are stored in the window.
dx = sensorGet(sensor,'pixel width','mm');

% Run the code, and plot
ISO12233(barImage, dx, [], 'all');

%% Plot MTF data

% The mtfData variable contains all the information plotted in this figure.
% We graph the results again just to illustrate what is in the data
% structure.
mtfData = get(gcf,'userdata');

vcNewGraphWin;
h = plot(mtfData.freq,mtfData.mtf,'-k');
hold on
nfreq = mtfData.nyquistf;
l = line([nfreq ,nfreq],[0.1,0],'color','k');
% text((nfreq-10),0.12,newText,'color','k');
xlabel('lines/mm');
ylabel('Relative amplitude');
title('MTF');
hold off; grid on

%% END
