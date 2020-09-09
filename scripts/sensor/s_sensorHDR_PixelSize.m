%% Simulate a sensor that combines data from multiple pixel sizes.
%
% The simulation captures image data with a series of sensors, each has a
% different pixel size. Because all the simulated sensors have the same dye
% size, it is possible to figure out which row/col values correspond in the
% different sensors (not shown here).
% 
% An HDR algorithm might extract data data from corresponding positions in
% the different simulated sensors and integrate these values into a single
% image. 
%
% See also:  sceneFromFile, sensorCompute, ipWindow, ipCompute
%
% Copyright ImagEval Consultants, LLC, 2010

%% 
ieInit

%% Read a high dynamic range scene

fName = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs.mat');

% Read in a multispectral file with high dynamic range and a mean level of
% 200 cd/m2
[scene,fname] = sceneFromFile(fName,'multispectral',200);

% ieAddObject(scene); sceneWindow
%%  Create an optical image with the default lens parameters (f# = 2.0)
oi = oiCreate;
oi = oiCompute(scene,oi);
% ieAddObject(oi); oiWindow

%%  A series of sensors with different pixel sizes but same dye size

clear psSize;
pSize = [1 2 4];        % Microns
dyeSizeMicrons = 512;   % Microns
fillFactor = 0.5;       % Percentage of pixel containing photodector

% We will have a cell array of sensors
sensor = cell(length(pSize),1);

% The sensor will be the same as the base sensor, but we will adjust their
% pixel sizes (keeping dye size constant)
baseSensor = sensorCreate('monochrome');             % Initialize
baseSensor = sensorSet(baseSensor,'expTime',0.003);  % 3 ms exposure time

% This is the base processor image. We store the rendered image here 
baseProcessor = ipCreate;    
ip = cell(length(pSize),1);

%% Run the main  loop

% We simulate a series of monochrome sensors with different pixel sizes We
% then render the images and place them in the virtual camera image window.
% We can leaf through them and see the effects of scaling the pixel sizes.
for ii=1:length(pSize)
    
    % Adjust the pixel size (meters), constant fill
    sensor{ii} = sensorSet(baseSensor,'pixel size constant fill factor',[pSize(ii) pSize(ii)]*1e-6);

    %Adjust the sensor row and column size so that the sensor has a constant
    %field of view.
    sensor{ii} = sensorSet(sensor{ii},'rows',round(dyeSizeMicrons/pSize(ii)));
    sensor{ii} = sensorSet(sensor{ii},'cols',round(dyeSizeMicrons/pSize(ii)));

    sensor{ii} = sensorCompute(sensor{ii},oi);
    sensor{ii} = sensorSet(sensor{ii},'name',sprintf('pSize %.1f',pSize(ii)));
    ieAddObject(sensor{ii}); 
    
    ip{ii} = ipCompute(baseProcessor,sensor{ii});
    ip{ii} = ipSet(ip{ii},'name',sprintf('pSize %.1f',pSize(ii)));
    
    ieAddObject(ip{ii}); 
end


%% Look at the series of images that were created. 

% The images have different spatial resolutions and row/col sizes. This
% brings up the window.  Click around. We suggest setting the display gamma
% (text box, lower left of the window) to about 0.6
ipWindow;  

% You can extract the raw data from different sources. To read out the
% voltages from the sensor directly you can use
ii = 2;
v = sensorGet(sensor{ii},'volts');
size(v)
% The size of v is equal to the number of pixels on the sensor

% To read out the rgb data from the virtual camera image (vci) structures
% you can use
ii = 1;
dv = ipGet(ip{ii},'result');
size(dv)
% The dv are RGB images, but since they are acquired with a monochrome
% camera the RGB values are equal.

%% Show the different resolution images side by side
imageMultiview('ip',1:3,true);

%% END


