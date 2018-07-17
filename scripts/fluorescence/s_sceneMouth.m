% Create a simple, fluorescent scene
%
% Understand the basic functions and parameters
%
% JEF/BW Vistasoft, 2018

%%
ieInit

%% Read in some illuminants

%{
% This is where HB stored a bunch of illuminants
 fName = fullfile(fiToolboxRootPath,'camera','illuminants');
 illuminant = ieReadSpectra(fName,wave);
 illuminantPhotons = Energy2Quanta(wave,illuminant);
 nChannels = size(illuminant,2);
%}

fName = fullfile(oreyeRootPath,'data','CheekMucosa','InnerCheekMucosa_1.jpg');
lName = fullfile(oreyeRootPath,'data','CheekMucosa','InnerCheekMucosa_1_Cheek.jpg');
illuminantName = fullfile(isetRootPath,'data','lights','blueLEDFlood.mat');

%%

scene = sceneFromFile(fName,'rgb');
scene = sceneAdjustIlluminant(scene,'blueLEDFlood.mat',10);   % 100 cd/m2
scene = sceneSet(scene,'name','Cheek mucosa');
ieAddObject(scene); sceneWindow;

%% Get a fluorophore

wave = 380:4:780;
deltaL = wave(2) - wave(1);
nWaves = length(wave);

% Grab one fluorophore
% pHrodoRed
% PacificOrange
fName  = fullfile(isetRootPath,'data','fluorescence','pHrodoRed.mat');
fl  = fiReadFluorophore(fName,'wave',wave);

vcNewGraphWin;
semilogy(wave,fl.emission,'k-')
xlabel('Wave (nm)'); ylabel('Relative emission');

%%
donaldsonM = fluorophoreGet(fl,'donaldson matrix');

vcNewGraphWin;
imagesc(wave,wave,donaldsonM);
xlabel('Wave (nm)'); ylabel('Wave (nm)');
grid on; set(gca,'YColor',[0.8 0.8 0.8]);
set(gca,'XColor',[0.8 0.8 0.8])

%%  Read the scene illuminant.  We figure the fluorophore sees this, too.

illuminant = sceneGet(scene,'illuminant energy');
emission = donaldsonM * illuminant(:);
vcNewGraphWin;
plot(wave,emission);

%% Make a scene that has the fluorescence emission spectrum at every location
sz = sceneGet(scene,'size');

% Make an XW format of the scene energy
sceneEnergy = repmat(emission(:)',sz(1)*sz(2),1);

% Make a random amount of the fluorophore at each location
% This qe controls the spatial structure of the scene.
fLevel = randn(sz)*0.1 + 0.5;
fLevel = RGB2XWFormat(fLevel);

% Convert multiply the emission spectrum at each point by the scalar in
% fLevel, the fluorescence emission level.
sceneEnergy = bsxfun(@times, fLevel(:), sceneEnergy);

%% Now only put the fluorescence in the right place

% We read just one label now.  In the future, for this same image, we will
% have multiple labels.  We might create a scene.label slot.  We could
% combine the different labels into an image and save it in the scene.label
% slot. Then we would build utilities to show them.s
cheek = imread(lName);  % An RGB file
vcNewGraphWin; imagesc(cheek);

cheek = RGB2XWFormat(cheek);
cheekLabel = double(cheek(:,1));

% We might scale the cheekLabel by the luminance of the underlying RGB
% image
luminance = sceneGet(scene,'luminance');
luminance = ieScale(luminance,1);
luminance = RGB2XWFormat(luminance);
cheekLabel = luminance .* cheekLabel;

sz = sceneGet(scene,'size');
vcNewGraphWin; imagesc(XW2RGBFormat(cheekLabel,sz(1),sz(2)));

sceneEnergy = bsxfun(@times, cheekLabel(:), sceneEnergy);

%% Now put it back into RGB format

sceneEnergy = XW2RGBFormat(sceneEnergy,sz(1),sz(2));

%% Make the fluorescent scene
flScene = sceneCreate('default',[],wave);
flScene = sceneSet(flScene,'name','PacificBlue fluorophore');
flScene = sceneSet(flScene,'energy',sceneEnergy);
flScene = sceneAdjustLuminance(flScene,10);  % cd/m2  TO be managed by qe
% ieAddObject(flScene); sceneWindow;

%% Combine the original scene with its fluorescent partner
combinedScene = sceneAdd(scene,flScene);
combinedScene = sceneSet(combinedScene,'name','pHrodoRed');
ieAddObject(combinedScene); sceneWindow;

%%

