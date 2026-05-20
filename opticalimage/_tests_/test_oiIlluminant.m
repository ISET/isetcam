function tests = test_oiIlluminant()
tests = functiontests(localfunctions);
end

function testMain(~)
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
tolerance = 1e-6;

%%
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
[X,~] = meshgrid(1:sz(2),1:sz(1));
oi = oiIlluminantSS(oi,X);
assert(isequal(oiGet(oi,'illuminant format'),'spatial spectral'));

%%
illuPhoton = oiGet(oi, 'illuminant photons');
assert(~isempty(oiGet(oi, 'illuminant name')));
illuWave = oiGet(oi, 'illuminant wave');
assert(isequal(size(illuPhoton),[80 120 31]));
assert(abs(sum(illuPhoton,'all')/6.47167491633122e+22 - 1) < 1e-4);
assert(abs(mean(illuPhoton(30:50,50:70,:),'all')/2.1566482492162e+17 - 1) < 1e-4);
rgb = imageSPD(illuPhoton, illuWave);
assert(abs( mean(double(rgb(:)))/0.667954238028162 - 1 )< tolerance);

%%
uData = oiPlot(oi, 'illuminant image');
assert(abs(mean(double(uData.srgb(:)))/0.693425079000493 - 1) < tolerance);

%% END



end
