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

%% Plot the series of lines
f = vcNewGraphWin([],'tall');
for ii=1:nWave
    subplot(nWave,1,ii)
    [f,p] = wvfPlot(wvfParams,'image psf','unit','um','wave',wList(ii),'plotrange',maxUM,'window',false);
    title(sprintf('wave %d',wList(ii)));
end

% Alternative plotting method
% [~,p] = wvfPlot(wvfParams,'1d psf angle','min',ii,maxMIN);

%% Plot the series of point spreads
vcNewGraphWin([],'tall');
for ii=1:nWave
    subplot(nWave,1,ii)
    wvfPlot(wvfParams,'image psf','unit','um','wave',wList(ii),'plotrange',maxUM,'window',false);
    title(sprintf('wave %d',wList(ii)));
end

%% End




end
