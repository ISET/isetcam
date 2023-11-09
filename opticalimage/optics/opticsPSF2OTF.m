function OTF = opticsPSF2OTF(imageFile,pixSizeM,wave)
% Convert the G channel of an RGB image into an optics OTF struct 
%
% Synopsis
%    OTF = opticsPSF2OTF(imageFile,[pixSizeM=1.2e-6],[wave=400:10:700])
%
% Brief Description
%  We convert the green channel of an RGB image into an OTF struct
%  that can be used in an OI for oiCompute.  The OTF structure
%  includes the otf and fx,fy specifications in cycles per millimeter.
%  And a 'function' slot with the string 'custom'.
%
% Inputs
%   imageFile - RGB file with a G channel that defines the point spread
%
% Optional
%   pixSizeM  - Pixel size in meters  1.2 microns
%   wave      - Wavelength vector  400:10:700
%
% Return
%   OTF - Struct for optics.OTF
%
% See also
%  s_opticsPSF2OTF.m
%

% Example:
%{
 % flare1.png or flare2.png
 fname = fullfile(isetRootPath,'data','optics','flare','flare2.png');
 OTF = opticsPSF2OTF(fname,1.2e-6,400:10:700);
 scene = sceneCreate('point array',512,128);
 oi = oiCreate('shift invariant');
 oi = oiSet(oi,'optics otfstruct',OTF);
 oi = oiCompute(oi,scene);
 oiWindow(oi);
%}

%% Default parameters

if notDefined('pixSizeM'),pixSizeM = 1.2e-6; end
if notDefined('wave'), wave = 400:10:700; end

%%
img = imread(imageFile);
psf = double(img(:,:,2));   % Use the green channel
% ieNewGraphWin; imagesc(psf); colormap(gray)

psf = double(psf);
psf = psf/sum(psf(:));

[row,col] = size(psf);

% We need to expand this over wavelengths
% otf = ifft2(psf);
% otf = psf2otf(psf); % from matlab builtin
% psf_shift = circshift(psf, -floor(size(psf)/2)); % from matlab builtin
psf_shifted = fftshift(psf);
otf = fft2(psf_shifted);
%% The DC is NOT in the center.  
% 
% To see the whole pattern we fftshift it into the center

% ieNewGraphWin; imagesc(fftshift(abs(otf)));
% ieNewGraphWin; mesh(fftshift(abs(otf)));

%% Then we figure out the cycles per millimeter

% pixSize  = 1.2e-6;   % Standard might be 1.2 microns
imgSizeMM = pixSizeM*col*1e3;   % Image size in millimeters

% OTF frequencies are stored in cycles per degree
fx = (-(col/2):( (col/2)-1) ) * (1/imgSizeMM);
fy = (-(row/2):( (row/2)-1) ) * (1/imgSizeMM);


%% Build the returned struct

OTF.function = 'custom';
OTF.OTF = repmat(otf,1,1,numel(wave));
OTF.fx = fx;
OTF.fy = fy;

end
