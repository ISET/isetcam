function tests = test_wvfPSFUtilities()
tests = functiontests(localfunctions);
end

function testPsfFindPeakAndCenter(~)
%% PSF peak location and centering preserve total energy

psf = zeros(7,7);
psf(2,6) = 10;
psf(2,5) = 4;
psf(3,6) = 2;

[peakRow,peakCol] = psfFindPeak(psf);
assert(peakRow == 2);
assert(peakCol == 6);

[centered,oldPeakRow,oldPeakCol] = psfCenter(psf);
[newPeakRow,newPeakCol] = psfFindPeak(centered);

assert(oldPeakRow == peakRow);
assert(oldPeakCol == peakCol);
assert(newPeakRow == 4);
assert(newPeakCol == 4);
assert(abs(sum(centered(:)) - sum(psf(:))) < 1e-12);

end

function testPsfVolumeWithGridInputs(~)
%% PSF volume uses sample spacing and returns unit-volume normalization

psf = ones(3,4);
[x,y] = meshgrid(0:2:6,0:3:6);

[volume,normalizedPsf] = psfVolume(psf,x,y);

assert(abs(volume - 72) < 1e-12);
assert(max(abs(normalizedPsf(:) - 1/72)) < 1e-12);
assert(abs(psfVolume(normalizedPsf,x,y) - 1) < 1e-12);

end

function testPsfCircularAveragePreservesVolume(~)
%% Circular averaging preserves PSF volume and places peak at the center

psf = zeros(7,7);
psf(4,4) = 100;
psf(4,3) = 2;
psf(4,5) = 4;
psf(3,4) = 6;
psf(5,4) = 10;

circularPsf = psfCircularlyAverage(psf);
[peakRow,peakCol] = psfFindPeak(circularPsf);

assert(isequal(size(circularPsf),size(psf)));
assert(all(circularPsf(:) >= 0));
assert(abs(sum(circularPsf(:)) - sum(psf(:))) < 1e-12);
assert(peakRow == 4);
assert(peakCol == 4);
assert(abs(circularPsf(4,3) - circularPsf(3,4)) < 1e-12);
assert(abs(circularPsf(4,5) - circularPsf(5,4)) < 1e-12);

end

function testPsfToLsfMatchesAxisSums(~)
%% Line-spread projections match direct sums for horizontal and vertical axes

psf = reshape(1:20,[4 5]);

horizontalLsf = psf2lsf(psf,'direction','horizontal');
verticalLsf = psf2lsf(psf,'direction','vertical');

assert(max(abs(horizontalLsf(:) - sum(psf,2))) < 1e-12);
assert(max(abs(verticalLsf(:) - sum(psf,1).')) < 1e-12);

squarePsf = magic(5);
multiWavePsf = cat(3,squarePsf,2*squarePsf);
multiWaveLsf = psf2lsf(multiWavePsf,'direction','horizontal');
assert(isequal(size(multiWaveLsf),[5 2]));
assert(max(abs(multiWaveLsf(:,1) - sum(squarePsf,2))) < 1e-12);
assert(max(abs(multiWaveLsf(:,2) - 2*sum(squarePsf,2))) < 1e-12);

end

function testLsfToCircularPsfReturnsNormalizedPsf(~)
%% Symmetric LSF conversion returns a normalized nonnegative square PSF

lsf = [0.05 0.2 0.5 0.2 0.05];
psf = lsf2circularpsf(lsf);
[peakRow,peakCol] = psfFindPeak(psf);

assert(isequal(size(psf),[5 5]));
assert(all(psf(:) >= 0));
assert(abs(sum(psf(:)) - 1) < 1e-12);
assert(peakRow == 3);
assert(peakCol == 3);
assert(abs(psf(3,2) - psf(3,4)) < 1e-12);
assert(abs(psf(2,3) - psf(4,3)) < 1e-12);

end

function testComputedWavefrontPsfIsNormalizedAndCentered(~)
%% Diffraction-limited wavefront calculation produces normalized PSFs

wvf = wvfCreate('calc wavelengths',[500 650], ...
    'spatial samples',65,'calc pupil diameter',3, ...
    'measured pupil',6,'lca method','none');
wvf = wvfCompute(wvf);

waves = wvfGet(wvf,'wave');
psfA = wvfGet(wvf,'psf',waves(1));
psfB = wvfGet(wvf,'psf',waves(2));

assert(isequal(size(psfA),[65 65]));
assert(isequal(size(psfB),[65 65]));
assert(all(psfA(:) >= -1e-12));
assert(all(psfB(:) >= -1e-12));
assert(abs(sum(psfA(:)) - 1) < 1e-6);
assert(abs(sum(psfB(:)) - 1) < 1e-6);

[peakRowA,peakColA] = psfFindPeak(psfA);
[peakRowB,peakColB] = psfFindPeak(psfB);
middleRow = wvfGet(wvf,'middle row');
assert(abs(peakRowA - middleRow) <= 1);
assert(abs(peakColA - middleRow) <= 1);
assert(abs(peakRowB - middleRow) <= 1);
assert(abs(peakColB - middleRow) <= 1);

radiusA = localSecondMomentRadius(psfA);
radiusB = localSecondMomentRadius(psfB);
assert(radiusB > radiusA);

end

function radius = localSecondMomentRadius(psf)
%% Robust width metric in pixel units.

[nRows,nCols] = size(psf);
[x,y] = meshgrid(1:nCols,1:nRows);
mass = sum(psf(:));
xCenter = sum(x(:).*psf(:)) / mass;
yCenter = sum(y(:).*psf(:)) / mass;
radius = sqrt(sum(((x(:) - xCenter).^2 + (y(:) - yCenter).^2).*psf(:)) / mass);

end
