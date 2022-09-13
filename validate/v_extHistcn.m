%% v_extHistcn
%
% Test the 2D histogram image function histcn and scatplot
%
% This function probably has more capabilities.  For now we use it for
% taking a scatter plot and turning it into an image.
%
% BW, Copyright Imageval Consulting, LLC, 2015

ieInit

%% Get a local image
fname  = 'hats.jpg';
ffname = fullfile(isetRootPath,'data','images','rgb',fname);
img    = imread(ffname);

%% Make a scatter plot image intensity of the r and g channels
r = img(:,:,1);
g = img(:,:,2);
X = double([r(:), g(:)]);
[N, ~,mid] = histcn(X);

vcNewGraphWin;
imagesc(mid{1:2},N(:,:));
axis xy; colormap(hot(64)); colorbar
xlabel('Red channel'); ylabel('Green channel')
title(sprintf('%s: Channel image histogram',fname))

%% RB
r = img(:,:,1);
b = img(:,:,3);
X = double([r(:), b(:)]);
[N, ~, mid] = histcn(X);

vcNewGraphWin;
imagesc(mid{1:2},N(:,:));
axis xy; colormap(hot(64)); colorbar
xlabel('Red channel'); ylabel('Blue channel')
title(sprintf('%s: Channel image histogram',fname))

%% Now call ieHistImage, which relies on histcn

img = ieHistImage(X,'hist type','histcn');

%%
img = ieHistImage(X,'hist type','scatplot');
