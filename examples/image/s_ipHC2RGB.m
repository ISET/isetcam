%% Create a series of waveband images from a multispectral object
%
% See also: imagehc2rgb, imagescRGB
%
% Copyright Imageval Consulting, LLC 2014

%%
ieInit

% Number of wavebands and thus RGB output images
nBands = 10;

%% Scene
scene = sceneCreate('slanted bar');

rgbImages = imagehc2rgb(scene,10);
ieNewGraphWin([],'tall');
for ii=1:10
    subplot(5,2,ii); imagescRGB(rgbImages(:,:,:,ii));
end

%% Optical image

oi = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'fnumber',16);
oi = oiSet(oi,'optics',optics);

oi = oiCompute(oi,scene);

rgbImages = imagehc2rgb(oi,nBands);
ieNewGraphWin([],'tall');
for ii=1:10
    subplot(5,2,ii); imagescRGB(rgbImages(:,:,:,ii));
end
%% END