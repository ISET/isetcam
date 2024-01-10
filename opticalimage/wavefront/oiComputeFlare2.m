function [oi, pupilFunction, psf_spectral, psfSupport] = oiComputeFlare2(oi, scene, varargin)
% Add lens flare to a scene/optical image.
%
% Syntax
%    oi = oiComputeFlare(oi,scene,varargin)
%
% Brief description:
%   Compute PSF and apply the it to a scene to generate an optical image.
%
%
% Input
%   oi          - Optical image struct or a wavefront struct
%   scene       - Spectral scene struct
%
% Optional Key/val pairs
%
% Output:
%   opticalImage: An ISET optical image structure.
%   aperture:  Scratched aperture
%   psf_spectral - Spectral point spread function
%
% See also
%   opticsDLCompute, opticsOTF (ISETCam)

% Examples:
%{
sceneSize = 512;
scene = sceneCreate('point array',sceneSize, 512);
scene = sceneSet(scene,'fov',10);
scene = sceneSet(scene, 'distance',0.05);
sceneSampleSize = sceneGet(scene,'sample size','m');
oi = oiCreate();
[oi,pupilmask, psf] = oiComputeFlare(oi, scene);
ip = piRadiance2RGB(oi,'etime',1);
ipWindow(ip);

% defocus
[oi,pupilmask, psf] = oiComputeFlare(oi, scene,'defocus',0.5);

ip = piRadiance2RGB(oi,'etime',1);
ipWindow(ip);

% aperture
wvf = wvfCreate('spatial samples',sceneSize);
wvf = wvfSet(wvf, 'spatial samples', 1024);
[aperture, params] = wvfAperture(wvf,'nsides',10,...
    'dot mean',50, 'dot sd',20, 'dot opacity',0.5,'dot radius',5,...
    'line mean',50, 'line sd', 20, 'line opacity',0.5,'linewidth',2);
[oi,pupilmask, psf] = oiComputeFlare(oi, scene,'aperture',aperture);
ip = piRadiance2RGB(oi,'etime',1);
ipWindow(ip);

[aperture, params] = wvfAperture(wvf,'nsides',0,...
    'texFile',fullfile(isetRootPath,'data','optics','flare','scratches','scratch_1.jpg'));
[oi,pupilmask, psf] = oiComputeFlare(oi, scene,'aperture',aperture);
figure(1);imshow(aperture)
ip = piRadiance2RGB(oi,'etime',1);
ipWindow(ip);

%}

%% Calculate the PSF using the complex pupil method.  
%
% The calculation enables creating a PSF with arbitrary wavefront
% aberrations. These are optical path differences (OPD) in the pupil.

%% Parse input
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('oi', @(x)isequal(class(x),'struct'));
p.addRequired('scene', @(x)isequal(class(x),'struct'));
p.addParameter('aperture',[]);       % Aperture mask
% p.addParameter('normalizePSF',true);  % whether normalize the calculatedPSF
% some parameters for defocus
p.addParameter('defocusterm', 0); % Zernike defocus term
p.addParameter('pixelsize',[]);% m

p.parse(oi,scene, varargin{:});

aperture      = p.Results.aperture;
defocusTerm      = p.Results.defocusterm;
pixelsize      = p.Results.pixelsize;

%%
fNumber = oiGet(oi,'fnumber');
focallengthM = oiGet(oi,'focal length','m');
pupilDiameter   = focallengthM / fNumber; % (m)

% Now it matches the standard computation.  
% oiGet(oi,'wangular','deg')

%% Starting with a scene, create an initial oi

% This code follows the logic in ISETCam routines 
%    opticsDLCompute and opticsOTF
%
[sceneHeight, sceneWidth, ~] = size(scene.data.photons);
oi = oiSet(oi,'optics focallength',focallengthM);
oi = oiSet(oi,'optics fnumber',fNumber);
oi = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi));
oi = oiSet(oi, 'wAngular', sceneGet(scene,'wAngular'));
% Apply some of the oi methods to the initialized oi data
offaxismethod = opticsGet(oi.optics,'off axis method');
switch lower(offaxismethod)
    case {'skip','none',''}
    case 'cos4th'
        oi = opticsCos4th(oi);
    otherwise
        fprintf('\n-----\nUnknown offaxis method: %s.\nUsing cos4th.',optics.offaxis);
        oi = opticsCos4th(oi);
