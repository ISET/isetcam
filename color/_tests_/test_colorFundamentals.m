function tests = test_colorFundamentals()
tests = functiontests(localfunctions);
end

function testEnergyQuantaConversionsNumericalValues(~)
%% Photon-energy conversion preserves physical constants and data format

wave = [500 600];
energyInColumns = [1 2]';

photons = Energy2Quanta(wave,energyInColumns);
expectedPhotons = [2.5170180749662556e18; 6.0408433799190139e18];
assert(max(abs(photons - expectedPhotons)./expectedPhotons) < 1e-14);

energyBack = Quanta2Energy(wave,photons');
assert(max(abs(energyBack - [1 2])) < 1e-12);

photonsXW = [1e18 2e18];
energyXW = Quanta2Energy(wave,photonsXW);
expectedEnergyXW = [0.39729551803612156 0.66215919672686929];
assert(max(abs(energyXW - expectedEnergyXW)) < 1e-12);

rgbPhotons = ones(2,3,2);
rgbEnergy = Quanta2Energy(wave,rgbPhotons);
rgbPhotonsBack = Energy2Quanta(wave,rgbEnergy);
assert(isequal(size(rgbEnergy),size(rgbPhotons)));
assert(max(abs(rgbPhotonsBack(:) - rgbPhotons(:))) < 1e-12);

end

function testChromaticityNumericalValues(~)
%% Chromaticity is computed correctly for XW and RGB image formats

XYZ = [1 2 3; 2 3 5; 0 0 0];
xy = chromaticity(XYZ);

expectedXY = [1/6 2/6; 0.2 0.3; 0 0];
assert(max(abs(xy(:) - expectedXY(:))) < 1e-15);

XYZImage = reshape([1 2 3; 2 3 5],[2 1 3]);
xyImage = chromaticity(XYZImage);
assert(isequal(size(xyImage),[2 1 2]));

xyImageXW = reshape(xyImage,[],2);
expectedImageXY = expectedXY(1:2,:);
assert(max(abs(xyImageXW(:) - expectedImageXY(:))) < 1e-15);

end

function testPhotopicLuminanceAndXYZNumericalValues(~)
%% Photopic luminance and XYZ values are pinned for standard spectra

lum555 = ieLuminanceFromEnergy(1,555,'binwidth',10);
assert(abs(lum555 - 6830) < 1e-10);

photons555 = Energy2Quanta(555,1);
lumPhotons555 = ieLuminanceFromPhotons(photons555',555);
assert(abs(photons555 - 2.793890063212544e18) < 1e4);
assert(abs(lumPhotons555 - lum555) < 1e-10);

XYZ555 = reshape(ieXYZFromEnergy(1,555),1,[]);
expectedXYZ555 = [3497.3021829999998 6830 39.272493170000004];
expectedXY555 = [0.33736333285085651 0.6588482901396886];

assert(max(abs(XYZ555 - expectedXYZ555)) < 1e-9);
assert(abs(XYZ555(2) - lum555) < 1e-10);
assert(max(abs(chromaticity(XYZ555) - expectedXY555)) < 1e-15);

wave = 400:100:700;
flatEnergy = ones(1,numel(wave));
XYZ = ieXYZFromEnergy(flatEnergy,wave);
lum = ieLuminanceFromEnergy(flatEnergy,wave);

expectedXYZ = [74636.133628000011 65465.413399999998 23266.395683000006];
expectedXY = [0.45685911439817961 0.40072374245300474];

assert(max(abs(XYZ - expectedXYZ)) < 1e-8);
assert(abs(lum - expectedXYZ(2)) < 1e-10);
assert(max(abs(chromaticity(XYZ) - expectedXY)) < 1e-15);

end

function testPhotonsAndEnergyXYZAgree(~)
%% XYZ from photons matches XYZ from the equivalent energy spectrum

wave = 400:100:700;
energy = [0.1 0.2 0.3 0.4];
photons = Energy2Quanta(wave,energy');

XYZEnergy = ieXYZFromEnergy(energy,wave);
XYZPhotons = ieXYZFromPhotons(photons',wave);

assert(max(abs(XYZEnergy - XYZPhotons)) < 1e-10);

end

function testScotopicLuminanceNumericalValue(~)
%% Scotopic luminance uses the rod sensitivity function and 1745 scale factor

wave = 400:100:700;
flatEnergy = ones(1,numel(wave));

scotopicLum = ieScotopicLuminanceFromEnergy(flatEnergy,wave);

assert(abs(scotopicLum - 162582.29520709161) < 1e-8);

end

function testLuminance2RadianceScalesToRequestedLuminance(~)
%% Luminance-to-radiance produces a spectrum with the requested luminance

[energy,wave] = ieLuminance2Radiance(100,555,'sd',10,'wave',500:1:610);

assert(isequal(size(energy),[111 1]));
assert(isequal(wave,500:1:610));
assert(abs(ieLuminanceFromEnergy(energy,wave) - 100) < 1e-10);
assert(abs(max(energy) - 0.0059589233717592125) < 1e-15);
assert(abs(sum(energy) - 0.14954547820146336) < 1e-14);
assert(energy(1) == 0);
assert(energy(end) == 0);

end
