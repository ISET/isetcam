function oi = opticsPSF(oi,scene,aperture,wvf,varargin)
% Calculate the optical image from the scene, using the PSF method
%
% Synopsis
%    oi = opticsPSF(oi,scene,varargin);
%
% Inputs
%   oi
%   scene
%
% Optional key/val
%  aperture
%  wvf
%  padvalue
%
% Return
%   oi
%
% Description
%  This function is called for shift-invariant and diffraction-limited
%  models.  It is not called for the ray trace calculation, which uses
%  the (ray trace method).
%
%  When 'skip' is not set, we use the method oiApplyPSF below. That
%  method 
% 
%   * uses one of several approaches to pad the OI
%   * sets the wvf parameters in the optics struct to match the
%  scene spectral radiance spatial sampling (see oiApplyPSF, lines
%  ...). 
%
%  The programming issues concerning using Matlab to apply the OTF to
%  the image (rather than convolution in the space domain) are
%  explained below.
%
% See also
%  oiCalculateOTF, oiCompute
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Parse

varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('oi',@(x)(isstruct(x) && isequal(x.type,'opticalimage')));
p.addRequired('scene',@(x)(isstruct(x) && isequal(x.type,'scene')));

if ieNotDefined('aperture'), aperture = []; end
if ieNotDefined('wvf'), wvf = []; end

p.addParameter('padvalue','zero',@(x)(ischar(x) || isvector(x)));

p.parse(oi,scene,varargin{:});

%%
optics      = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');

switch lower(opticsModel)
    case {'skip','skipotf'}
        irradianceImage = oiGet(oi,'photons');
        oi = oiSet(oi,'photons',irradianceImage);
        
    case {'dlmtf','diffractionlimited','shiftinvariant','custom','humanotf'}
        oi = oiApplyPSF(oi,scene,aperture,wvf,'mm',p.Results.padvalue);
        
    otherwise
        error('Unknown OTF method');
end

end

%-------------------------------------------
function oi = oiApplyPSF(oi,scene,aperture,wvf,unit,padvalue)
%Calculate and apply the otf waveband by waveband
%
%   oi = oiApplyPSF(oi,method,unit);
%
% We calculate the OTF every time, never saving it, because it can take up
% a lot of space and is not that hard to calculate.  Also, any change to
% the optics properties would make us recompute the OTF, and keeping things
% synchronized can be error prone.
%
% Example:
%    oi = oiApplyPSF(oi);
%
% Copyright ImagEval Consultants, LLC, 2003.
 
% Input handling
if ieNotDefined('oi'),     error('Optical image required.'); end
if ieNotDefined('aperture'), aperture = [];  end
if ieNotDefined('wvf'),           wvf = [];  end
if ieNotDefined('unit'),         unit = 'mm';end

%% Pad the optical image to allow for light spread.  

% Also, make sure the row  and col values are even.
imSize   = oiGet(oi,'size');
padSize  = round(imSize/8);
padSize(3) = 0;
sDist = sceneGet(scene,'distance');

% ISETBio and ISETCam, historically, used different padding
% strategies.  Apparently, we have zero, mean and border implemented -
% which are not all documented at the top.  We should also allow spd
% and test it. Zero photons was the default for ISETCam, and mean
% photons was the default for ISETBio.
switch padvalue
    case 'zero'
        padType = 'zero photons';
    case 'mean'
        padType = 'mean photons'; 
    case 'border'
        padType = 'border photons'; 
    case 'spd'
        error('spd padvalue not yet implemented.')
    otherwise
        error('Unknown padvalue %s',padvalue);
end

oi = oiPadValue(oi,padSize,padType,sDist);

%% Get information from the oi 

% We will set some of this into the wvf and compute the PSF
wavelist  = oiGet(oi,'wave');
flength   = oiGet(oi,'focal length',unit);
fnumber   = oiGet(oi,'f number');

% WVF is square.  Use the larger of the two sizes
oiSize    = max(oiGet(oi,'size'));   

% It is possible (but unlikely) to get here without having a wvf
% structure stored in the optics of the oi.  That is made an explicit
% error, rather than making up a wvf.
if isempty(wvf)
    if (isfield(oi,'optics') && isfield(oi.optics,'wvf'))
        wvf = oi.optics.wvf;
    else
        error('Applying PSF method with an empty wvf structure and no optics.wvf field.');
    end
