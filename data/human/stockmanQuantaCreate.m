%% Script to create Stockman curves on a quantal, not energy, basis
%
wave = 380:780;
fname = fullfile(isetRootPath, 'data', 'human', 'stockman.mat');
[fSEnergy, fN] = ieReadColorFilter(wave, fname);
% vcNewGraphWin; plot(wave,fSEnergy); grid on

% Row dimension of vector and wave must be equal
q2e = Quanta2Energy(wave, ones(length(wave), 1));
% vcNewGraphWin; plot(wave,q2e)

% Human cone absorptions are about 0.3, so we scale them
% here.  This might be set more precisely by users.  The
% PsychToolbox has a description of the references and
% values that we could import here.

% ISET computes based on photons.  So we multiply by a factor that converts
% photons to energy, and then apply the stockman.  We group Photons to
% Energy and Stockman into a single matrix, and save this out.  Then:
%
%     OI Photons -> Photons to Energy -> Stockman
fSQuanta = diag(q2e) * fSEnergy;
mx = max(fSQuanta);
fSQuanta = fSQuanta * diag(1./mx);
% vcNewGraphWin; plot(wave,fSQuanta); grid on

oname = fullfile(isetRootPath, 'data', 'human', 'stockmanQuanta.mat');
inData.wavelength = wave; % Vector of W wavelength samples
inData.data = fSQuanta; % Matrix of filters (W rows, N filter columns)
inData.filterNames = fN; % Cell array of names; first letter is a color hint
inData.comment = 'Converted from Stockman energy to Stockman quanta by StockmanQuantaCreate.m';
fullFileName = ieSaveColorFilter(inData, oname);

% Compare the energy and quantal forms.  Notice that they are similar where
% there are lots of absorptions, but they differn noticeably at the very
% long and short wavelengths
vcNewGraphWin;
plot(wave, fSEnergy./fSQuanta);
grid on

%% Do SP cones

%% End
