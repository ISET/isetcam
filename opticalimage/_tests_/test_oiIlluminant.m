function tests = test_oiIlluminant()
tests = functiontests(localfunctions);
end

function testSpectralIlluminantReplicatesToSpatialSpectral(~)
%% oiIlluminantSS replicates a spectral illuminant across OI geometry.

oi = localIlluminantOI;
basePhotons = oiGet(oi,'photons');
spectralPhotons = [10; 20; 30];

illuminant = illuminantCreate('equal photons',oiGet(oi,'wave'));
illuminant = illuminantSet(illuminant,'photons',spectralPhotons);
oi = oiSet(oi,'illuminant',illuminant);

assert(isequal(oiGet(oi,'illuminant format'),'spectral'));

oi = oiIlluminantSS(oi);
illuminantPhotons = oiGet(oi,'illuminant photons');
illuminantEnergy = oiGet(oi,'illuminant energy');

assert(isequal(oiGet(oi,'illuminant format'),'spatial spectral'));
assert(isequal(size(illuminantPhotons),[3 4 3]));
assert(max(abs(oiGet(oi,'photons') - basePhotons),[],'all') < 1e-12);

for ii = 1:numel(spectralPhotons)
    thisPlane = illuminantPhotons(:,:,ii);
    assert(max(abs(thisPlane(:) - spectralPhotons(ii))) < 1e-6);
end

expectedEnergy = Quanta2Energy(oiGet(oi,'wave'),spectralPhotons);
for ii = 1:numel(spectralPhotons)
    thisPlane = illuminantEnergy(:,:,ii);
    assert(max(abs(thisPlane(:) - expectedEnergy(ii))) < 1e-12);
end

whiteXYZ = oiGet(oi,'illuminant xyz');
assert(isequal(size(whiteXYZ),[3 4 3]));
assert(all(isfinite(whiteXYZ(:))));

end

function testIlluminantPatternPreservesLocalReflectance(~)
%% oiIlluminantPattern scales photons and illuminant photons together.

oi = localIlluminantOI;
scenePhotons = oiGet(oi,'photons');
spectralPhotons = [4; 8; 16];
pattern = [1 2 3 4; 5 6 7 8; 9 10 11 12];

illuminant = illuminantCreate('equal photons',oiGet(oi,'wave'));
illuminant = illuminantSet(illuminant,'photons',spectralPhotons);
oi = oiSet(oi,'illuminant',illuminant);
oi = oiIlluminantSS(oi);

baseIlluminantPhotons = oiGet(oi,'illuminant photons');
baseReflectance = scenePhotons ./ baseIlluminantPhotons;

oi = oiIlluminantPattern(oi,pattern);
patternedPhotons = oiGet(oi,'photons');
patternedIlluminantPhotons = oiGet(oi,'illuminant photons');

for ii = 1:oiGet(oi,'nwave')
    assert(max(abs(patternedPhotons(:,:,ii) - scenePhotons(:,:,ii).*pattern),[],'all') < 1e-12);
    assert(max(abs(patternedIlluminantPhotons(:,:,ii) - baseIlluminantPhotons(:,:,ii).*pattern),[],'all') < 1e-6);
end

patternedReflectance = patternedPhotons ./ patternedIlluminantPhotons;
assert(max(abs(patternedReflectance(:) - baseReflectance(:))) < 1e-7);

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

function oi = localIlluminantOI
%% Small deterministic OI for illuminant structure tests.

wave = [500 600 700];
sz = [3 4];

oi = oiCreate;
oi = oiSet(oi,'wave',wave);
oi = oiSet(oi,'size',sz);
oi = oiSet(oi,'fov',5);
oi = oiSet(oi,'photons',reshape(1:(prod(sz)*numel(wave)),[sz numel(wave)]));

end
