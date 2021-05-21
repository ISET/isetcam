function [optics, inName, outName] = siConvertRTdata(inName,fieldHeight,outName)
% Convert RT optics to a custom optics structure data from one field height
%
%    optics = siConvertRTdata(fName,fieldHeight)
%
% fieldHeight specified in meters
%
% The RT data are a good source of examples for single PSFs from real
% lenses.  This routine creates an optic structure used for shift-invariant
% calculations but with an OTF/PSF drawn from one of the field heights in a
% ray trace (Zemax) calculation.
%
% The saved file can then be used for shift-invariant calculations with a
% custom calculation.
%
%Examples:
%     baseDir = [isetRootPath,'\data\optics\'];
%     inName = fullfile(baseDir,'rtZemaxExample.mat');
%
%     siConvertRTdata;
%
%     fieldHeight = 0.5;
%     siConvertRTdata(inName,fieldHeight,fullfile(baseDir,'siZemaxExample05.mat'));
%
%     fieldHeight = 1.0;
%     siConvertRTdata(inName,fieldHeight,fullfile(baseDir,'siZemaxExample10.mat'));
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('inName'),    inName = vcSelectDataFile; end
if ieNotDefined('fieldHeight')
    fieldHeight = ieReadNumber('Enter field height (mm)',0,'%.02f');
    fieldHeight = fieldHeight/1000;  % fieldHeight must be in meters
end

% Read in the ray traced optics file
tmp = load(inName); rtOptics = tmp.optics; clear tmp;

% Figure out the nyQuist
rtWave    = opticsGet(rtOptics,'rtPSFWavelength');
dx        = opticsGet(rtOptics,'rtPSFSpacing','m');
rtSupport = opticsGet(rtOptics,'rtSupport','m');
nSamples  = size(rtSupport,1);

nyquistF = 1 ./ (2*dx);   % Line pairs (cycles) per meter

OTF = zeros(nSamples,nSamples,length(rtWave));
for ii=1:length(rtWave)
    psf         = opticsGet(rtOptics,'rtpsfdata',fieldHeight,rtWave(ii));
    psf         = psf/sum(psf(:));
    OTF(:,:,ii) = fftshift(fft2(psf));
    % figure;
    % mesh(abs(OTF(:,:,ii)))
    % mesh(abs(fft2(OTF(:,:,ii))))
    % mesh(psf)
end

% Check this - we converted from mm to meters ... make sure everything
% plots and looks OK
fx = unitFrequencyList(nSamples)*nyquistF(2);
fy = unitFrequencyList(nSamples)*nyquistF(1);
% [FY, FX] = meshgrid(fy,fx);
% figure; mesh(FY, FX, abs(OTF(:,:,ii)))
% figure; mesh(FY, FX, OTF(:,:,ii))

optics = opticsCreate;

% We may have a problem with the meters scale here ... we were probably
% setting cyc/mm and now we are setting cyc/meter ...
% April 26, 2008
optics = opticsSet(optics,'otffunction','custom');
optics = opticsSet(optics,'otfData',OTF);
optics = opticsSet(optics,'otffx',fx);
optics = opticsSet(optics,'otffy',fy);
optics = opticsSet(optics,'otfwave',rtWave);

if ieNotDefined('outName'), outName = vcSelectDataFile('stayput','w'); end
vcSaveObject(optics,outName);

return;
