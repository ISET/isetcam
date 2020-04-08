function [optics, opticsFile] = rtImportData(optics,rtProgram,pFileFull)
%Import data for optics ray trace calculations
%
%  [optics, opticsFile] = rtImportData(optics,rtProgram,pFileFull)
%
% Description:
%  The imported data files are produced by the macros ISET_RT_CODEV.SEQ or
%  ISET_RT_ZEMAX.ZPL run from within those ray tracing programs.
%  Instructions for using those macros are posted on the ImagEval web-site.
%
%  The ray trace (rt) data are returned as part of the optics structure
%  (optics.rt).
%
% Using the GUI (oiWindow), the user can export the optics.rt information
% (oiWindow | Optics | Import Optics).
%
% If it is exported, then the ray trace it can be imported using the Import
% Optics pull down in the (oiWindow | Optics | Import Optics)
%
% Ray trace methods can be used in the optics computation by selecting
% the 'Custom Compute' button and then selecting the custom computation
% routine:  opticsRayTrace
%
% The ray trace point spread functions (PSFs) are not always centered on
% the sampling grid.  This produces an unwanted image displacement, and
% this can be quite significant given that we are sampling the PSFs at
% several hundred microns.  The distortion should be handled properly by
% the rtGeometry call, so that in principle these PSFs should be centered.
% We can enforce such symmetry here, and we do at the user's option.
%
% There is also the issue of the rotation.  We assume that the x-axis is 0
% deg. But the zemax function provides us with image height along the
% y-axis.  So, we rotate the PSFs here when we symmetrize.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also

% Examples
%{
% Fails - need to make it work properly with a test data set.
%  oi = vcGetObject('oi'); optics = oiGet(oi,'optics');
%  optics = rtImportData(optics);
%  oi = sceneSet(oi,'optics',optics);;
%  vcReplaceObject(oi);
%}

% TODO:
%
% We are concerned that at present (4.25.2008) the x,y dimensions of zemax
% are flipped from the x,y of ISET.  We think we need to rotate the zemax
% data before storing it.
%
% Read the Chief Ray Angle data
% Read the header for the psfSpacing (in microns) and interpolate to 0.25
% micron samples or some common size support for the PSF.
%
% All of the rt fields should be set using opticsSet(optics,'rtMumble')
% instead of directly touching the structure, as we do here.
%
% The user should have an opportunity to symmetrize the PSFs w.r.t the
% current sampling grid (rtPSFCenter).  They should also be able to
% rotate the data which are normally entered along the y-axis but should be
% entered along the x-axis (I think).

%% Argument checking
if ieNotDefined('rtProgram'), rtProgram = 'zemax'; end
rt.program = rtProgram;

%  Read the ISETPARMS file
if ieNotDefined('pFileFull')
    pFileFull = vcSelectDataFile('stayput','r','txt','Select the ISETPARMS.txt file');
    if isempty(pFileFull)
        disp('User canceled')
        return;
    end
end

% Filled in if we save.  Otherwise, left empty.
opticsFile = [];

%% Read the file, which was written out by Zemax.  
% As Zemax evolves, and textscan evolves, we have had some issues staying
% abreast.
fid = fopen(pFileFull,'r');
if fid == -1,  error('Unable to open %s\n',pFileFull);
else
    s = fread(fid,'*char');
    fclose(fid);
end

% This is how we strip out the non-ascii characters and evaluate the text
% in the file.
asciiValues = s( (s<128) & (s > 0))';
eval(asciiValues)   % Keep only the ascii characters
fprintf('Reduced character count from %d to %d\n',length(s),length(asciiValues));

% success = copyfile([filename,ext],[filename,'.m']);
% if ~success, errordlg('Error moving parameters file.  Check permissions.'); end

% Perhaps we should be getting the transmittance out of ZEMAX/CODEV?

