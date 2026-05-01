function tests = test_wvfSampleData()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_wvfSampleData
%
% Compute psfs for the Hofer sample data
%
% HH provided Zernike coefficients measured in 9 subjects.  We compute the
% psfs using these, and look at a slice through each of them.  We try
% things various different ways.
%
% The computed PSFs are recentered, with their maximum in the center, so
% that we see the real peak when we take the 1D slice.
%
% This also optimizes the defocus to maximize the strehl ratio for each
% subject, so you can see the (large) effect of doing that.
%
% Note from DHB.  Again, I don't know if these are correct, but at least
% you can see that you get a wide range of answers by using different
% subjects' data.
%
% Note from HH: Surprised by the large changes with the 3mm pupil between
% zero defocus and that required to optimize the strehl.   Ran it with
% calcpupil of 6mm (since already had lots of calculations done for these
% subjects at this size) and with or without the SCE the values of defocus
% required to optimize the monochromatic strehl matched my calculations- at
% least within the resolution of your routine, so I guess the 3mm result is
% just what happens.  Not exactly an independent test, but at least
% verifies that these routines produce the same result as my original
% function.
%
% Note from HH: For real calculations, using a defocus increment smaller
% than 0.25 Diopters would be wise.
%
% (c) Wavefront Toolbox Team, 2012 (bw)

%% Initialize
ieInit;

maxMIN = 6;

%% Use Heidi Hofer's sample data here

% Set values in millimeters
wvfP = wvfCreate('measured pupil',6,'calculated pupil',3);
wvfP = wvfSet(wvfP,'lcaMethod','human');
wvfP = wvfCompute(wvfP);
wList = wvfGet(wvfP,'wave');

% Sample data
sDataFile = fullfile(wvfRootPath,'data','sampleZernikeCoeffs.txt');
theZernikeCoeffs = importdata(sDataFile);

whichSubjects = 1:2; nSubjects = length(whichSubjects);
theZernikeCoeffs = theZernikeCoeffs(:,whichSubjects);

% For plotting
nRows = ceil(sqrt(nSubjects));
nCols = ceil(nSubjects/nRows);

% No Stiles Crawford
sceWavelength = 550;
wvfP.sceParams = sceCreate(sceWavelength,'none');

%% Test Strehl ratios
ratios = [0.033, 0.103];

for ii = 1:nSubjects
    % fprintf('** Subject %d\n',ii)
    
    % Compute the diffraction limited version of the PSF
    wvfP = wvfSet(wvfP,'zcoeffs',zeros(61,1));
    wvfP = wvfSet(wvfP,'lcaMethod','human');
    wvfP = wvfCompute(wvfP);

    % Diffraction limited
    udataD = wvfPlot(wvfP,'1d psf angle','unit','min','wave',wList,'plotrange',maxMIN);
    hold on;
    
    % Now, set it up for the typical subject
    wvfP = wvfSet(wvfP,'zcoeffs',theZernikeCoeffs(:,ii));
    wvfP = wvfSet(wvfP,'lcaMethod','human');
    wvfP = wvfCompute(wvfP);

    [udataS, pData] = wvfPlot(wvfP,'1d psf angle','unit','min','wave',wList,'plotrange',maxMIN);
    set(pData,'color','b');
    hold on;
    
    strehlDirect = max(udataS.y(:))/max(udataD.y(:));
    assert(abs(ratios(ii) - strehlDirect) < 1e-3);
   
    % wvfPlot(wvfP,'image psf','unit','um','wave',wList,'plotrange',20);
    
end

%% End


end
