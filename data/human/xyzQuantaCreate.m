%% Script to create CIE 1931 XYZ curves on a quantal, not energy, basis
%

%%
wave = 380:780;
fname = fullfile(isetRootPath,'data','human','XYZ.mat');
xyzEnergy = ieReadSpectra(fname,wave,0);
% vcNewGraphWin; plot(wave,xyzEnergy); grid on

% Row dimension of vector and wave must be equal
q2e = Quanta2Energy(wave,ones(length(wave),1));
% vcNewGraphWin; plot(wave,q2e)

% Human cone absorptions are about 0.3, so we scale them
% here.  This might be set more precisely by users.  The
% PsychToolbox has a description of the references and
% values that we could import here.

% ISET computes based on photons.  So we multiply by a factor that converts
% photons to energy.  We group Photons to Energy and XYZ into a single
% matrix, and save this out. Thus, the calculation is
%
%     OI Photons -> Photons to Energy -> XYZ
%
xyzQuanta = diag(q2e)*xyzEnergy;
% vcNewGraphWin; plot(wave,xyzQuanta); grid on

%% The values of the Y are meaningful (cd/m2).  So we want to make sure that
% if we put in the same light as photons and energy, we get the same value
% back.
d65Energy = ieReadSpectra('D65',wave);      % vcNewGraphWin; plot(wave,d65Energy)
d65Quanta = Energy2Quanta(wave,d65Energy);  % vcNewGraphWin; plot(wave,d65Quanta)
valQ = xyzEnergy'*d65Energy(:);
valE = xyzQuanta'*d65Quanta(:);
if abs(valQ - valE) > 10e-9
    error('Quantal calculation differs from energy');
end

%% Save
oname = fullfile(isetRootPath,'data','human','xyzQuanta.mat');
ieSaveSpectralFile(wave,xyzQuanta,'XYZ in a format to calculate with quantal input',oname);

%% Compare the energy and quantal forms.

% Notice that they are similar where
% there are lots of absorptions, but they differn noticeably at the very
% long and short wavelengths
vcNewGraphWin; plot(wave,xyzEnergy./xyzQuanta); grid on

%% Now make the adjustment for just the Vlambda (Y) function

vlambda = ieReadSpectra('vlambda',wave,0);
vcNewGraphWin; plot(wave,vlambda); grid on
q2e = Quanta2Energy(wave,ones(length(wave),1));
vlambdaQuanta = q2e(:) .* vlambda(:);
vcNewGraphWin; plot(wave,vlambdaQuanta); grid on

% vcNewGraphWin; plot(wave,vlambdaQuanta./vlambda); grid on
%% Save
oname = fullfile(isetRootPath,'data','human','vlambdaQuanta');
ieSaveSpectralFile(wave,vlambdaQuanta,'vLambda in a format to calculate with quantal input',oname);

% Copy to duplicate names
curDir = pwd;
chdir(fileparts(oname))
copyfile('vlambdaQuanta.mat','photopicLuminosityQuanta.mat');
copyfile('vlambdaQuanta.mat','luminosityQuanta.mat');
chdir(curDir)

%% End
