% Create a simple, fluorescent scene
%
% Understand the basic functions and parameters
%
% JEF/BW Vistasoft, 2018

%% Scene and fluorophore properties

wave = 380:4:780;
deltaL = wave(2) - wave(1);
nWaves = length(wave);

% Grab one fluorophore
fName  = fullfile(isetRootPath,'data','fluorescence','phRodoRed.mat');
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


%% Read in some illuminants
fName = fullfile(fiToolboxRootPath,'camera','illuminants');
illuminant = ieReadSpectra(fName,wave);
illuminantPhotons = Energy2Quanta(wave,illuminant);
nChannels = size(illuminant,2);


%% Create a simple, standard scene and use one of the illuminants

scene = sceneCreate('macbeth',[],wave);
whichLight = 3;
scene = sceneAdjustIlluminant(scene,illuminant(:,whichLight));
ieAddObject(scene); sceneWindow;

%%  Read the scene illuminant.  We figure the fluorophore sees this, too.

illuminant = sceneGet(scene,'illuminant energy');
emission = donaldsonM * illuminant(:);
vcNewGraphWin;
plot(wave,emission);

%% Make a scene that has the emission spectrum at every location
sz = sceneGet(scene,'size');

% Make an XW format of the scene energy
sceneEnergy = repmat(emission(:)',sz(1)*sz(2),1);

% Make a random amount of the fluorophore at each location
% This qe controls the spatial structure of the scene.
fLevel = randn(sz)*0.1 + 0.5;
fLevel(:,1:48) = 0;
fLevel = RGB2XWFormat(fLevel);

% Convert multiply the emission spectrum at each point by the scalar in
% fLevel, the fluorescence emission level.
sceneEnergy = diag(fLevel(:))*sceneEnergy;
sceneEnergy = XW2RGBFormat(sceneEnergy,sz(1),sz(2));

%% Make the fluorescent scene
flScene = sceneCreate('macbeth',[],wave);
flScene = sceneSet(flScene,'energy',sceneEnergy);
ieAddObject(flScene); sceneWindow;

%% Combine the original scene with its fluorescent partner
combinedScene = sceneAdd(scene,flScene);
ieAddObject(combinedScene); sceneWindow;

%%
