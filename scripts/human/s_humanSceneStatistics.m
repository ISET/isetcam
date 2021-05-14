%% s_HumanSceneStatistics
%
% We create a random (Gaussian, white spatial noise, D65 SPD) scene.  We
% visualize the white noise spatial statistics in the scene space.
%
% Then we pass this scene through the human optics to create a spectral
% irradiance image.
%
% Finally, we compute the responses in the cones, using three simplified
% human sensors. Each mosaic comprises a full mosaic of each of the cone
% types.  We show amplitude of the spatial FFT of the cone mosaic
% absorptions for the L,M, and S cone types.
%
% All of the three types experience a low spatial frequency response
% because of the lens. The S-cone mosaic only experiences a relatively low
% spatial frequency image.
%
% (c) Imageval Consulting, LLC, 2012
%

%% Initialize
ieInit
try
    rng('default');  % To achieve the same result each time
catch err
    randn('seed');
end
%%  We start with a small (2 deg) scene of white noise
% Each radiance is drawn from a Gaussian
contrast = 0.5;
scene =  sceneCreate('white noise',[256 256],contrast);
scene = sceneSet(scene,'h fov',2);
vcAddAndSelectObject(scene); sceneWindow;

%% The amplitude of the spatial contrast of the radiance image
% This is a white noise image, so the amplitude spectrum is flat.  Notice
% that the contrast means we have removed the mean.  We plot the radiance
% data at 550 nm, but this would be the same at any wavelength.
scenePlot(scene,'radiance fft image',550);

%%  Create the optical image.  Notice that it is significantly blurred
% This is because of the human optics
oi = oiCreate('human');
oi = oiCompute(scene,oi);
vcAddAndSelectObject(oi); oiWindow;

%% Set up the human sensor parameters and compute.
% We will create a series of sensors, each with just one of the three types
% of cones.  For each, we will compute the spatial mosaic of responsea, and
% then plot the spatial amplitude spectrum
params.sz = [256,256];
params.coneAperture = [2 2 ]*1e-6;     % In meters
xy = [64,1];
cType = {'L','M','S'};
pFFT = cell(3,1); sensor = cell(3,1);
for ii=1:3
    params.rgbDensities = [0 0 0 0]; % Empty, L,M,S
    params.rgbDensities(ii+1) = 1;   % Fill up with L,M or S.
    
    sensor{ii} = sensorCreate('human',[],params);
    
    sensor{ii} = sensorSet(sensor{ii},'exp time',0.2);
    sensor{ii} = sensorCompute(sensor{ii},oi);
    vcAddAndSelectObject(sensor{ii});
    
    p = sensorGet(sensor{ii},'photons');
    p = reshape(p,params.sz(1),params.sz(2));
    p = p - mean(p(:));  % Remove mean
    pFFT{ii} = fftshift(abs(fft2(p)));  % Compute FFT
end

%% Plot the three spatial amplitude spectra
vcNewGraphWin([],'tall');
for ii=1:3
    subplot(3,1,ii)
    imagesc(pFFT{ii}); colormap(hot(64)); colorbar;
    axis image; axis off
    xlabel('Cycles/deg'); ylabel('Cycles/deg');
    title(sprintf('%s cone spatial amp spectrum',cType{ii}));
end


