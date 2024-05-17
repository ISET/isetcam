function [oi, pupilFunction, psf_spectral, psfSupport] = oiComputeFlare(oi, scene, varargin)
% Deprecated:
% 
%   We now use the usual oiCompute and wvfAperture methods
%   Add lens flare to a scene/optical image.
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
oi = oiCreate('wvf');
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

oiDelta = oiGet(oi,'sample spacing','m');  % In the sensor/retina plane
oiDelta = oiDelta(1);
% 
% For each wavelength, apply the dirty mask
nWave = numel(waveList);
for ww = 1:nWave

    % Wavelength in meters
    wavelength = waveList(ww) * 1e-9; % (m)

    %{
    % To match with the wvf code:
    flengthM = 4e-3;
    flengthMM = flengthM*1e3;
    fnumber = 3;
    wvf = wvfCreate('wave',400:10:700);
    wvf = wvfSet(wvf, 'focal length', flengthMM, 'mm');
    wvf = wvfSet(wvf, 'calc pupil diameter', flengthMM/fnumber);
    nPixels = oiGet(oi, 'size'); nPixels = nPixels(1);
    wvf = wvfSet(wvf, 'spatial samples', nPixels);
    psf_spacingMM = oiGet(oi,'sample spacing','mm');
    lambdaMM = 550*1e-6;
    pupil_spacingMM = lambdaMM * flengthMM / (psf_spacingMM(1) * nPixels);
    wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);
    wvf = wvfCompute(wvf);
    wavelengthNM = round(wavelength*10^9);
    %}

    % Set up the pupil function.  I am not sure about the logic for
    % this spatial support.  Could be right, but I just don't know.
    % What plane is it in?  Pupil?  oiWidth is in the sensor plane, so
    % maybe the spacing isn't quite right? (BW).
    pupilSampleStepX = 1 / (oiDelta * oiSize) * wavelength * focallengthM;
    % wvfGet(wvf, 'pupil sample spacing','m',round(wavelength*10^9)) 
    pupilSupportX = (-0.5: 1/oiSize: 0.5-1/oiSize) * pupilSampleStepX * oiSize;
    % wvfGet(wvf, 'pupil support','m',round(wavelength*10^9)) 
    
    pupilSampleStepY = 1 / (oiDelta * oiSize) * wavelength * focallengthM;
    pupilSupportY = (-0.5: 1/oiSize: 0.5-1/oiSize) * pupilSampleStepY * oiSize;
    [pupilX, pupilY] = meshgrid(pupilSupportX, pupilSupportY);
    
    pupilRadius = 0.5*pupilDiameter;

    pupilRadialDistance = sqrt(pupilX.^2 + pupilY.^2);

    % Valid parts of the pupil
    pupilMask = pupilRadialDistance <= pupilRadius;
    if ~isempty(aperture)
        boundingBox = imageBoundingBox(pupilMask);
        aperture_resize = imresize(aperture,[boundingBox(3),boundingBox(4)],'nearest');
        sz = double(round((oiSize - boundingBox(3))/2) - 2);
        if sz > 0
            % In some cases, there is no need to pad.
            aperture_resize = padarray(aperture_resize,[sz,sz],0,'both');
        end

        aperture_resize = imresize(aperture_resize,[oiSize,oiSize],'nearest');
        aperture_resize(aperture_resize > 1) = 1;
        aperture_resize(aperture_resize < 0) = 0;
        pupilMask = aperture_resize;
        
    end

    pupilRho = pupilRadialDistance./pupilRadius;
    % ----------------Comments From Google Flare Calculation---------------
    % Compute the Zernike polynomial of degree 2, order 0. 
    % Zernike polynomials form a complete, orthogonal basis over the unit disk. The 
    % "degree 2, order 0" component represents defocus, and is defined as (in 
    % unnormalized form):
    %
    %     Z = 2 * r^2 - 1.
    %
    % Reference:
    % Paul Fricker (2021). Analyzing LASIK Optical Data Using Zernike Functions.
    % https://www.mathworks.com/company/newsletters/articles/analyzing-lasik-optical-data-using-zernike-functions.html
    % ---------------------------------------------------------------------
    
    % No general wavefront aberration.  But we could defocus.
    % Default defocusTerm is 0
    wavefront = zeros(size(pupilRho)) + defocusTerm*(2 * pupilRho .^2 - 1);

    phase_term = exp(1i*2 * pi .* wavefront);

    % This is the pupil function.  We should compare with the wvf
    % calculation.
    pupilFunction = phase_term .* pupilMask;

    % By here, we have the pupil function
    % tmp = wvfGet(wvf,'pupil function',round(wavelength*10^9));
    %{
    % Build a wvf here and use wvfComputePSF ....
   
    %}

    % This is the same as wvfComputePSF function

    % Calculate the PSF from the pupil function
    psfFnAmp = fftshift(fft2(ifftshift(pupilFunction)));
    inten = psfFnAmp .* conj(psfFnAmp);    % unnormalized PSF.
    shiftedPsf = real(inten);

    PSF = shiftedPsf./sum(shiftedPsf(:));
    PSF = PSF ./ sum(PSF(:));

    % Now we know the size of PSF.  Allocate space
    if ww == 1
        sz = size(oi.data.photons(:,:,ww));
        photons_fl   = zeros(sz(1),sz(2),nWave);
        psf_spectral = zeros(oiSize,oiSize,nWave);
    end

    
    %{
     ieNewGraphWin; mesh(getMiddleMatrix(PSF,30));
     % The PSF seems pretty much like the one calculated using
     % the wvf and wvf2oi approach.
     ss = oiGet(oi,'spatial support','um');
     ieNewGraphWin; mesh(ss(:,:,1),ss(:,:,2),psf_spectral(:,:,ww));
     set(gca,'xlim',[-10 10],'ylim',[-10 10]);
     title('piFlareApply');
     diskSize = airyDisk(waveList(ww),fNumber,'units','um','diameter',true)    
    %}
    % PSFwvf = wvfGet(wvf,'psf',round(wavelength*1e9));
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
