function optics = siSynthetic(psfType,oi,varargin)
% Create synthetic shift-invariant optics
%
% Synopsis
%  optics = siSynthetic(psfType,oi,varargin)
%
% Brief
%  This code creates shift-invariant optics.  We build on this to let the
%  user create a custom shift-invariant optics.
%
% By default, the optics (custom) fields are filled in using simple values.
%
% Inputs
% psfType:  'gaussian'   -- Bivariate normal  (default)
%           'lorentzian' -- Lorentzian (Cauchy) 
%           'pillbox'    -- Square patch
%           'custom'     -- Read a file with the variables, as explained
%                           below.  They are interpolated to match the
%                           optics requirements.
%
% oi:        Optical image (ieGetObject('oi') is the default)
%
% Optional varargin arguments
%
% **Gaussian**
%   waveSpread: Size of the PSF spread (microns) at each of the wavelengths
%   xyRatio:    Ratio of spread in x and y directions
%   filename:   Output file name for the optics
%
% **Lorentzian**
%   gParameter:  The gamma parameter determines tail size.  It is either a
%                scalar, or a vector equal in length to the number of
%                wavelengths in the oi. 
%
% **pillbox**
%   size:        Size of the pillbox edge in microns
%
% **custom**
%   inData  - filename or struct with psf, umPerSamp, and wave data
%   outFile - Optional
%
% See also:  
%   s_opticsSIExamples, ieSaveSIOpticsFile
%

% Examples:
%{
  wave = 400:10:700; psfType = 'gaussian';  waveSpread = wave/wave(1);
  xyRatio = ones(1,length(wave));
  oi = oiCreate('shiftinvariant');
  oi = oiSet(oi,'wave',wave);
  optics = siSynthetic(psfType,oi,waveSpread,xyRatio);
  psfMovie(optics,ieNewGraphWin,0.1);
%}
%{
  % Make one with an asymmetric Gaussian
  wave = 400:10:700; psfType = 'gaussian';  waveSpread = wave/wave(1);
  xyRatio = 2*ones(1,length(wave));
  oi = oiCreate('shiftinvariant');
  oi = oiSet(oi,'wave',wave);
  optics = siSynthetic(psfType,oi,waveSpread,xyRatio);
  psfMovie(optics,ieNewGraphWin);
%}
%{
  wave = 400:10:700; psfType = 'lorentzian'; 
  oi = oiCreate('shiftinvariant');
  oi = oiSet(oi,'wave',wave);
  gParameter = [1:numel(wave)]/numel(wave)*5 + 2;
  optics = siSynthetic(psfType,oi,gParameter);
  psfMovie(optics,ieNewGraphWin);
%}


%% Parameter initializiation
if ieNotDefined('psfType'), psfType = 'gaussian'; end
if ieNotDefined('oi'), oi = vcGetObject('oi'); end
inFile = 'siSynthetic';
outFile = [];

% Wavelength samples
wave     = oiGet(oi,'wave');
nWave    = length(wave);

% Spatial samples used for ISET representation of the OTF
nSamples = 129;                  % 128 samples, spaced 0.25 um
OTF      = zeros(nSamples,nSamples,nWave);
dx(1:2)  = 0.25*1e-3;            % The output sampling in mm per samp

%% Create psf and OTF

