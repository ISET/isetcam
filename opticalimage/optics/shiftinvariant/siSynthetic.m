function optics = siSynthetic(psfType,oi,varargin)
%Create synthetic shift-invariant optics
%
%  optics = siSynthetic(psfType,oi,varargin)
%
% This code was used for testing the shift-invariant optics.  We build on
% this to let the user create a custom shift-invariant optics.
%
% By default, the optics (custom) fields are filled in using simple values.
%
% psfType:  'gaussian' --  bivariate normals.
%           'custom'   --  read a file with variables explained below
% oi:        Optical image
%
% varargin for gaussian:
%   waveSpread: size of the PSF spread at each of the wavelength
%             for gaussian this is in microns (um)
%   xyRatio:   Ratio of spread in x and y directions
%   filename:  Output file name for the optics
%
% varargin for custom
%   inData  - filename or struct with psf, umPerSamp, and wave data
%   outFile - Optional
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:  s_SIExamples, ieSaveSIOpticsFile
%  t_codeFFTinMatlab for an explanation of some of the operations in here.
%

% Examples:
%{
  wave = 400:10:700; psfType = 'gaussian';  waveSpread = wave/wave(1);
  xyRatio = ones(1,length(wave));
  optics = siSynthetic(psfType,oi,waveSpread,xyRatio);
  psfMovie(optics,ieNewGraphWin);
%}
%{
% Make one with an asymmetric Gaussian
  wave = 400:10:700; psfType = 'gaussian';  waveSpread = wave/wave(1);
  xyRatio = 2*ones(1,length(wave));
  optics = siSynthetic(psfType,oi,waveSpread,xyRatio);
  psfMovie(optics,ieNewGraphWin);
%}
%{
% Convert a custom file to an optics structure
%  ieSaveSIOpticsFile(rand(128,128,31),(400:10:700),[0.25,0.25],'custom.mat');
%  inFile = 'custom'; outFile = 'deleteMe.mat'
%  optics = siSynthetic('custom',oi,'custom',[]);
%}
%{
%  optics = siSynthetic('custom',oi,inFile,outFile);
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
nSamples = 128;                  % 128 samples, spaced 0.25 um
OTF      = zeros(nSamples,nSamples,nWave);
dx(1:2)  = 0.25*1e-3;              % The output sampling in mm per samp

%% Create psf and OTF

switch lower(psfType)
    case 'gaussian'
        % Create a Gaussian set of PSFs.
        if length(varargin) < 2, error('Wavespread and xyRatio required'); end
        xSpread = varargin{1};    % Spread is in units of um here
        xyRatio = varargin{2};
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
            psf         = fftshift(psf);  % Place center of psf at (1,1)
            OTF(:,:,jj) = fft2(psf);
        end
    case 'custom'
        %% Get PSF data
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

