%% Experiment with changing the surface reflectances in the image
%
% We use convolution by different kernels to blur the surface reflectance
% functions. The original motivation is to control the image gamut by
% blurring the reflectance functions so they become more neutral (e.g.,
% Gaussian blur).
%
% Convolving with a sharpening filter is also illustrated.  And once you
% get started, the possibility of changing the gamut by multiplying with
% with a general vector (which could be grouped into the light) also
% arises.
%
% There are many ways to change the reflectances by many other possible
% transforms that either reduce or expand the gamut in different ways.
% This script illustrates the first and simplest methods.
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% Choose a scene

% Colorful chart
s = sceneCreate('reflectance chart');
ieAddObject(s);
sceneWindow;

%%  Get the reflectance functions and blur them with a gaussian

r = sceneGet(s, 'reflectance');
[r, row, col] = RGB2XWFormat(r);

% The Gaussian  moves everything towards neutral.
% The red-green collapses much faster than the blue-yellow
g = fspecial('gaussian', [1, 9], 3);

% Blur a few times
r3 = conv2(r, g, 'same');
nLoops = 5;
for ii = 1:nLoops
    r3 = conv2(r3, g, 'same');
end
r3 = XW2RGBFormat(r3, row, col);

% Store the result
s2 = sceneAdjustReflectance(s, r3);
s2 = sceneSet(s2, 'name', 'Gaussian');
sceneWindow(s2);

%% Show the the modified scene

% You could look at the shift in the xy chromaticities this way
%
% rect = [1 1 row-1 col-1];
% scenePlot(s2,'chromaticity roi',rect);
% scenePlot(s,'chromaticity roi',rect);

% Compare the original and the desaturated
imageMultiview('scene', [1, 2], true);

%% Convolve the original reflectances with a DoG

r = sceneGet(s, 'reflectance');
[r, row, col] = RGB2XWFormat(r);

% Reflectance sharpened
g = [0, -.2, .2, .5, 2, -.2, 0];
g = g / sum(g(:));

% Repeat a small number of times
r3 = conv2(r, g, 'same');
nLoops = 2;
for ii = 1:nLoops
    r3 = conv2(r3, g, 'same');
end
r3 = XW2RGBFormat(r3, row, col);
r3 = ieClip(r3, 0, 1);
s3 = sceneAdjustReflectance(s, r3);
s3 = sceneSet(s3, 'name', 'DoG');
ieAddObject(s3);
sceneWindow;

% rect = [1 1 row-1 col-1];
% scenePlot(s3,'chromaticity roi',rect);

%%  Compare the original and the sharpened image

imageMultiview('scene', [1, 3], true);

%%