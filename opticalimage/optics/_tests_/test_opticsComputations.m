function tests = test_opticsComputations()
tests = functiontests(localfunctions);
end

function testCos4thDataAndPhotonScaling(~)
%% Cos4th relative illumination creates a spatial falloff image

oi = oiCreate;
wave = [500 600 700];
photons = ones(16,18,numel(wave));
oi = oiSet(oi,'fov',0.01);
oi = oiSet(oi,'wave',wave);
oi = oiSet(oi,'photons',photons);
oi = oiSet(oi,'optics offaxis method','cos4th');

oi = opticsCos4th(oi);

sFactor = oiGet(oi,'optics cos4th data');
scaledPhotons = oiGet(oi,'photons');

assert(isequal(size(sFactor),[16 18]));
assert(isequal(size(scaledPhotons),size(photons)));
assert(all(sFactor(:) > 0));
assert(all(sFactor(:) <= 1 + 1e-12));
assert(max(abs(scaledPhotons(:,:,1) - sFactor),[],'all') < 1e-6);
assert(max(abs(scaledPhotons(:,:,2) - sFactor),[],'all') < 1e-6);

center = sFactor(round(end/2),round(end/2));
corner = sFactor(1,1);
assert(center > corner);

end

function testOpticsOTFAndPSFSkipPreservePhotons(~)
%% Skip optics paths return the current photon image unchanged

scene = sceneCreate;
oi = oiCreate;
wave = [500 600];
photons = reshape(single(1:(12*14*numel(wave))),12,14,numel(wave));
oi = oiSet(oi,'wave',wave);
oi = oiSet(oi,'photons',photons);
oi = oiSet(oi,'optics model','skip');

otfOi = opticsOTF(oi,scene);
psfOi = opticsPSF(oi,scene);

assert(isequal(oiGet(otfOi,'photons'),photons));
assert(isequal(oiGet(psfOi,'photons'),photons));

end

function testShiftInvariantOTFInterpolationAndPSF(~)
%% Stored shift-invariant OTF data interpolate by wavelength

optics = opticsCreate('shift invariant');
otf = zeros(8,8,2);
otf(:,:,1) = 0.5;
otf(:,:,2) = 1.0;
otf(1,1,:) = 1;

optics = opticsSet(optics,'otf data',otf);
optics = opticsSet(optics,'otf fx',linspace(-40,40,8));
optics = opticsSet(optics,'otf fy',linspace(-40,40,8));
optics = opticsSet(optics,'otf wave',[500 700]);

midOtf = opticsGet(optics,'otf data',600);
assert(isequal(size(midOtf),[8 8]));
assert(abs(midOtf(1,1) - 1) < 1e-12);
assert(abs(midOtf(2,2) - 0.75) < 1e-12);

psf = opticsGet(optics,'psf data',600,'mm');
assert(isequal(size(psf.psf),[8 8]));
assert(isequal(size(psf.xy),[8 8 2]));
assert(abs(sum(psf.psf(:)) - 1) < 1e-12);

end

function testOpticsOTFIdentityPreservesPaddedPhotons(~)
%% A unit custom OTF leaves the padded photon image unchanged

[oi, scene] = localComputationalOI([8 10],[500 600]);
basePhotons = oiGet(oi,'photons');
oi = localSetMatchedCustomOTF(oi,@(sz,nWave) ones([sz nWave]));

otfOi = opticsOTF(oi,scene,'padvalue','zero');
otfPhotons = oiGet(otfOi,'photons');

padSize = round([size(basePhotons,1) size(basePhotons,2)]/8);
expectedPhotons = zeros(size(basePhotons,1) + 2*padSize(1), ...
    size(basePhotons,2) + 2*padSize(2), size(basePhotons,3));
expectedPhotons((1:size(basePhotons,1)) + padSize(1), ...
    (1:size(basePhotons,2)) + padSize(2), :) = basePhotons;

assert(isequal(size(otfPhotons),size(expectedPhotons)));
assert(max(abs(otfPhotons - expectedPhotons),[],'all') < 1e-6);

