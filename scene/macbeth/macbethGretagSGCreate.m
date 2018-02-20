%% macbethGretagSGCreate.m 
%
%Create a scene data structure of the Gretag digital color chart SG
%reflectance target from Francisco Imai and Andy Lin July 2010
%
% The scene assumes a illuminant with equal energy at all wavelengths. 
% The user can change the illuminant using the GUI
%   Scene>Edit>Adjust SPD>Change Illuminant) 
% or by using a script
%   s_changeIlluminant.m in the ISET-4.0/scripts/scene directory
%
% In the future we should make this a function that accepts 
%   reflectance, wavelength, number of rows, number of cols, size of
%   patch, width of black lines
% And we should define a format for Excel spreadsheet data which we can
% read in using this script
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Read and store Gretag reflectcance data from Canon
% comment = 'Gretag digital color chart SG reflectance target from Francisco Imai and Andy Lin July 2010';
% fN = ieSaveSpectralFile(spd_wave,spd_reflectance,comment,[]);

%% Create the large Gretag chart
fName = fullfile(isetRootPath,'data','surfaces','gretagDigitalColorSG.mat');
[reflectance wave]= ieReadSpectra(fName);

%% Create the chart
nWave = 36;
rows  = 10;
cols  = 14;

%% Notice  we need the transpose of the reflectance below
tmp = reshape(reflectance',rows,cols,nWave);
peakR = max(tmp(:));

% Make the patches a little bigger than needed so we can put in black lines
patchSize = 30;
img = imageIncreaseImageRGBSize(tmp,patchSize);
% tst = sum(img,3); imagesc(tst)

%% Insert 5 black lines
nBlack = 5;
for ii=(patchSize - nBlack + 1):patchSize:(rows*patchSize)
    theseRows = ii:(ii+nBlack);
    for ww = 1:nWave
        img(theseRows,:,ww) = 0;
    end
end
% tst = sum(img,3); imagesc(tst)
for jj=(patchSize - nBlack + 1):patchSize:(cols*patchSize)
    theseCols = jj:(jj+nBlack);
    for ww=1:nWave
        img(:, theseCols,ww ) = 0;
    end
end
% tst = sum(img,3); imagesc(tst)
%% Prepend black rows and columns
new = zeros(size(img,1)+5,size(img,2)+5,nWave);
new(6:end,6:end,:) = img;
img = new;

%%
scene = sceneCreate;
scene = sceneSet(scene,'name','GretagSC');
scene = sceneSet(scene,'wave',wave);
scene = sceneSet(scene,'photons',img);
scene = sceneSet(scene,'knownReflectance',[img(10,10,10),10,10,10]);
scene = sceneSet(scene,'illuminantEnergy',ones(nWave,1));
scene = sceneAdjustLuminance(scene,100);
%%
ieAddObject(scene);
sceneWindow

%%
% interpolate scene
wave = 400:10:700;
scene = sceneInterpolateW(scene,wave,1);
ieAddObject(scene);
sceneWindow
%%
% save gretagDigitalColorSGscene scene

