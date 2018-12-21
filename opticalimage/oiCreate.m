function [oi,val] = oiCreate(oiType,varargin)
%Create an optical image structure.
%
% Syntax
%   oi = oiCreate(oiType,varargin)
%
% Description
%  The oi structure describe the image irradiance at the sensor.  It
%  includes a structure that defines the optics.
%
% Inputs
%   oiType - 
%     {'diffraction limited'} -  Diffraction limited optics, no diffuser or
%                             data (Default)
%     {'shift invariant'}     -  General high resolution shift-invariant
%                             model set up. Like human but pillbox OTF
%     {'wvf'}        - Use the wavefront methods to specify the shift
%     {'human'}      - Inserts human shift-invariant optics
%                   invariant optics
%     {'ray trace'}  - Ray trace OI
%
%  These are used for snr-lux testing
%     {'uniform d65'} - Turns off offaxis to make uniform D65 image
%     {'uniform ee'}  - Turns off offaxis and creates uniform EE image
%
% The wavelength spectrum is normally inherited from the scene.  To
% specify a spectrum for the optical image use
%
%      oi = oiCreate('default');
%      oi = initDefaultSpectrum('hyperspectral');
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  sceneCreate

% Example
%{
oi = oiCreate;
oi = oiCreate('diffraction limited');  % As above
oi = oiCreate('human');
oi = oiCreate('ray trace',rtOpticsFile);
oi = oiCreate('uniform d65');  % D65 used for lux-sec vs. snr measurements.
oi = oiCreate('uniform EE');   % Create an equal energy
oi = oiCreate('uniform EE',64,(380:4:1068)); % Set size and wave
%}
%

% Default is the diffraction limited calculation
if ieNotDefined('oiType'),  oiType = 'diffraction limited'; end
if ieNotDefined('val'),     val = vcNewObjectValue('OPTICALIMAGE'); end
if ieNotDefined('optics'),  optics = opticsCreate('default'); end

oi.type = 'opticalimage';
oi.name = vcNewObjectName('opticalimage');
oi.metadata = [];  % Store metadata typically for machine-learning apps

% In case there is an error, print out the valid types for the user.
validTypes = {'default','diffraction limited','shift invariant','ray trace',...
    'human','uniformd65','uniformEE','wvf'};

%%
switch ieParamFormat(oiType) 
    case {'diffractionlimited','diffraction','default'}
        oi = oiSet(oi,'optics',optics);
        
        % Set up the default glass diffuser with a 2 micron blur circle, but
        % skipped
        oi = oiSet(oi,'diffuser method','skip');
        oi = oiSet(oi,'diffuser blur',2*10^-6);
        oi = oiSet(oi,'consistency',1);

    case {'shiftinvariant'}
        % Rather than using the diffraction limited call to make the OTF,
        % we use some other method, perhaps wavefront.
        % Human is a special form of shift-invariant.  We might make
        % shiftinvariant-wvf or just wvf in the near future after
        % experimenting some.
        oi = oiSet(oi,'optics',opticsCreate('shift invariant',oi));
        oi = oiSet(oi,'name','SI');
        oi = oiSet(oi,'diffuserMethod','skip');
        oi = oiSet(oi,'consistency',1);

    case {'raytrace'}
        % Create the default ray trace unless a file name is passed in
        oi = oiCreate('default');
        rtFileName = fullfile(isetRootPath,'data','optics','rtZemaxExample.mat');
        if ~isempty(varargin), rtFileName = varargin{1}; end
        load(rtFileName,'optics');
        oi = oiSet(oi,'optics',optics);
        
    case {'human'}
        % Marimont and Wandell human optics model.  For more extensive
        % biological modeling, see the ISETBIO derivative which has now
        % expanded and diverged from ISET.
        oi = oiCreate('default');
        oi = oiSet(oi,'diffuserMethod','skip');
        oi = oiSet(oi,'consistency',1);
        oi = oiSet(oi,'optics',opticsCreate('human'));
        oi = oiSet(oi,'name','human-MW');
        
    case {'uniformd65'}
        % Uniform, D65 optical image.  No cos4th falloff, huge field of
        % view (120 deg). Used in lux-sec SNR testing and scripting
        oi = oiCreateUniformD65;
        
    case {'uniformee','uniformeespecify'}
        % Uniform, equal energy optical image. No cos4th falloff. Might be used in
        % lux-sec SNR testing or scripting.  Not really used now
        % (5.3.2005).
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreateUniformEE(sz,wave);
        
    case {'wvf'}
        % A shift-invariant type with a wavefront struct attached that
        % is used to control the point spread function
        
        wvf = wvfCreate;  % This is diffraction limited
        wvf = wvfComputePSF(wvf);
        oi = wvf2oi(wvf);
        
        % Add the wvf parameters
        oi.wvf = wvf;
        
    otherwise
        fprintf('\n--- Valid OI types: ---\n')
        for ii=1:length(validTypes)
            fprintf('%d: %s\n',ii,validTypes{ii});
        end
        fprintf('-------\n')

        error('***Unknown oiType: %s\n',oiType);
end

return;

%--------------------------------------------
function oi = oiCreateUniformD65
%  Create a spatially uniform, D65 image with a very large field of view.
%  The optical image is created without any cos4th fall off so it can be
%  used for lux-sec SNR testing.  The diffraction limited fnumber is set
%  for no blurring.
%

scene = sceneCreate('uniform d65');
scene = sceneSet(scene,'hfov',120);
ieAddObject(scene);

oi = oiCreate('default');
oi = oiSet(oi,'optics fnumber',1e-3);
oi = oiSet(oi,'optics offaxis method','skip');
oi = oiCompute(scene,oi);


return;

%---------------------------------------------
function oi = oiCreateUniformEE(sz,wave)
%  Create a spatially uniform, equal energy image with a very large field
%  of view. The optical image is created without any cos4th fall off so it
%  can be used for lux-sec SNR testing.  The diffraction limited fnumber is
%  set for no blurring.

scene = sceneCreate('uniform EE',sz,wave);
scene = sceneSet(scene,'hfov',120);
ieAddObject(scene);

oi = oiCreate('default');
oi = oiSet(oi,'optics fnumber',1e-3);
oi = oiSet(oi,'optics offaxis method','skip');
oi = oiCompute(scene,oi);

return;
