%% Illuminant correction
%
% Calculate illuminant correction matrices for a surface
% reflectance chart and collection of illuminants.  Each matrix
% converts the data obtained under a test illuminant into an
% estimate of the sensor data under a standard illuminant (D65 in
% this case).
%
% One could then transform the sensor data into a standard space,
% such as XYZ, assuming that we know the illuminant (D65).
%
% N.B.  There are still some edits to come for the part at the
% end.
%
% See also:

% Copyright ImagEval Consultants, LLC, 2016

%%
ieInit

%% Create the N-100 reflectance chart
%
% Alternatively, you can choose the scene surface reflectances
% here this way, if you want.
%
% Choose some example reflectance data
% sFiles = cell(1,2);
% sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
% sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','Food_Vhrel.mat');
%
% % Row and column size for the reflectance chart
% sSamples = [48 16];
%
% % Spatial samples for each square patch
% pSize = 20;
%
% % Create the scene, storing the specific surface samples (sSamples)
% [scene, sSamples] = sceneReflectanceChart(sFiles,sSamples,pSize);
% scene = sceneSet(scene,'name','surface chart');

scene = sceneCreate('reflectance chart');
ieAddObject(scene); sceneWindow;

%% Create an oi and a sensor

oi = oiCreate;

% Set the sensor of interest here
nikon = sensorCreate;
wave  = sensorGet(nikon,'wave');

% Load up  Nikon color filters and an infrared
nikon = sensorSet(nikon,'infrared',ieReadSpectra('infrared2',wave));
nikon = sensorSet(nikon,'color filters',ieReadSpectra('NikonD70',wave));
nikon = sensorSetSizeToFOV(nikon,sceneGet(scene,'fov'),oi);

%% Display the scene over a range of blackbody illuminants
bbodyList = (3000:1000:8500);
nIlluminant = length(bbodyList);
oIP = ipCreate;

% We could put in a transform selected by imageSensorCorrection
%    oVci = ipSet(oVci,'color conversion transform',VAL);
%    oVci = ipSet(oVci,'Sensor Correction Method','mcc optimized');
%    oVci = ipSet(oVci,'Illuminant Correction Method','gray world');
%    oVci = ipSet(oVci,'Internal CS','XYZ');

oIP = ipSet(oIP,'Transform method','adaptive');
oIP = ipSet(oIP,'conversion method Sensor ','none');
oIP = ipSet(oIP,'correction method Illuminant ','none');
oIP = ipSet(oIP,'Internal CS','sensor');

% Adjust the scene illuminant SPD and compute a series of rendered images.
vci = cell(1,nIlluminant);
for ii=1:nIlluminant
    scene = sceneAdjustIlluminant(scene,blackbody(wave,bbodyList(ii),'energy'));
    scene = sceneAdjustLuminance(scene,100);
    scene = sceneSet(scene,'name',sprintf('surface %.1f',bbodyList(ii)));
    ieAddObject(scene);   % sceneWindow;
    
    oi = oiCompute(scene,oi);
    ieAddObject(oi);      % oiWindow;
    
    nikon = sensorCompute(nikon,oi);
    ieAddObject(nikon);   % sensorWindow;
    
    vci{ii} = ipCompute(oIP,nikon);
    vci{ii} = ipSet(vci{ii},'name',sprintf('BB %d',bbodyList(ii)));
    ieAddObject(vci{ii});
end
ipWindow;

%% Now put in the transform method
% IN PROGRESS

%%