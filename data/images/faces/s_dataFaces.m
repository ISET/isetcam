%% s_dataFacesSpectral
%
% Illustrate how to download some of the spectral face data
%

ieWebGet('browse','spectral');

theFile = ieWebGet('resource type','spectral','resource name','CaucasianMale');
scene = sceneFromFile(theFile,'spectral');
sceneWindow(scene);

% theFile = fullfile(ieRootPath,'local','scenes','spectral','CaucasianMale.mat');
theFile = ieWebGet('resource type','faces','resource name','LoResFemale6');
face = sceneFromFile(theFile,'spectral');
face = sceneSet(face,'wave',420:10:700);

sceneWindow(face);

theLight = sceneGet(face,'illuminant photons');
[lightXW, row,col] = RGB2XWFormat(theLight);
spectrum = mean(lightXW);
wave = sceneGet(face,'wave');
plotRadiance(wave,spectrum);

faced65 = sceneAdjustIlluminant(face,'D65.mat');

