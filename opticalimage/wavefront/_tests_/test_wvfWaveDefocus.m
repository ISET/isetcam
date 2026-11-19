function tests = test_wvfWaveDefocus()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
% v_wvfWaveDefocus
%
% Compute for wavelengths different from nominal focus wavelength
%
% The psf should get broader away from the focus wavelength. How much
% broader, I don't know but we can at least verify the qualitative
% behavior, again for the diffaction limited case.
%
% Note from DHB.  The psfs do get broader, and they take on multiple peaks.
% Is this right?  I don't know.
%
% Note from HH: The PSF should start to take on multiple peaks (ringing,
% etc should still be radially symmetric) with change in defocus, so this
% looks right.  At some point defocus will be large enough that you'll run
% into sampling problems.  You could check this by starting with very high
% sampling density and decreasing until just before the point where you
% start to see issues.
%
% See also:  v_wvfDiffractionPSF, v_wvfWaveDefocus
%
% (c) Wavefront Toolbox Team, 2012 (bw)

%% Initialize and set parameters
ieInit;

% Ranges for plotting
maxMIN = 2;
maxMM  = 1;
maxUM  = 20;

%% Calculate point spread for wavelength defocus

% Set up default parameters structure with diffraction limited default
wvfP = wvfCreate;
wave = 400:50:700;
wvfP = wvfSet(wvfP,'wave',wave);
nWave = wvfGet(wvfP,'n wave');
wList = wvfGet(wvfP,'wave');

%% Compute and plot the default
wvfP = wvfSet(wvfP,'lcaMethod','human');
wvfParams = wvfCompute(wvfP);

% Human LCA should spread the PSF away from the nominal focus wavelength.
peaks = zeros(size(wList));
for ii = 1:nWave
    psf = wvfGet(wvfParams,'psf',wList(ii));
    testCase.verifyTrue(all(isfinite(psf(:))));
    testCase.verifyGreaterThanOrEqual(psf,0);
    testCase.verifyEqual(sum(psf,'all'),1,'AbsTol',1e-6);
    peaks(ii) = max(psf(:));
end
focus = find(wList == 550);
% Fixed regression values: MATLAB R2025b, model code at 015b1309.
expectedPeaks = [0.000180921831262 0.000508675424493 0.00316845014637 ...
    0.0268557708968 0.0106743106183 0.00176826080453 0.000991354845476];
testCase.verifyEqual(peaks(:)',expectedPeaks,'RelTol',1e-6);
testCase.verifyGreaterThan(peaks(focus),peaks(1));
testCase.verifyGreaterThan(peaks(focus),peaks(end));
end
