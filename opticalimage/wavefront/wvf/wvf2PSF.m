function [siData, wvfP] = wvf2PSF(wvfP, showBar)
% Convert wvf structure data to ISET shift-invariant PSF data
%
%    [siData, wvfP] = wvf2PSF(wvfP)
%
% For examples of how to convert to an optical image, which is perhaps more
% practical, see wvf2oi.m 
%
% For each wavelength in wvf, compute the PSF with proper units and
% place it in an ISET shift-invariant PSF format that can be used for human
% optics simulation.
%
% The wvfP is the main wavefront optics toolbox structure. The psf is
% computed at the wave values in the structure.  The updated structure with
% the PSFs can be returned.
%
% The data can be saved in ISET format using ieSaveSIDataFile as in the
% example below. which loads the standard human data for a particular pupil
% size. Alternatively, the siData can be converted to an optics structure
% with the function siSynthetic.  
%
% Example:
%    pupilMM = 3; zCoefs = wvfLoadThibosVirtualEyes(pupilMM);
%    wave = [450:100:650]';
%    wvfP = wvfCreate('wave',wave,'zcoeffs',zCoefs,'name',sprintf('human-%d',pupilMM));
%
%    [d, wvfP] = wvf2PSF(wvfP);
%    fName = sprintf('psfSI-%s',wvfGet(wvfP,'name'));
%    ieSaveSIDataFile(d.psf,d.wave,d.umPerSamp,fName);
%  
%    oi = oiCreate('human'); 
%    optics = siSynthetic('custom',oi,d);
%    flength = 0.017;  % Human focal length is 17 mm
%    oi = oiSet(oi,'optics fnumber',flength/pupilMM);
%    oi = oiSet(oi,'optics flength',flength);
%    oi = oiSet(oi,'optics',optics);
%
%    vcNewGraphWin([],'tall');
%    subplot(2,1,1), wvfPlot(wvfP,'image psf','um',550,15,'no window');
%    subplot(2,1,2), wvfPlot(wvfP,'image psf','um',550,15,'no window');
%
% See also: wvf2oi
%
% Copyright Imageval 2012

%% Parameters
if notDefined('wvfP'),    error('wvf parameters required.'); end
if notDefined('showBar'), showBar = ieSessionGet('wait bar'); end

wave = wvfGet(wvfP,'wave');
nWave = wvfGet(wvfP,'nwave');

%% Use WVF to compute the PSFs
wvfP = wvfComputePSF(wvfP);

% Set up to interpolate the PSFs for ISET spacing in microns between
% samples.
nPix = 128;                 % Number of pixels in ISET representation
umPerSamp = [0.25,0.25];    % In microns in ISET
iSamp = (1:nPix)*umPerSamp(1);
iSamp = iSamp - mean(iSamp);
iSamp = iSamp(:);
psf = zeros(nPix,nPix,nWave);

if showBar, wBar = waitbar(0,'Creating PSF'); end
for ii=1:nWave,
    if showBar, waitbar(ii/nWave,wBar); end
    thisPSF = wvfGet(wvfP,'psf',wave(ii));  % vcNewGraphWin; imagesc(thisPSF)
    
    % These are the samples in space as per the wavefront calculation.  I
    % don't understand how they are calculated but as of today, they are
    % not correctly coordinated with ISET
    samp = wvfGet(wvfP,'psf spatial samples','um',wave(ii));
    samp = samp(:);
    
    % Do the interpolation
    psf(:,:,ii) = interp2(samp,samp',thisPSF,iSamp,iSamp');
    % wvfPlot(wvfP,'image psf space','um',wave(ii),50)
end
if showBar, close(wBar); end

siData.psf = psf;
siData.wave = wave;
siData.umPerSamp = umPerSamp;

end


%% From ISET script on how to create an SI data file

% Now, write out a file containing the relevant point spread function
% data, along with related variables.
% umPerSample = [0.25,0.25];                % Sample spacing
% 
% % Point spread is a little square in the middle of the image
% h = zeros(128,128); h(48:79,48:79) = 1; h = h/sum(h(:));
% for ii=1:length(wave), psf(:,:,ii) = h; end     % PSF data
% 
% % Save the data
% ieSaveSIDataFile(psf,wave,umPerSample,'SI-pillBox');
