%% v_displayLUT
%
%
%

%%
ieInit

%%  Read an 8bit RGB file and return some photons.

fName = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
photons = vcReadImage(fName,'rgb');

%% Read an 8-bit RGB file.  With a 10-bit gamma table.

photons = vcReadImage(fName,'rgb','OLED-Sony.mat');
vcNewGraphWin; imagesc(photons(:,:,10))

%%
scene = sceneFromFile(fName,'rgb',100,'OLED-Sony.mat');
vcAddAndSelectObject(scene); sceneWindow;

%% Try putting in numerical data

img = rand(128,128,3);
scene = sceneFromFile(img,'rgb',100,'OLED-Sony.mat');
vcAddAndSelectObject(scene); sceneWindow;


%% Add more cases here to check

%% END