end

function testOpticsOTFDcOnlyReturnsPaddedMean(~)
%% A DC-only custom OTF returns the mean of the padded image

[oi, scene] = localComputationalOI([8 8],[550]);
oi = localSetMatchedCustomOTF(oi,@localDcOnlyOTF);

otfOi = opticsOTF(oi,scene,'padvalue','mean');
otfPhotons = oiGet(otfOi,'photons');

expectedMean = mean(oiGet(oi,'photons'),'all');
assert(max(abs(otfPhotons(:) - expectedMean)) < 1e-5);

end

function testOpticsPSFFlatFieldPreservesPhotons(~)
%% The wavefront PSF path preserves a flat field under mean padding

scene = sceneCreate('uniform ee',32,550);
scene = sceneSet(scene,'fov',0.5);
[oi,wvf] = oiCreate('wvf');
oi = oiSet(oi,'wave',550);
oi = oiSet(oi,'photons',ones(16,16,1));
oi = oiSet(oi,'optics model','shift invariant');

psfOi = opticsPSF(oi,scene,[],wvf,'padvalue','mean');
psfPhotons = oiGet(psfOi,'photons');

assert(isequal(size(psfPhotons),[20 20]));
assert(max(abs(psfPhotons(:) - 1)) < 1e-5);

otfData = oiGet(psfOi,'optics otf data');
assert(isequal(size(otfData,1),20));
assert(isequal(size(otfData,2),20));
assert(abs(abs(otfData(1,1,1)) - 1) < 1e-6);

end

function testOiCalculateOTFMatchesStoredCustomOTF(~)
%% oiCalculateOTF returns custom OTF data on the requested support

[oi, ~] = localComputationalOI([8 8],[500 700]);
oi = localSetMatchedCustomOTF(oi,@(sz,nWave) ones([sz nWave]));

[otf,fSupport] = oiCalculateOTF(oi,oiGet(oi,'wave'),'mm');

assert(isequal(size(otf),[8 8 2]));
assert(isequal(size(fSupport),[8 8 2]));
assert(max(abs(otf(:) - 1)) < 1e-12);

end

function [oi, scene] = localComputationalOI(sz,wave)
%% Build an OI and matching scene for deterministic optics computations.

scene = sceneCreate('uniform ee',max(sz),wave);
scene = sceneSet(scene,'fov',1);
scene = sceneSet(scene,'distance',1.2);

oi = oiCreate;
oi = oiSet(oi,'fov',sceneGet(scene,'fov'));
oi = oiSet(oi,'wave',wave);
oi = oiSet(oi,'size',sz);
photons = reshape(1:(prod(sz)*numel(wave)),[sz numel(wave)]);
oi = oiSet(oi,'photons',photons);
oi = oiSet(oi,'optics model','shift invariant');
oi = oiSet(oi,'optics offaxis method','skip');

end

function oi = localSetMatchedCustomOTF(oi,otfFunction)
%% Attach a custom OTF sampled on the support used after opticsOTF padding.

imSize = oiGet(oi,'size');
padSize = round(imSize/8);
padSize(3) = 0;
paddedOi = oiPadValue(oi,padSize,'zero photons',1.2);
fSupport = oiGet(paddedOi,'fSupport','mm');
nWave = oiGet(oi,'n wave');

otf = otfFunction(size(fSupport(:,:,1)),nWave);
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'model','shift invariant');
optics = opticsSet(optics,'otf data',otf);
optics = opticsSet(optics,'otf fx',fSupport(:,1,2)');
optics = opticsSet(optics,'otf fy',fSupport(1,:,1));
optics = opticsSet(optics,'otf wave',oiGet(oi,'wave'));
oi = oiSet(oi,'optics',optics);

end

function otf = localDcOnlyOTF(sz,nWave)
%% Create an OTF with only DC transmission.

otf = zeros([sz nWave]);
otf(1,1,:) = 1;

end