% Evaluate the parameters file and set basic parameters
%
% The m-file produced by Code V or Zemax looks something like this:
%
% %   C:\PROGRAM FILES\ZEMAX\LENSES\EO54852.ZMX
% lensFile='EO54852.ZMX';      %Lens file name
% psfSize=128;                 % PSF ROW AND COL SIZE
% wave=400:50:700;             % WAVELENGTH SAMPLES (NM)
% imgHeightNum=13;             % Number of IMAGE HEIGHTS
% imgHeightMax=3.0000000;      % Maximum IMAGE HEIGHT (MM)
% objDist=250.000;                 % OBJECT DISTANCE (MM)
% mag=-0.023954;          % OPTICAL SYSTEM MAGNIFICATION
% baseLensFileName='EO54852'
% refWave=587.562;          % REFERENCE WAVELENGTH (NM)
% fov=26.198448;          % MAXIMUM DIAGONAL HALF FOV (DEGREE)
% efl=5.999968;          % EFFECTIVE FOCAL LENGTH (MM) 
% fnumber_eff=1.780820;          % EFFECTIVE F-NUMBER
% fnumber=1.774644;          % F-NUMBER

% eval(filename);

%% Set up the parameters into rt structure

% Make sure the psf size is even.  Maybe it should be a power of 2?
if isodd(psfSize), error('PSF size must be even.'); end %#ok<NODEF>

rt.lensFile = lensFile;                 % *.LEN file
rt.referenceWavelength = refWave;       % Reference wavelength
rt.objectDistance = objDist;            % Distance of object?
rt.mag = -abs(mag);                     % We force it negative.  Problem for microscopes

% PM should implement these calculations in Zemax if possible
rt.fNumber = fnumber;                   % f# = (Focal length)/(Entrance pupil diameter)
rt.effectiveFocalLength = efl;          % Equivalent focal length for multicomponent lens
rt.effectiveFNumber = fnumber_eff;      % Effectve f# = 0.5/(NUMERICAL APERTURE)

% These are the image heights used in the simulation
% This code assumes that we always start at the center of the image, that
% is at an image height of zero.
imgHeight = ((0:(imgHeightNum-1))/(imgHeightNum-1))*imgHeightMax;

% The PSF goes out to the FOV and we treat the readout as a circle.  We
% have the field of view here. We multiply the number by 2 because in ZeMax
% the original value is half of the FOV.
rt.fov = fov * 2;

% These are full path file names
% [diName,riName,psfNameList] = rtFileNames(baseLensFileName,wave,imgHeight); %#ok<NODEF>
[~,baseName,~] = fileparts(baseLensFileName);
[diName,riName,psfNameList] = rtFileNames(baseName,wave,imgHeight); %#ok<NODEF>

%%  Load the geometry - needs fixing up.
% diName = 'I-Phone 5_DI_.dat';
nWave   = length(wave);
nHeight = length(imgHeight);

rt.geometry.fieldHeight = imgHeight(:);
rt.geometry.wavelength = wave(:);

% Read the geometry distortion file produced by Zemax
fid = fopen(diName,'r');
if fid == -1,  error('Unable to open %s\n',diName);
else
    s = fread(fid,'*char');
    fclose(fid);
end

% This method for reading the new Zemax file is not going well (Brian).
% Note that the zemaxLoad() uses 129, not 128.
asciiValues = s( (s < 128) & (s > 0) )';
dCell = textscan(asciiValues,'%f'); 
d = dCell{1};

% The function is stored as (field height x wavelength)
% For backwards compatibility this is correct (Brian)
rt.geometry.function = reshape(d,nWave,nHeight)';  

%%  Load the relative illumination

rt.relIllum.fieldHeight = imgHeight(:);
rt.relIllum.wavelength = wave(:);
fid = fopen(riName,'r');
if fid == -1,  error('Unable to open %s\n',diName);
else
    s = fread(fid,'*char');
    fclose(fid);
end

asciiValues = s( (s < 128) & (s > 0) )';  % This eliminates non-ascii chars
dCell = textscan(asciiValues,'%f');    % Read and save
d = dCell{1};

% (field height x wavelength)
rt.relIllum.function = reshape(d,nWave,nHeight)';  % For backwards compatibility (Brian)

%% Fill up the psf data

switch lower(rtProgram)
    %     case 'code v'
    %         % In this case, psfSpacing is in the parameters file
    %         [r,c] = size(load(psfNameList{1,1}));
    case 'zemax'
        % For Zemax, we read psfSpacing, usually 0.2500 uM and data area,
        % usually 32 microns (128*0.25), from the file.  The ratio is the
        % number of samples. We check this for every file as we read (see
        % below).  This is true for the Fps command.  (We are experimenting
        % with the Hps command).
        [psfSpacing, psfArea] = zemaxReadHeader(psfNameList{1,1});
        psfSize = psfArea/psfSpacing;
        if round(psfSize) ~= psfSize
            warning('MATLAB:rtImportSizeError','Sample size and Image delta problem');
            psfSize = round(psfSize);
        end
    otherwise
        errordlg('Unknown rtProgram');
