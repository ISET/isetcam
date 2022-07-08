%% s_dataFacesSpectral
%
% Illustrate how to download some of the spectral face data
%

ieWebGet('browse','spectral');

theFile = ieWebGet('resource type','spectral','resource name','CaucasianMale');
scene = sceneFromFile(theFile,'spectral');
sceneWindow(scene);

% theFile = fullfile(ieRootPath,'local','scenes','spectral','CaucasianMale.mat');
theFile = ieWebGet('resource type','faces','resource name','LoResFemale1');
face = sceneFromFile(theFile,'spectral');
face = sceneSet(face,'wave',420:10:700);

sceneWindow(face);

%% How to scale the level of the light
theLight = sceneGet(face,'illuminant energy');
[r,c,~] = size(theLight);

lightScale = sum(theLight,3);
ieNewGraphWin; mesh(lightScale)


%%
[lightXW, row,col] = RGB2XWFormat(theLight);
spatialScale = sum(lightXW,2);
spectrum = mean(lightXW);
wave = sceneGet(face,'wave');
plotRadiance(wave,spectrum);

%% New light
d65 = ieReadSpectra('d65',wave);   % Energy
tmp = repmat(d65',187785,1);
for ii=1:numel(spatialScale)
    tmp(ii,:) = spatialScale(ii)*tmp(ii,:);
end
newIll = XW2RGBFormat(tmp,r,c);

%%
theEnergy = sceneGet(face,'energy');

newEnergy = (theEnergy ./ theLight) .* newIll;
face = sceneSet(face,'energy',newEnergy);
face = sceneSet(face,'illuminant energy',newIll);
sceneWindow(face);