switch lower(psfType)
    case 'gaussian'
        % Create a Gaussian set of PSFs.
        if length(varargin) < 2, error('Wavespread and xyRatio required'); end

        xSpread = varargin{1};    % Spread is in units of um here
        if isscalar(xSpread), xSpread = ones(nWave,1)*xSpread;
        elseif numel(xSpread) == nWave
        else
            error('Bad number of entries in xSpread')
        end

        xyRatio = varargin{2};
        if isscalar(xyRatio), xyRatio = ones(nWave,1)*xyRatio;
        elseif numel(xyRatio) == nWave
        else,  error('Bad number of entries in xyRatio')
        end
        
        ySpread  = xSpread(:) .* xyRatio(:);
        if length(varargin) == 3, outFile = varargin{3};
        else, outFile = []; end
        
        % Convert spread from microns to millimeters because OTF data are stored in
        % line pairs per mm
        xSpread = double(xSpread/1000);  ySpread = double(ySpread/1000);
        
        for jj = 1:nWave
            % We convert from spread in mm to spread in samples for the
            % biNormal calculation.
            psf         = biNormal(xSpread(jj)/dx(2),ySpread(jj)/dx(1),0,nSamples);
            psf         = psf/sum(psf(:));
            psf         = rot90(psf);     % Testing
            psf         = ifftshift(psf);  % Place center of psf at (1,1)
            OTF(:,:,jj) = fft2(psf);
        end

    case 'lorentzian'
        if isempty(varargin), gParameter = 1;
        else, gParameter = varargin{1};
        end

        if isscalar(gParameter)
            g = gParameter*ones(nWave,1);
        elseif numel(gParameter) == nWave, g = gParameter;
        else, error('gParameter must be scalar or vector with nWave values.');
        end

        % Scale for the radius of the 128 x 128 PSF size
        [X,Y] = meshgrid(1:nSamples,1:nSamples);
        X = X - mean(X(:)); Y = Y - mean(Y(:));
        r = sqrt(X.^2 + Y.^2);
        for jj=1:nWave
            psf = 1 ./ (1 + (r/g(jj)).^2);
            psf         = psf/sum(psf(:));
            psf         = ifftshift(psf);  % Place center of psf at (1,1)
            OTF(:,:,jj) = fft2(psf);
        end
    case 'pillbox'
        % Square patch of patchSize.  Wavelength dependency not yet
        % implemented.

        if isempty(varargin)
            % Choose size of the pillbox that is a little bigger than the
            % Airy Disk size.  The dx units above are in millimeters
            % because the OTF in optics is in millimeters.
            fNumber = oiGet(oi,'optics fnumber');
            patchSize = airyDisk(700,fNumber,'units','mm');
        else
            patchSize = varargin{1};
        end

        % nSamples is 1:129, so the center location is 65
        psfSamples = ceil(patchSize/dx(1));
        samples    = ((nSamples+1)/2 - psfSamples):((nSamples+1)/2 + psfSamples);

        psf = zeros(nSamples,nSamples); 
        psf(samples,samples) = 1;
        psf = psf/sum(psf(:));
        psf = ifftshift(psf);  % Place center of psf at (1,1)

        for jj=1:length(wave)
            OTF(:,:,jj) = fft2(psf);
        end        

    case 'custom'
        % Get PSF data from a file.  Interpolate the data

        if isempty(varargin)
            % Find a file by asking user
            inFile = ...
                vcSelectDataFile('stayPut','r','mat','Select custom SI optics');
            if isempty(inFile)
                disp('User canceled'); optics = []; return;
            end
        elseif ischar(varargin{1})
            % This is a file name.  Load it and get parameters
            tmp = load(varargin{1});
            if ~isfield(tmp,'psf'),  error('Missing psf variable');
            else, psfIn = tmp.psf; end
            if ~isfield(tmp,'wave'), error('Missing wave variable');
            else, wave = tmp.wave; end
            if ~isfield(tmp,'umPerSamp'), error('Missing wave variable');
            else, mmPerSamp = (tmp.umPerSamp)/1000; end
        elseif isstruct(varargin{1})
            % The psf data were sent in as a struct with slots for the psf
            % itself (psf), wavelength samples and spacing in microns per
            % sample.
            psfData = varargin{1};
            psfIn = psfData.psf;
            wave  = psfData.wave;
            mmPerSamp = (psfData.umPerSamp)/1000;
        end
        if length(varargin) > 1, outFile = varargin{2}; end
        
        % Check the parameters for consistency
        [m,n,nWave] = size(psfIn);
        if length(wave) ~= nWave
            error('Mis-match between wavelength and psf');
        end
        if m ~= nSamples || n ~= nSamples
            error('Not sure why we have this constraint');
        end
        
        
        %% OTF computation
        
        % This is the sampling grid of the psfIn.
        % Units are in mm.
        x = (1:n)*mmPerSamp(2); x = x - mean(x(:));
        y = (1:m)*mmPerSamp(1); y = y - mean(y(:));
        [xInGrid, yInGrid] = meshgrid(x,y);
        
        xOut = (1:nSamples)*dx(2); xOut = xOut - mean(xOut(:));
        yOut = (1:nSamples)*dx(1); yOut = yOut - mean(yOut(:));
        [xOutGrid, yOutGrid] = meshgrid(xOut,yOut);
        
        for ii=1:nWave
            psf = interp2(xInGrid,yInGrid,psfIn(:,:,ii),xOutGrid,yOutGrid,'linear',0);
            psf = psf/sum(psf(:));    % figure(1); mesh(psf)
            psf = fftshift(psf);      % Place center of psf at (1,1)
            OTF(:,:,ii) = fft2(psf);  % figure(1); mesh(OTF(:,:,ii))
        end
    otherwise
        error('Unspecified PSF format');
end

%% Find OI sample spacing.  The OTF line spacing is managed in lines/mm

nyquistF = 1 ./ (2*dx);   % Line pairs (cycles) per mm
fx = unitFrequencyList(nSamples)*nyquistF(2);
fy = unitFrequencyList(nSamples)*nyquistF(1);

% [FY, FX] = meshgrid(fy,fx); vcNewGraphWin; mesh(FY, FX, fftshift(abs(OTF(:,:,2))))

%% Create and save the optics
optics = opticsCreate;
optics = opticsSet(optics,'name',inFile);
optics = opticsSet(optics,'model','shiftinvariant');
optics = opticsSet(optics,'otf function','custom');
optics = opticsSet(optics,'otf data',OTF);
optics = opticsSet(optics,'otf fx',fx);   % Cycles per millimeter
optics = opticsSet(optics,'otf fy',fy);   % Cycles per millimeter
optics = opticsSet(optics,'otf wave',wave);

if isempty(outFile), return;
else,                vcSaveObject(optics,outFile);
end

if exist(fullfile(tempdir,'deleteMe.mat'),'file'), delete(fullfile(tempdir,'deleteMe.mat')); end
if exist(fullfile(tempdir,'customFile.mat'),'file'), delete(fullfile(tempdir,'customFile.mat')); end


end

