function [oi,wvf] = oiCreate(oiType,varargin)
% Create an optical image structure 
%
% Syntax
%   [oi, wvf] = oiCreate(oiType,varargin)
%
% Description
%  The oi structure describes the optics parameters and stores image
%  irradiance (at the sensor). The oi includes the optics structure.
%
% Inputs
%   oiType -
%     {'diffraction limited'} -  Diffraction limited optics, no diffuser or
%                         data (Default).  Equivalent to using the wvf or
%                         shift-invariant with a zero wavefront
%                         aberrations.
%
%     {'shift invariant'}  -  Shift-invariant model, used for wavefront
%                      calculations in ISETCam and also as the basis for
%                      the wvf human (wavefront model estimated from
%                      adaptive optics)
%
%     {'wvf human'}  - Human shift-invariant optics based on mean
%                      wavefront abberration from Thibos et al. (2009,
%                      Ophthalmic & Physiological Optics). Optional
%                      parameters can be passed for this case (see below).
%                      Also includes the human Lens default.
%
%     {'wvf'}        - Use the wavefront measurements to define the optics.
%     
%     {'human mw'}   - Human shift-invariant optics model with chromatic
%                      aberration estimated by Marimont-Wandell
%
%     {'ray trace'}  - Ray trace OI, which is a limited form of ray
%                      tracing. It includes a wavelength-dependent and
%                      field height dependent PSF, along with relative
%                      illumination and geometric distortion.  These data
%                      are derived from Zemax, typically. 
%
%     {'uniform d65'} - Turns off offaxis to make uniform D65 image
%
%     {'uniform ee'}  - Turns off offaxis and creates uniform EE image
%
%     {'black'}       - A black OI used for sensor parameter estimates
%
%
% Optional key/val
%   
%   varargin - parameters are used for rayTrace, human wvf, uniform d65,
%      uniform ee and black.
% 
%     rayTrace    - varargin{1} = rtFileName
%     human wvf   - varargin{:} passed to opticsCreate
%
%     uniform d65, uniform ee, black -  
%          sz = varargin{1}; wave = varargin{2};  
%
% Returns
%   oi  - The constructed optical image with the optics
%   wvf - The optics structure is created from a wavefront struct. That
%         struct is optionally returned as the second argument.
%
% Description
%
%  The wavelength spectrum is normally inherited from the scene.  To
%  specify a spectrum for the optical image use
%
%      oi = oiCreate('default');
%      oi = initDefaultSpectrum('hyperspectral');
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  
%   sceneCreate, oiCompute, oiSet/Get, wvfCreate, wvf2oi, wvf2optics

