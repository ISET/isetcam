%% Check the oi illuminant functions
%
%  We sometimes include illuminant in the OI when we render a 3D scene with
%  PBRT (ISET3D).  Typically these are spatial-spectral illuminants
%
% See also
%   oiIlluminantSS, oiIlluminantPattern, sceneIlluminantSS,
%   sceneIlluminantPattern
%

%%
ieInit;
scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi, scene);
thisI = illuminantCreate;

%%
oi = oiSet(oi,'illuminant',thisI);
testI = oiGet(oi,'illuminant');
assert(isequal(thisI,testI));

%%  This reads the data in the illuminant and reports the format
sz = oiGet(oi,'size');
[X,Y] = meshgrid(1:sz(2),1:sz(1));
oi = oiIlluminantSS(oi,X);
oiGet(oi,'illuminant format')

%%
illuPhoton = oiGet(oi, 'illuminant photons');
illuName = oiGet(oi, 'illuminant name');
illuWave = oiGet(oi, 'illuminant wave');
rgb = imageSPD(illuPhoton, illuWave);
oiPlot(oi, 'illuminant image');


%% END


