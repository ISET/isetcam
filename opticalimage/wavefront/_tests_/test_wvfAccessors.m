function tests = test_wvfAccessors()
tests = functiontests(localfunctions);
end

function testDefaultWavefrontParameters(~)
%% Default wavefront object exposes expected stored and derived parameters

wvf = wvfCreate;

assert(strcmp(wvfGet(wvf,'type'),'wvf'));
assert(strcmp(wvfGet(wvf,'name'),'default'));
assert(isequal(wvfGet(wvf,'wave'),550));
assert(wvfGet(wvf,'n wave') == 1);
assert(abs(wvfGet(wvf,'measured pupil','mm') - 8) < 1e-12);
assert(abs(wvfGet(wvf,'calc pupil diameter','mm') - 3) < 1e-12);
assert(abs(wvfGet(wvf,'measured wl','nm') - 550) < 1e-12);
assert(abs(wvfGet(wvf,'focal length','mm') - 17.1883) < 1e-10);

expectedFNumber = wvfGet(wvf,'focal length','mm') / ...
    wvfGet(wvf,'calc pupil diameter','mm');
assert(abs(wvfGet(wvf,'fnumber') - expectedFNumber) < 1e-12);
assert(wvfGet(wvf,'spatial samples') == 201);
assert(wvfGet(wvf,'middle row') == 101);

end

function testSettersAndUnitConversions(~)
%% Set/get paths preserve values and length units

wvf = wvfCreate;
wvf = wvfSet(wvf,'name','unit-test wvf');
wvf = wvfSet(wvf,'wave',[450; 550; 650]);
wvf = wvfSet(wvf,'calc pupil diameter',4);
wvf = wvfSet(wvf,'focal length',20,'mm');
wvf = wvfSet(wvf,'spatial samples',65);
wvf = wvfSet(wvf,'ref pupil plane size',13);

assert(strcmp(wvfGet(wvf,'name'),'unit-test wvf'));
wave = wvfGet(wvf,'wave');
assert(isequal(wave(:),[450; 550; 650]));
assert(wvfGet(wvf,'n wave') == 3);
assert(abs(wvfGet(wvf,'wave','um',2) - 0.55) < 1e-12);
assert(abs(wvfGet(wvf,'calc pupil diameter','m') - 0.004) < 1e-15);
assert(abs(wvfGet(wvf,'focal length','cm') - 2) < 1e-12);
assert(abs(wvfGet(wvf,'fnumber') - 5) < 1e-12);
assert(wvfGet(wvf,'spatial samples') == 65);
assert(abs(wvfGet(wvf,'ref pupil plane size','mm') - 13) < 1e-12);
assert(abs(wvfGet(wvf,'ref pupil plane size','m') - 0.013) < 1e-15);

end

function testWavelengthDependentSampling(~)
%% Wavelength vector drives wavelength count and sampling support

wvf = wvfCreate('calc wavelengths',[500 600], ...
    'spatial samples',51,'ref pupil plane size',12, ...
    'measured wl',500,'sample interval domain','psf');

pupilSize = wvfGet(wvf,'pupil plane size','mm',[500 600]);
assert(isequal(size(pupilSize),[2 1]));
assert(max(abs(pupilSize(:) - [12; 14.4])) < 1e-12);

psfSupport = wvfGet(wvf,'psf support','um',500);
assert(numel(psfSupport) == 51);
assert(abs(psfSupport(wvfGet(wvf,'middle row'))) < 1e-12);
assert(abs(psfSupport(1) + psfSupport(end)) < 1e-12);

wvf = wvfSet(wvf,'sample interval domain','pupil');
pupilSize = wvfGet(wvf,'pupil plane size','mm',[500 600]);
assert(max(abs(pupilSize(:) - [12; 12])) < 1e-12);

end

function testZernikeSetGetAndIndexing(~)
%% Zernike name and index helpers agree on low-order OSA terms

wvf = wvfCreate;
wvf = wvfSet(wvf,'zcoeffs',[0.25 -0.5], ...
    {'defocus','vertical_astigmatism'});

assert(abs(wvfGet(wvf,'zcoeffs','defocus') - 0.25) < 1e-12);
assert(abs(wvfGet(wvf,'zcoeffs','vertical_astigmatism') + 0.5) < 1e-12);
assert(abs(wvfGet(wvf,'zcoeffs',4) - 0.25) < 1e-12);
assert(abs(wvfGet(wvf,'zcoeffs',5) + 0.5) < 1e-12);

j = 0:14;
[n,m] = wvfOSAIndexToZernikeNM(j);
jRoundTrip = wvfZernikeNMToOSAIndex(n,m);
assert(isequal(jRoundTrip,j));
assert(isequal(wvfOSAIndexToVectorIndex(j),j + 1));
assert(isequal(wvfOSAIndexToVectorIndex({'piston','defocus', ...
    'primary_spherical'}),[1 5 13]));

end