% Example
%{
[oi,wvf] = oiCreate;
oi = oiCreate('diffraction limited');  % As above
[oi,wvf] = oiCreate('human');
% oi = oiCreate('ray trace',rtOpticsFile);
oi = oiCreate('uniform d65');  % D65 used for lux-sec vs. snr measurements.
oi = oiCreate('uniform EE');   % Create an equal energy
[oi,wvf] = oiCreate('uniform EE',64,(380:4:1068)); % Set size and wave
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

%%
switch ieParamFormat(oiType)
    case {'empty'}
        % Just the basic shell of the oi struct
        % Other terms will get added by the calling function
        oi.type = 'opticalimage';
        oi.name = vcNewObjectName('opticalimage');
        oi.metadata = [];  % Store metadata typically for machine-learning apps
        oi = oiSet(oi, 'diffuser method', 'skip');
        oi = oiSet(oi,'wave',[]);
        wvf = [];

    case {'diffractionlimited','shiftinvariant','diffraction','wvf','default'}

        % We create via the wavefront method.  We convert the
        % wavefront to an OI, and that process calls opticsCreate to
        % convert the wvf parameters into an ISETCam optics struct.
        wvf = wvfCreate('wave',(400:10:700)');

        % Set up the old standard optics values
        wvf = wvfSet(wvf,'focal length',3.9,'mm');

        % Set the f number to 4
        wvf = wvfSet(wvf,'calc pupil diameter',3.9/4,'mm');

        % Create the psf
        wvf = wvfCompute(wvf);
        oi  = wvf2oi(wvf);
        
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

        % Enables the oiWindow to show fnumber and flength
        if isequal(ieParamFormat(oiType),'diffractionlimited')
            oi.optics.model = 'diffractionlimited';
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
        [oi,wvf] = oiCreate('shift invariant');
        oi = oiSet(oi,'diffuserMethod','skip');
        oi = oiSet(oi,'optics',opticsCreate('human mw'));
        oi = oiSet(oi,'name','human-MW');
        oi = oiSet(oi, 'optics lens', Lens('wave', oiGet(oi, 'optics wave')));

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
        % varargin has something else in mind.  The wvf is attached to
        % oi.optics.wvf
        [optics,wvf] = opticsCreate('wvf human', varargin{:});
        oi = oiSet(oi, 'optics', optics);
        oi = oiSet(oi, 'name', 'human-WVF');
        oi = oiSet(oi, 'optics lens', Lens('wave', oiGet(oi, 'optics wave')));

        % Used by ISETCam, but removed for human lens case.
        if checkfields(oi.optics, 'transmittance')
            oi.optics = rmfield(oi.optics, 'transmittance');
        end

    case {'uniformd65'}
        % Uniform, D65 optical image.  No cos4th falloff, huge field of
        % view (120 deg). Used in lux-sec SNR testing and scripting
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreateUniformD65(sz,wave);
        wvf = [];

    case {'uniformee','uniformeespecify'}
        % Uniform, equal energy optical image. No cos4th falloff. Might be used in
        % lux-sec SNR testing or scripting.  Not really used now
        % (5.3.2005).
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreateUniformEE(sz,wave);
        wvf = [];

    case {'black'}
        % oi = oiCreate('black',sz,wave);
        %
        % Black scene with huge FOV.  Used to set zerolevel in the sensor,
        % and perhaps other electrical testing code.
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreate('shift invariant'); 
        oi = oiSet(oi,'wave',wave);
        oi = oiSet(oi,'photons',zeros(sz,sz,numel(wave)));
        oi = oiSet(oi,'fov',100);        
        wvf = [];

    case {'pinhole'}
        % Pinhole camera version of OI
        oi = oiCreate('shift invariant');
        oi = oiSet(oi, 'optics model', 'skip');
        oi = oiSet(oi, 'bit depth', 64);  % Forces double
        oi = oiSet(oi, 'optics offaxis method', 'skip');
        oi = oiSet(oi, 'diffuser method', 'skip');

        % Pinhole do not have a focal length.  In this case, the focal
        % length is used to say the image plane distance.
        oi = oiSet(oi, 'optics focal length',NaN);
        oi = oiSet(oi, 'optics name','pinhole');
        oi = oiSet(oi, 'name', 'pinhole');
        wvf = [];

    otherwise
        fprintf('\n--- Valid OI types: ---\n')
        for ii=1:length(validTypes)
            fprintf('%d: %s\n',ii,validTypes{ii});
        end
        fprintf('-------\n')
        
        error('***Unknown oiType: %s\n',oiType);
end

end

%--------------------------------------------
function oi = oiCreateUniformD65(sz,wave)
%  Create a spatially uniform, D65 image with a very large field of view.
%  The optical image is created without any cos4th fall off so it can be
%  used for lux-sec SNR testing.  The diffraction limited fnumber is set
%  for no blurring.
%

scene = sceneCreate('uniform d65',sz,wave);
scene = sceneSet(scene,'hfov',120);
ieAddObject(scene);

oi = oiCreate('default');
oi = oiSet(oi,'optics fnumber',1e-3);
oi = oiSet(oi,'optics offaxis method','skip');
oi = oiCompute(oi,scene);

end

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

end