end

% Make sure the wvf matches how the person set the oi/optics info
wvf = wvfSet(wvf, 'focal length', flength, unit);
wvf = wvfSet(wvf, 'calc pupil diameter', flength/fnumber);
wvf = wvfSet(wvf, 'wave',wavelist);
wvf = wvfSet(wvf, 'spatial samples', oiSize);

%% Get read to compute the PSF

% With this information set, we can match the pupil sample spacing
% with the desired oi sample spacing. This also determines the
% frequency samples for the OTF.
psf_spacing = oiGet(oi,'sample spacing',unit);

% Default measurement wavelength is 550 nm.
lambdaM = wvfGet(wvf, 'measured wl', 'm');

lambdaUnit = ieUnitScaleFactor(unit)*lambdaM;

% Calculate the pupil sample spacing to match the PSF and the oi
% spatial samples.
pupil_spacing    = lambdaUnit * flength / (psf_spacing(1) * oiSize); % in meters

% Account for different unit scale, scale the user input unit to mm, 
% This set only takes mm for now.
currentUnitScale = ieUnitScaleFactor(unit);
mmUnitScale      = 1000/currentUnitScale;
wvf = wvfSet(wvf,'field size mm', pupil_spacing * oiSize * mmUnitScale); % only accept mm

% Compute the pupil function with the new parameters
wvf = wvfCompute(wvf,'aperture',aperture);

% Get the wavelength-dependent PSFs
PSF = wvfGet(wvf,'psf');
if ~iscell(PSF)
    tmp = PSF; clear PSF; PSF{1} = tmp;
end

%% Apply the PSF to the scene photons

% One wavelength at a time
p = oiGet(oi,'photons');
oiHeight = size(p,1);
oiWidth = size(p,2);
nWave = numel(wavelist);

for ww = 1:nWave
    
    % Deal with non square scenes
    if oiWidth ~= oiHeight
        %  sz = round(double(abs(oiWidth - oiHeight)/2));

        % Find the difference between height and width, and set sz to
        % compensate.
        delta = abs(oiWidth - oiHeight);
        if isodd(delta) 
            sz(1) = floor(delta/2); sz(2) = sz(1) + 1;
        else
            sz(1) = delta/2; sz(2) = sz(1);
        end

        if oiWidth < oiHeight
            % Add zeros to the columns
            photons = padarray(p(:,:,ww),[0,sz(1)],0,'pre');
            photons = padarray(photons,[0,sz(2)],0,'post');
            % photons = padarray(p(:,:,ww),[0,sz],0,'both');
            % photons = ImageConvFrequencyDomain(photons,PSF{ww}, 2);
            photons = fftshift(ifft2(fft2(photons) .* fft2(PSF{ww})));
            p(:,:,ww) = photons(:,sz(1)+(1:oiWidth));
        else
            photons = padarray(p(:,:,ww),[sz(1),0],0,'pre');
            photons = padarray(photons,[sz(2),0],0,'post');
            photons = fftshift(ifft2(fft2(photons) .* fft2(PSF{ww})));
            p(:,:,ww) = photons(sz(1)+(1:oiHeight),:);
        end
    else
        % This is where we usually work for square scenes.
        p(:,:,ww) = ifft2( fft2(p(:,:,ww)) .* fft2(ifftshift(PSF{ww})) );
        
    end

end

% Set the transformed photons into the OI
oi = oiSet(oi,'photons',p);

% Convert the modified wvf to the updated optics
wvfOptics = wvf2optics(wvf);

% Update the only the OTF, preserving the rest of the optics struct.
% When we are computing with the opticsPSF method, we do not need to
% store this.  But it is convenient to have for plotting and to be
% consistent with the opticsOTF path, which still exists.
oi.optics.OTF = wvfOptics.OTF;

% We saved OTF in optics, we can clear the data saved in wvf. When we need
% them again, we call wvfCompute.  
% We clear
% wvf.psf, wvf.wavefrontaberrations, wvf.pupilfunc, wvf.areapix, and
% wvf.areapixapod.

wvf = wvfClearData(wvf);

% Update the wvf
oi = oiSet(oi,'optics wvf',wvf);

end

