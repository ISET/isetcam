%% Increase the number of scene spatial samples
%
% The number of spatial samples in a scene is one more of its
% resolution.  Equally important is how many samples there are
% per degree of visual angle.  
%
% This routine increases the number of spatial samples by linear
% interpolation.
%
% See also:  imageIncreaseImageRGBSize
%
% (c) Imageval Consulting, LLC, 2012

%%
ieInit
delay = 0.2;

%%
scene = sceneCreate;
sceneWindow(scene); pause(delay);

%% Double the rows, triple the columns
s = [2,3];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
sceneWindow(scene); pause(delay);

%% Double the cols
s = [1,2];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
sceneWindow(scene); pause(delay);

%% Triple the cols - should return to original aspect ratio

s = [3,1];
p = sceneGet(scene,'photons');
p = imageIncreaseImageRGBSize(p,s);
scene = sceneSet(scene,'photons',p);
sceneWindow(scene); pause(delay);

%%