end

rt.psf.function = zeros(psfSize,psfSize,nHeight,nWave);

% Load the pointspread function data into a 4D array
% (row,col,imgHeight,Wavelength)
[~,baseLensFile] = fileparts(lensFile);
showBar = ieSessionGet('waitbar');
if showBar, wBar = waitbar(0,'Converting PSF data'); end
warningGiven = 0;
for ii=1:length(imgHeight)
    if showBar
        waitbar(ii/nHeight,wBar,sprintf('%s (FH %.2f)',strrep(baseLensFile,'_','-'),imgHeight(ii)));
    end
    
    for jj=1:length(wave)
        switch lower(rtProgram)
            %             case 'code v'
            %                 % This should become codevLoad(); and include a check for
            %                 % key
            %                 rt.psf.function(:,:,ii,jj) = load(psfNameList{ii,jj});
            case 'zemax'
                [testSpacing, testArea] = zemaxReadHeader(psfNameList{ii,jj});
                if isempty(testSpacing) || isempty(testArea)
                    errordlg(sprintf('Bad file: %s',psfNameList{ii,jj}));
                end
                if (testSpacing == psfSpacing) && (testArea == psfArea)
                    tmp = zemaxLoad(psfNameList{ii,jj},psfSize);
                    if sum(tmp(:)) ~= 1 && ~warningGiven
                        warningGiven = 1;
                        fprintf('Area under psf: %f\n',sum(tmp(:)));
                        warning('Matlab:rtScalingPSF','Scaling area under psf to 1'); 
                        tmp = tmp/sum(tmp(:));
                    end
                    rt.psf.function(:,:,ii,jj) = tmp;
                else
                    str = sprintf('PSF data have the wrong size: %s',psfNameList{ii,jj});
                    errordlg(str); return;
                end
        end
    end
end

% We should ask the user if the psf data should be centered at this
% point.
% r = questdlg('Center PSFs on grid?');
% if strcmp(r,'Yes')
%     disp('PSF centering not yet implemented.')
% %     optics = opticsSet(optics,'rayTrace',rt); 
% %     % We need to check for rotation, too.  At present, the Zemax script has
% %     % a y-axis field height.  That could mean (depending on whether Y is up
% %     % or down) a 90 or a -90 deg rotation is needed.  To check.  I think a
% %     % -90 is needed.
% %     disp('rtImportData: Centering and rotating 90 deg clockwise')
% %     optics = rtPSFCenter(optics,-1);
% %     rt = opticsGet(optics,'rayTrace'); 
% end

if showBar, delete(wBar); end

% Save the (x,y) positions of the PSF samples.  These are in units of
% millimeters because the psfSpacing variable is in millimeters.
% This list always contains a sample at 0
% For a 2^n (e.g., 64,64) grid, Code V puts the zero point at 2^n - 1 (e.g., 33,33)
%
% psfSize = [r,c];
% colPsfPos = [((-psfSize(2)/2)):(psfSize(2)/2) - 1]*psfSpacing;
% rowPsfPos = [((-psfSize(1)/2)):(psfSize(1)/2) - 1]*psfSpacing;
% [xPSF,yPSF] = meshgrid(colPsfPos,rowPsfPos);
% rt.psf.xSupport = xPSF;
% rt.psf.ySupport = yPSF;

% The image height is given in millimeters and stored in millimeters
rt.psf.fieldHeight = imgHeight(:);

% The Zemax values are given in microns.  We store them in millimeters.
rt.psf.sampleSpacing = [psfSpacing,psfSpacing]/1000;

% Units are nanometers
rt.psf.wavelength = wave(:);

% Put all the rt info into the optics.  Probably we should been doing
% opticsSet(optics,PARAM,VAL) all along.
optics = opticsSet(optics,'rayTrace',rt);
optics = opticsSet(optics,'model','rayTrace');

%% Save the optics data
button = questdlg('Save the converted optics?','RT Optics save');
switch lower(button)
    case 'yes'
        opticsFile = vcSaveObject(optics);
    otherwise
        disp('RT optics not saved.')
end

end





