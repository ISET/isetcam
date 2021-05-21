% v_saveImage:
%
% Validate the xxSaveImage functions
%
% Not well done, yet
%
%

%%
ieInit
chdir(fullfile(isetRootPath,'local'))

%% We save the image data from various windows to a file
scene = sceneCreate;
camera = cameraCreate;
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');

%%
fName = 'deleteMe';
sceneWindow(scene);
outputPNG = sceneSaveImage(scene,fName);
img = imread(outputPNG);
ieNewGraphWin; image(img);
delete(outputPNG);

%%
ip = cameraGet(camera,'oi');
outputPNG = oiSaveImage(ip,'deleteMe');   % PNG is appended
img = imread(outputPNG); ieNewGraphWin; image(img);
delete(outputPNG);

%% No sensor case implemented (yet)

%% Image processing window
ip = cameraGet(camera,'ip');
showImageFlag = true; trueSizeFlag = true;
fName = ipSaveImage(ip,'deleteMe',showImageFlag,trueSizeFlag);   % PNG is appended

img = imread(fName);
ieNewGraphWin; image(img);
delete(fName);

%% END