%% s_irSensorSimulation
%
%  UNDER DEVELOPMENT
%  Demonstrate ISET analyses using IR scene data and IR sensor
%
% Copyright ImagEval Consultants, LLC, 2010

%% Set up a scene containing infrared data
%

% These scenes can be created into the IR
% scene_types = {'MCC, EE';...
%     'ISO 12233 SFR';...
%     'Star pattern';...
%     'Choose an IR scene'};
% scene_type_index = menu('Choose simulation',scene_types);

% We will operate in the the visible + NIR regime. Note that the wavelength
% support for Option 4 ('Choose a scene') will come from the multispectral
% scene.
spectrum.wave = (400:10:1000)';
scene_type_index = 1;
switch scene_type_index
    case 1 % MCC
        patchSize = 8;
        scene = sceneCreate('macbethEE_IR',patchSize,spectrum);
    case 2 % ISO 12233
        scene = sceneCreate('slantedBar',512,7/3,spectrum.wave);
    case 3 % ISO 12233
        scene = sceneCreate('ringsrays',8,256,spectrum.wave);
    case 4 % Multispectral scene
        % Location of scene (directory and filename).
        %         scene_dir   = '';
        %         scene_name = 'ms_iset_photons_person_3_4_D65';
        %         scene_fname = fullfile(scene_dir,scene_name);
        scene_fname  = vcSelectImage('multispectral');
        scene = sceneFromFile(scene_fname,'multispectral');
end

scene_lum  = 75;       % mean luminance (candelas)
scene_fov  = 2.64;     % field of view (degrees)
scene_dist = 10;       % distance of imager from scene (m)

scene = sceneAdjustLuminance(scene,scene_lum);
scene = sceneSet(scene,'fov',scene_fov);
scene = sceneSet(scene,'distance',scene_dist);
wave  = sceneGet(scene,'wave');

% Show scene window
% vcReplaceAndSelectObject(scene); sceneWindow;


%% Optics

opt_fnumber = 4;        % f#
opt_flength = 20e-3; % 10e-3; % focal length in metres

% Initialize optics and create irradiance image of specified scene
oi     = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'fnumber',opt_fnumber);
optics = opticsSet(optics,'focallength',opt_flength);
optics = opticsSet(optics,'offaxis','skip');
oi     = oiSet(oi,'optics',optics);
oi     = oiCompute(scene,oi);

vcReplaceAndSelectObject(oi);
% Uncomment the following line to see optics window
oiWindow;

%% Sensor

% Create a color sensor, with the fourth in the IR
sensor = sensorCreate;
cfType = 'gaussian'; 
cPos = 450:100:850; width = ones(size(cPos))*35;
nFilters = length(cPos);

% blue, red, green, ir1, ir2
filterSpectra = sensorColorFilter(cfType,wave, cPos, width);
allNames = {'b1','g1','r1','x1','i2'};
filterNames = cell(1,nFilters);
for ii=1:nFilters, filterNames{ii} = allNames{ii}; end

% figure(1); plot(wave,filterSpectra)

% Create a four channel set of filters with RGB and IR
% cfType = 'gaussian'; 
% cPos   = [450:100:650, 800]; % nm
% width  = [35 35 35 45];      % nm
% filterSpectra = sensorColorFilter(cfType,wave, cPos, width);
% filterNames = {'b','g','r','w'};
% % figure(1); plot(wave,filterSpectra)

sensor = sensorSet(sensor,'wave',wave);
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'pd spectral qe',ones(size(wave)));
sensor = sensorSet(sensor,'pixel',pixel);
sensor = sensorSet(sensor,'ir filter',ones(size(wave)));
sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);
sensor = sensorSet(sensor,'pattern',[1 5 3; 2 4 2; 3 2 1]);

% sensorShowCFA(sensor);

sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
% oi = vcGetObject('oi');
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor)
sensorWindow;

% Plot a couple of lines
% sensorPlotLine(sensor,'h','volts','space',[1,115]);
% sensorPlotLine(sensor,'h','volts','space',[1,116]);
% sensorPlotLine(sensor,'h','volts','space',[1,117]);

%% END

