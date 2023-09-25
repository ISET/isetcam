function [oi,val] = oiCreate(oiType,varargin)
% Create an optical image structure that stores the irradiance at the
% sensor
%
% Syntax
%   oi = oiCreate(oiType,varargin)
%
% Description
%  The oi structure describes the image irradiance at the sensor along with
%  many optics metadata.  The oi includes the optics structure.
%
% Inputs
%   oiType -
%     {'diffraction limited'} -  Diffraction limited optics, no diffuser or
%                         data (Default).  Equivalent to using the wvf or
%                         shift-invariant with a zero wavefront
%                         aberrations.
%     {'shift invariant'}  -  Shift-invariant model, used for wavefront
%                      calculations in ISETCam and also as the basis for
%                      the wvf human (wavefront model estimated from
%                      adaptive optics)
%     {'wvf human'}  - Human shift-invariant optics based on mean
%                      wavefront abberration from Thibos et al. (2009,
%                      Ophthalmic & Physiological Optics). Optional
%                      parameters can be passed for this case (see below).
%                      Also includes the human Lens default.
%     {'wvf'}        - Use the wavefront measurements to define the optics.
%     
%     {'human mw'}   - Human shift-invariant optics model with chromatic
%                      aberration estimated by Marimont-Wandell
%     {'ray trace'}  - Ray trace OI, which is a limited form of ray
%                      tracing. It includes a wavelength-dependent and
%                      field height dependent PSF, along with relative
%                      illumination and geometric distortion.  These data
%                      are derived from Zemax, typically. 
%
%  These are used for snr-lux testing
%     {'uniform d65'} - Turns off offaxis to make uniform D65 image
%     {'uniform ee'}  - Turns off offaxis and creates uniform EE image
%     {'black'}        - A black OI used for sensor parameter estimates
%
% The wavelength spectrum is normally inherited from the scene.  To
% specify a spectrum for the optical image use
%
%      oi = oiCreate('default');
%      oi = initDefaultSpectrum('hyperspectral');
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  
%   sceneCreate, oiCompute, oiSet/Get, wvfCreate, wvf2oi

% TODO:
%   Create a human oi without Thibos based on the diffraction limited
%   wvf.  It should have the lens class attached.
%

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

validTypes = {'default','pinhole','diffractionlimited','diffraction', ...
    'shiftinvariant','raytrace','wvf',...
    'human','humanmw','wvfhuman','humanwvf',...
    'uniformd65','uniformee','black'};

% Default is the diffraction limited calculation
if ieNotDefined('oiType'), oiType = 'diffraction limited'; 
else 
    if strncmp(oiType,'valid',5)
        oi = validTypes;
        return;
    end
end
if ieNotDefined('val'),     val = vcNewObjectValue('OPTICALIMAGE'); end
if ieNotDefined('optics'),  optics = opticsCreate('default'); end

oi.type = 'opticalimage';
oi.name = vcNewObjectName('opticalimage');
oi.metadata = [];  % Store metadata typically for machine-learning apps


