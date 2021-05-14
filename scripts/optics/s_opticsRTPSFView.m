%% Calculating with the ray trace model (synthetic)
%
% The *ray trace* optics model is the most complex of the ISET
% optics models.  It applies a space-varying and wavelength
% dependent *point spread* functions (svPSF). These can be
% created either by calculating from a *Zemax* file, or as we do
% here, a ray trace synthetic model.
%
% The space-varying PSFs are computed and shown here.
%
% See also: rtSynthetic, rtPlot, rtPrecomputePSF,
%           s_opticsGaussianPSF, s_opticsRTGridLines
%
% Copyright Imageval Consulting, LLC, 2012

%%
ieInit
wbStatus = ieSessionGet('waitbar');
% ieSessionSet('waitbar','on');

%% Alternatively, you can run an oiCompute in the ray trace mode

% In this case, the svPSF structure will be stored in the oi. You
% can get the shift variant PSFs that were computed and stored
% this way.
scene = sceneCreate('point array',384);
scene = sceneSet(scene,'h fov',4);
scene = sceneInterpolateW(scene,550:100:650);
ieAddObject(scene); sceneWindow;

%% Create the space-varying optics
oi = oiCreate;
rtOptics = []; spreadLimits = [1 5]; xyRatio = 1.6;
rtOptics = rtSynthetic(oi,rtOptics,spreadLimits,xyRatio);
oi = oiSet(oi,'optics',rtOptics);

%% Compute the irradiance and space-varying PSF
oi    = oiCompute(oi,scene);

%% View the PSFs at the various field heights

vcNewGraphWin;
% These are the computed PSFs
svPSF = oiGet(oi,'psf struct');
for ii=1:size(svPSF.psf,2)
    imagesc(svPSF.psf{1,ii,1}), axis image; pause(0.3);
end

%% These are PSFs at the various sample angles
vcNewGraphWin;
for ii=1:size(svPSF.psf,1)
    imagesc(svPSF.psf{ii,end,1}); axis image; pause(0.3);
end

%%  The point spread at two field heights

% At the center
rtPlot(oi,'psf',550,0);

% At the largest field height
imgHeight = oiGet(oi,'psf image heights','mm');
rtPlot(oi,'psf',550,max(imgHeight(end)));

% Replace the wait bar status
ieSessionSet('waitbar',wbStatus);

%%