end

% oiCompute type code

% Pad the optical image to allow for light spread (code from isetcam)
padSize  = round([sceneHeight sceneWidth]/8);
padSize(3) = 0;
sDist = sceneGet(scene,'distance');
oi = oiPadValue(oi,padSize,'zero photons',sDist);
%  oiWidth, oiHeight, imgSize, 
oiSize = oiGet(oi,'size');
oiHeight = oiSize(1); oiWidth = oiSize(2);


if oiWidth>oiHeight, oiSize = oiWidth;
else, oiSize = oiHeight;
end

% Match the sample spacing the user might request as part of oiCompute
if ~isempty(pixelsize)
    wAngularMatchPixel = atand(pixelsize*oiWidth/2/focallengthM)*2;
    oi = oiSet(oi, 'wAngular',wAngularMatchPixel);
end

waveList = oiGet(oi, 'wave');

% Start to compute the pupil function

flengthMM = oiGet(oi,'focal length','mm');
fnumber   = oiGet(oi, 'f number');

wvf = wvfCreate('wave',waveList);
wvf = wvfSet(wvf, 'focal length', flengthMM, 'mm');
wvf = wvfSet(wvf, 'calc pupil diameter', flengthMM/fnumber);

wvf = wvfSet(wvf, 'spatial samples', oiSize);

psf_spacingMM = oiGet(oi,'sample spacing','mm');
lambdaMM = 550*1e-6;
pupil_spacingMM = lambdaMM * flengthMM / (psf_spacingMM(1) * oiSize);
wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * oiSize);

wvf = wvfCompute(wvf,'aperture',aperture);
%

% For each wavelength, apply the dirty mask
nWave = numel(waveList);
for ww = 1:nWave
    % Now we know the size of PSF.  Allocate space
    if ww == 1
        sz = size(oi.data.photons(:,:,ww));
        photons_fl   = zeros(sz(1),sz(2),nWave);
        psf_spectral = zeros(oiSize,oiSize,nWave);
    end


    PSF = wvfGet(wvf,'psf',waveList(ww));
    % Deal with non square scenes
    if oiWidth ~= oiHeight
        sz = double(abs(oiWidth - oiHeight)/2);
        if oiWidth<oiHeight
            photons = padarray(oi.data.photons(:,:,ww),[0,sz],0,'both');
            photons_applied = ImageConvFrequencyDomain(photons,PSF, 2);
            photons_ww = photons_applied(:,sz+1:sz+oiWidth);
        else
            photons = padarray(oi.data.photons(:,:,ww),[sz,0],0,'both');
            photons_applied = ImageConvFrequencyDomain(photons,PSF, 2);
            photons_ww = photons_applied(sz+1:sz+oiHeight,:);
        end
        photons_fl(:,:,ww) = photons_ww;
    else
        photons_fl(:,:,ww) = ImageConvFrequencyDomain(oi.data.photons(:,:,ww), PSF, 2 );
    end
    

    psf_spectral(:,:,ww) = PSF;
    % photons_fl(:,:,ww) = ImageConvFrequencyDomain(oi.data.photons(:,:,ww), psf_spectral(:,:,ww), 2 );

end

psfSupport = oiGet(oi,'spatial support','um');

%% The properties of the oi are not fully set.  

% The photons are calculated, but the OTF is not set, and thus the PSF
% doesn't show up correctly for oiPlot(), for example.  That is one
% reason to use the wvf2oi() approach, particularly if we are sharing
% the data.
%
% We would need to take the psf and compute the OTF.OTF values, as in
% wvf2oi

oi = oiSet(oi,'photons',photons_fl);

% Compute illuminance, though not really necessary
% oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

end
