%% Evaluating an infrared camera MTF
%
% The MTF is calculated using the slanted edge target (ISO 12233
% calculation).  This is a long (and older) version of the more
% calculation illustrated in s_metricsMTFSlantedBar.
%
% The processing steps illustrated are
%
% # Create a slanted bar scene with infrared data 
% # Convert the scene to an optical image
% # Create a sensor with 7 bands and a random spatial CFA and
% compute the virtual camera image
% # Interactively select the rectangular region and store it
% # Compute the MTF of the slanted edge target for this sensor
% and spatial CFA
%
% See also:  sceneCreate, ieReadColorFilter, ieRect2Locs,
% vcGetROIData, ISO12233
%
% Copyright ImagEval Consultants, LLC, 2010

%% 
ieInit

%% First, create a slanted bar image.  Make the slope some uneven value

sz = 512;    %Row and col samples
slope = 7/3;
meanL = 100; % cd/m2
viewD = 1;   % Viewing distance (m)
fov   = 5;   % Horizontal field of view  (deg)
wave = 400:4:1068;

scene = sceneCreate('slantedBar',sz,slope,fov,wave);

% Now we will set the parameters of these various objects.
% First, let's set the scene field of view.
scene = sceneAdjustLuminance(scene,meanL);    % Candelas/m2
scene = sceneSet(scene,'distance',viewD);     % meters
scene = sceneSet(scene,'fov',fov);            % Field of view in degrees

ieAddObject(scene);                  % Add to database
sceneWindow;


%% Create an optical image with some default optics.
oi = oiCreate;
fNumber = 4;
oi = oiSet(oi,'optics fnumber',fNumber);


% Now, compute the optical image from this scene and the current optical
% image properties
oi = oiCompute(scene,oi);
oiWindow(oi);

%% Create sensor

% Build a default sensor
sensor = sensorCreate;
wave   = sceneGet(scene,'wave');
[filterSpectra,allNames] = ieReadColorFilter(wave,'NikonD200IR.mat');

% This is a way to make artificial color filters, each with a Gaussian
% sensitivity profile. 
%    nSensors = 7; minW = 450; maxW = 800; 
%    cPos = linspace(minW,maxW,nSensors); 
%    width = ones(size(cPos))*(cPos(2)-cPos(1))/2; cfType = 'gaussian'; 
%    filterSpectra = sensorColorFilter(cfType, wave, cPos, width);
%    allNames = {'b1','g1','r1','x1','i1','z1','i2'};

% Spatial layout is 3x3 for seven sensor case.
%    p = [ 1 2 3; 4 5 6; 7 7 7];
%    sensor = sensorSet(sensor,'pattern and size',p);
%    sensorShowCFA(sensor);

nSensors    = length(allNames);
filterNames = cell(1,nSensors);
for ii=1:nSensors, filterNames{ii} = allNames{ii}; end
% vcNewGraphWin; plot(wave,filterSpectra)

% Adjusting the wavelength requires updating several fields - the
% sensor, the pixel, the photodetector QE, and the infrared
% filter.  The pixel wave is updated automatically, but it is
% necessary to also update the infrared and photodetector QE -
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);
sensor = sensorSet(sensor,'ir filter',ones(size(wave)));
% vcNewGraphWin; plot(wave,sensorGet(sensor,'irFilter'))

pixel  = sensorGet(sensor,'pixel');
pixel  = pixelSet(pixel,'pd spectral qe',ones(size(wave)));
sensor = sensorSet(sensor,'pixel',pixel);
% vcNewGraphWin; plot(wave,pixelGet(pixel,'pd spectral qe'))

% Match the sensor size to the scene FOV. Also matches the CFA size to the
% sensor (I think).
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),scene,oi);

% Compute the image and bring it up.
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;

% Plot a couple of lines
%    sensorPlotLine(sensor,'h','volts','space',[1,80]);
%    sensorPlotLine(sensor,'h','volts','space',[1,81]);

%% Create and set the processor window
vci = ipCreate;
vci = ipSet(vci,'scale display',1);
vci = ipSet(vci,'render Gamma',0.6);

% Use the linear transformation derived from sensor space (above) to
% display the RGB image in the processor window.
vci = ipSet(vci,'conversion method sensor ','MCC Optimized');
vci = ipSet(vci,'correction method illuminant ','Gray World');% 
vci = ipSet(vci,'internal CS','XYZ');

% First, compute with the default properties.  This uses bilinear
% demosaicing, no color conversion or balancing.  The sensor RGB
% values are simply set to the display RGB values.
vci = ipCompute(vci,sensor);
ipWindow(vci)

%% Define the rect for the ISO12233 calculation

% Have the user select the edge. 
masterRect = [39    25    51    65];

% It is also possible to estimate the rectangle automatically using
% ISOFindSlantedBar, which is called in ieISO12233()

%% Calculate an MTF when you choose the rectangle

roiLocs = ieRect2Locs(masterRect);

barImage = vcGetROIData(vci,roiLocs,'results');
c = masterRect(3)+1;
r = masterRect(4)+1;
barImage = reshape(barImage,r,c,3);
% figure; imagesc(barImage(:,:,1)); axis image; colormap(gray);
% pause;

dx = sensorGet(sensor,'pixel width','mm');

% Run the ISO 12233 code.  The results are stored in the window.
ISO12233(barImage, dx);

%% Compare what happens when we place an IR blocking filter in the path
[irFilter,irName] = ieReadColorFilter(wave,'IRBlocking');
% vcNewGraphWin; plot(wave,irFilter);

sensor = sensorSet(sensor,'ir filter',irFilter);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); 
% sensorImageWindow;

%% Compute the MTF with the rectangle selected automatically

vci = ipCompute(vci,sensor);
mtf = ieISO12233(vci);

% Changed from 77 to 75 on Nov. 11, 2019.  This was part of a fix of the
% ISOFindSlantedBar code that put the rect more into the center of the
% edge. 
assert(abs(mtf.mtf50 - 75) <= 3);

ieAddObject(vci); ipWindow;
h = ieDrawShape(vci,'rectangle',mtf.rect);

%% END