%%
switch ieParamFormat(oiType)
    case {'diffractionlimited','diffraction','default'}
        oi = oiSet(oi,'optics',optics);
        
        % Set up the default glass diffuser with a 2 micron blur circle, but
        % skipped
        oi = oiSet(oi,'diffuser method','skip');
        oi = oiSet(oi,'diffuser blur',2*10^-6);  % If used, 2 um.
        
        % Camera lenses use transmittance, not human lens.
        if checkfields(oi.optics, 'lens')
            warning('How did a human lens get in diffraction limited?')
            oi.optics = rmfield(oi.optics, 'lens');
            oi.optics.transmittance.wave = (370:730)';
            oi.optics.transmittance.scale = ones(length(370:730), 1);
        end
        
    case {'shiftinvariant'}
        % Rather than using the diffraction limited call to make the OTF
        % we use some other method, perhaps wavefront.
        % Human is a special form of shift-invariant.  We might make
        % shiftinvariant-wvf or just wvf in the near future after
        % experimenting some.
        oi = oiSet(oi,'optics',opticsCreate('shift invariant',oi));
        oi = oiSet(oi,'name','SI');
        oi = oiSet(oi,'diffuserMethod','skip');

        % Camera lenses use transmittance, not human lens.
        if checkfields(oi.optics, 'lens')
            warning('How did a human lens get in shift invariant?')
            oi.optics = rmfield(oi.optics, 'lens');
            oi.optics.transmittance.wave = (370:730)';
            oi.optics.transmittance.scale = ones(length(370:730), 1);
        end

    case {'raytrace'}
        % Create the default ray trace unless a file name is passed in
        oi = oiCreate('default');
        rtFileName = fullfile(isetRootPath,'data','optics','rtZemaxExample.mat');
        if ~isempty(varargin), rtFileName = varargin{1}; end
        load(rtFileName,'optics');
        oi = oiSet(oi,'optics',optics);
        
    case {'humanmw'}
        % Marimont and Wandell human optics model.
        %
        % Historically, 'human' defaulted to the Marimont and Wandell
        % case.  Changed July, 2023. So this could create some
        % trouble. But so far so good.
        oi = oiCreate('default');
        oi = oiSet(oi,'diffuserMethod','skip');
        oi = oiSet(oi,'optics',opticsCreate('human mw'));
        oi = oiSet(oi,'name','human-MW');
        oi = oiSet(oi, 'lens', Lens('wave', oiGet(oi, 'optics wave')));

        % Used by ISETCam, but removed for human lens case.
        if checkfields(oi.optics, 'transmittance')
            oi.optics = rmfield(oi.optics, 'transmittance');
        end

    case {'human','wvfhuman','humanwvf'}
        % oi = oiCreate('wvf human', pupilMM, zCoefs, wave)
        %
        % Human optics specified from Thibos data.  The wavefront
        % structure has LCA set to use human.
        %
        % This is an alternative calculation compared to human mw
        % (Marimont and Wandell), above.         

        oi = oiCreate('shift invariant');
        oi = oiSet(oi, 'diffuser method', 'skip');

        % These optics default to the Thibos zcoeffs for 3mm, unless
        % varargin has something else in mind.
        oi = oiSet(oi, 'optics', opticsCreate('wvf human', varargin{:}));
        oi = oiSet(oi, 'name', 'human-WVF');
        oi = oiSet(oi, 'lens', Lens('wave', oiGet(oi, 'optics wave')));

        % Used by ISETCam, but removed for human lens case.
        if checkfields(oi.optics, 'transmittance')
            oi.optics = rmfield(oi.optics, 'transmittance');
        end

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
        
    case {'black'}
        % oi = oiCreate('black',sz,wave);
        %
        % Black scene with huge FOV.  Used to set zerolevel in the sensor,
        % and perhaps other electrical testing code.
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreate; oi = oiSet(oi,'wave',wave);
        oi = oiSet(oi,'photons',zeros(sz,sz,numel(wave)));
        oi = oiSet(oi,'fov',100);
        
    case {'wvf'}
        % A shift-invariant type based on a wavefront struct.
        % The default wavefront structure is used, and it is attached
        % to the oi.
        
        wvf = wvfCreate;  % This is diffraction limited
        wvf = wvfCompute(wvf);
        oi = wvf2oi(wvf);
        
        % Add the wvf parameters
        oi.wvf = wvf;
    case {'pinhole'}
        % Pinhole camera version of OI
        oi = oiCreate;
        oi = oiSet(oi, 'optics model', 'skip');
        oi = oiSet(oi, 'bit depth', 64);  % Forces double
        oi = oiSet(oi, 'optics offaxis method', 'skip');
        oi = oiSet(oi, 'diffuser method', 'skip');

        % Pinhole do not have a focal length.  In this case, the focal
        % length is used to say the image plane distance.
        oi = oiSet(oi, 'optics focal length',NaN);
        oi = oiSet(oi, 'optics name','pinhole');
        oi = oiSet(oi, 'name', 'pinhole');
        
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
oi = oiCompute(oi,scene);


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
oi = oiCompute(oi, scene);

return;
