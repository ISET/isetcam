%% s_opticsPSF2OTF
%
% We start with an image that defines a PSF.  We also define a couple
% of other parameters (field of view and pixel size).  We then convert
% the image into a properly labeled OTF that can be attached to a
% shift-invariant OI.
%
% We will test the work using the Flare 7K point spread images
%
% See also
%

%% We first just get the PSF into the OTF format with the proper fftshift
fname = fullfile(isetRootPath,'data','optics','flare','flare2.png');

img = imread(fname);
psf = img(:,:,2);   % Use the green channel
% ieNewGraphWin; imagesc(psf); colormap(gray)

psf = double(psf);
psf = psf/sum(psf(:));

[row,col] = size(psf);

% We need to expand this over wavelengths
otf = ifft2(psf);

%%
% The DC is NOT in the center.  So to see the whole pattern we
% fftshift it into the center
ieNewGraphWin; imagesc(fftshift(abs(otf)));
ieNewGraphWin; mesh(fftshift(abs(otf)));

%% Then we figure out the cycles per millimeter

hFOV     = 40;       % Horizontal field of view in degrees
pixSize  = 1.2e-6;   % Standard might be 1.2 microns
% imgSizeM = pixSize*col;   % Image size in meters
% imgSizeMM = imgSizeM*1e3; % Image size in millimeters

% OTF frequencies are stored in cycles per degree
fx = (-(col/2):( (col/2)-1) ) * (1/hFOV) * 50;
fy = (-(row/2):( (row/2)-1) ) * (1/hFOV) * 50;

%% Again to visualize now with frequencies labeled

ieNewGraphWin; imagesc(fx,fy,fftshift(abs(otf)));
ieNewGraphWin; mesh(fx,fy,fftshift(abs(otf)));

%%  Now we want to put the OTF into an OI

scene = sceneCreate('point array');
scene = sceneSet(scene,'hfov',40);
oi = oiCreate('shift invariant');
oi = oiCompute(oi,scene);
oiWindow(oi);

%%
wave = oiGet(oi,'wave');
OTF = zeros(row,col,numel(wave));

for ii=1:numel(wave)
    OTF(:,:,ii) = otf;
end
oi.optics.OTF.OTF = OTF;
oi.optics.OTF.fx = fx;
oi.optics.OTF.fy = fy;

%%
oi = oiCompute(oi,scene);
oiWindow(oi);


