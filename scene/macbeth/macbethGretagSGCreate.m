%% macbethGretagSGCreate.m 
%
% A script that creates a scene data structure of the Gretag digital color
% chart SG reflectance target provided by Francisco Imai and Andy Lin July
% 2010
%
% The scene assumes a illuminant with equal energy at all wavelengths.  We
% have a chart with these color patches in the Packard lab.
%
% The user can change the illuminant in the sceneWindow.
%
% See also
%   macbethChartCreate;

%% Read and store Gretag reflectcance data from Canon
% comment = 'Gretag digital color chart SG reflectance target from Francisco Imai and Andy Lin July 2010';
% fN = ieSaveSpectralFile(spd_wave,spd_reflectance,comment,[]);

%% Create the large Gretag chart
fName = which('gretagDigitalColorSG.mat');
wave = 400:10:700;
reflectance= ieReadSpectra(fName,wave);

%% Create the chart
nWave = numel(wave);
rows  = 10;
cols  = 14;

%% Notice  we need the transpose of the reflectance below
tmp = reshape(reflectance',rows,cols,nWave);
peakR = max(tmp(:));

% Make the patches a little bigger than needed so we can put in black lines
patchSize = 30;
img = imageIncreaseImageRGBSize(tmp,patchSize);
%{
 ieNewGraphWin;
 tst = sum(img,3); imagesc(tst)
%}

%% Insert 5 black lines
nBlack = 5;
for ii=(patchSize - nBlack + 1):patchSize:(rows*patchSize)
    theseRows = ii:(ii+nBlack);
    for ww = 1:nWave
        img(theseRows,:,ww) = 0;
    end
end
%{
 ieNewGraphWin;
 tst = sum(img,3); imagesc(tst)
%}

for jj=(patchSize - nBlack + 1):patchSize:(cols*patchSize)
    theseCols = jj:(jj+nBlack);
    for ww=1:nWave
        img(:, theseCols,ww ) = 0;
    end
end
%{
 ieNewGraphWin;
 tst = sum(img,3); imagesc(tst)
%}

%% Prepend black rows and columns
new = zeros(size(img,1)+5,size(img,2)+5,nWave);
new(6:end,6:end,:) = img;
img = new;
%{
 ieNewGraphWin;
 tst = sum(img,3); imagesc(tst)
%}

%%
scene = sceneCreate;
scene = sceneSet(scene,'name','GretagSC');
scene = sceneSet(scene,'wave',wave);
scene = sceneSet(scene,'photons',img);
scene = sceneSet(scene,'knownReflectance',[img(10,10,10),10,10,10]);
scene = sceneSet(scene,'illuminantEnergy',ones(nWave,1));
scene = sceneAdjustLuminance(scene,100);

%%
sceneWindow(scene);

%% END

