function oi = opticsPSF(oi,scene,aperture,wvf,varargin)
% Apply the opticalImage using the PSF method to the photon data
%
% Synopsis
%    oi = opticsPSF(oi,scene,varargin);
%
% Inputs
%   oi
%  scene
%
% Optional key/val
%
% Return
%   oi
%
% Description
%  FIX FIX
%   The optical transform function (OTF) associated with the optics in
%   the OI is applied to the scene data.  This function is called for
%   shift-invariant and diffraction-limited models.  It is not called
%   for the ray trace calculation, which uses the (ray trace method)
%   pointspreads derived from Zemax.
%
%   The OTF data are spectral and thus can be rather large.  The
%   spectral OTF represents every spatial frequency in every waveband.
%
%   The programming issues concerning using Matlab to apply the OTF to the
%   image (rather than convolution in the space domain) are explained
%   below.
%
% See also
%  oiCalculateOTF, oiCompute
%
% Examples:
%  oi = opticsOTF(oi);      % Not saved
%  oi = opticsOTF(oi,1);    % OTF data are saved -- NOT YET IMPLEMENTED
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

%
if ieNotDefined('oi'),     error('Optical image required.'); end
if ieNotDefined('aperture'), aperture = [];  end
if ieNotDefined('wvf'),           wvf = [];  end
if ieNotDefined('unit'),         unit = 'mm';end

% Pad the optical image to allow for light spread.  Also, make sure the row
% and col values are even.
imSize   = oiGet(oi,'size');
padSize  = round(imSize/8);
padSize(3) = 0;
sDist = sceneGet(scene,'distance');

% ISETBio and ISETCam, historically, used different padding
% strategies.  Apparently, we have zero, mean and border implemented -
% which are not all documented at the top.  We should also allow spd
% and test it. Zero photons was the default for ISETCam, and mean
% photons was the default for ISETBio.  
% 
% This update is being tested as of 9/25/2023.
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

% Convert the oi into the wvf format and compute the PSF
wavelist  = oiGet(oi,'wave');
flength   = oiGet(oi,'focal length',unit);
fnumber   = oiGet(oi,'f number');

% WVF is square.  Use the arger of the two sizes
oiSize    = max(oiGet(oi,'size'));   

if isempty(wvf)
    wvf = wvfCreate('wave',wavelist);
end

% Make sure the wvf matches how the person set the oi/optics info
wvf = wvfSet(wvf, 'focal length', flength, unit);
wvf = wvfSet(wvf, 'calc pupil diameter', flength/fnumber);
wvf = wvfSet(wvf, 'wave',wavelist);
wvf = wvfSet(wvf, 'spatial samples', oiSize);

% Setting this matches the pupil sample spacing with the oi sample
% spacing.
%
% BW: Worried about the lambdaM fixed value.
psf_spacing = oiGet(oi,'sample spacing',unit);

% 550 nm.
lambdaM = 550*1e-9;
lambdaUnit = ieUnitScaleFactor(unit)*lambdaM;

% Set the reference field size (see t_wvfOverview).  This set only takes mm
% for now.  We may change in the future.
pupil_spacing    = lambdaUnit * flength / (psf_spacing(1) * oiSize);
currentUnitScale = ieUnitScaleFactor(unit);
mmUnitScale      = 1000/currentUnitScale;
wvf = wvfSet(wvf,'field size mm', pupil_spacing * oiSize * mmUnitScale); % only accept mm

% Compute the PSF.  We may need to consider LCA and other parameters
% at this point.  It should be possible to set this true easily.
if ~isempty(wvf.customLCA)
    % For now, human is the only option
    if strcmp(wvf.customLCA,'human')
        wvf = wvfCompute(wvf,'aperture',aperture,'human lca',true);
    end
else
    % customLCA is empty
    wvf = wvfCompute(wvf,'aperture',aperture,'human lca',false);
end

% Make this work:  wvfPlot(wvf,'psf space',550);

% Old
% otfM = oiCalculateOTF(oi, wave, unit);  % Took changes from ISETBio.

nWave = numel(wavelist);

% All the PSFs
PSF = wvfGet(wvf,'psf');
if ~iscell(PSF)
    tmp = PSF; clear PSF; PSF{1} = tmp;
end

% Get the current data set.  It has the right size.  We over-write it
% below.
p = oiGet(oi,'photons');
oiHeight = size(p,1);
oiWidth = size(p,2);

otf = zeros(oiSize,oiSize,nWave);

for ww = 1:nWave
    
    % Deal with non square scenes
    if oiWidth ~= oiHeight
        sz = double(abs(oiWidth - oiHeight)/2);
        if oiWidth < oiHeight
            photons = padarray(p(:,:,ww),[0,sz],0,'both');
            photons = ImageConvFrequencyDomain(photons,PSF{ww}, 2);
            p(:,:,ww) = photons(:,sz+1:sz+oiWidth);
        else
            photons = padarray(p(:,:,ww),[sz,0],0,'both');
            photons = ImageConvFrequencyDomain(photons,PSF{ww}, 2);
            p(:,:,ww) = photons(sz+1:sz+oiHeight,:);
        end
    else
        p(:,:,ww) = ImageConvFrequencyDomain(p(:,:,ww), PSF{ww}, 2 );
    end
    % otf requires a single wavelength
    otf(:,:,ww) = wvfGet(wvf,'otf',wavelist(ww));
end

oi = oiSet(oi,'photons',p);

wvfOptics = wvf2optics(wvf);

% Update the OTF struct while preserve the optics struct.
oi.optics.OTF = wvfOptics.OTF;

% We saved OTF in optics, we can clear the data saved in wvf, if we need
% them, we can call wvfCompute.
wvf = wvfClearData(wvf);

oi = oiSet(oi,'optics wvf',wvf);
end

