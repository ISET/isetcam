function [oi, wvf, scene] = oiCreate(oiType,varargin)
% Create an optical image structure 
%
% Syntax
%   [oi, wvf, scene] = oiCreate(oiType,varargin)
%
% Description
%  The oi structure describes the optics parameters and stores image
%  irradiance (at the sensor). The oi includes the optics structure.
%
% Inputs
%   oiType -
%     {'pinhole'}    - Turn off cos4th, infinite depth of field and
%                      NaN focal length
%
%     {'diffraction limited'} -  Diffraction limited optics, no diffuser or
%                      data (Default).  Equivalent to using the wvf or
%                      shift-invariant with a zero wavefront aberrations.
%
%     {'wvf'}        - Use a wavefront structure to define
%                      shift-invariant optics.  Default is diffraction
%                      limited, fnumber 4, focal length 3.863 mm
%     
%     {'wvf human'}  - Human shift-invariant optics based on mean
%                      wavefront abberration from Thibos et al. (2009,
%                      Ophthalmic & Physiological Optics). Optional
%                      parameters can be passed for this case (see below).
%                      Also includes the human Lens default.
%
%     {'human mw'}   - Human shift-invariant optics model with chromatic
%                      aberration estimated by Marimont-Wandell
%
%     {'psf'}        - A shift invariant OI created from a PSF optics
%                      struct, typically created by siSynthetic
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
%   varargin - Different parameters can be used for rayTrace, human wvf,
%   wvf, uniform d65, uniform ee and black.
% 
%     rayTrace    - varargin{1} = rtFileName
%     human wvf   - varargin{:} passed to opticsCreate
%
%     uniform d65, uniform ee, black -  
%          sz = varargin{1}; wave = varargin{2};  
%     wvf  - varargin{1} = A specific wavefront struct
%
% Returns
%   oi    - The constructed optical image with the optics
%   wvf   - The wavefront structure used to create the optics
%   scene - The scene used to create the oi for uniform cases
%
% Description
%
%  The wavelength spectrum is normally inherited from the scene.  To
%  specify a spectrum for the optical image use
%
%      oi = oiCreate('default');
%      oi = initDefaultSpectrum(oi, 'hyperspectral');
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

%% Parse arguments
validTypes = {'default','pinhole','diffractionlimited','diffraction', ...
    'shiftinvariant','raytrace','wvf',...
    'human','humanmw','wvfhuman','humanwvf',...
    'uniformd65','uniformee','black'};

% Default is the diffraction limited calculation
if ieNotDefined('oiType'), oiType = 'diffraction limited'; 
else 
    % If oiCreate('valid'), we return the valid types
    if strncmp(oiType,'valid',5)
        oi = validTypes;
        return;
    end
end

oiType   = ieParamFormat(oiType);
varargin = ieParamFormat(varargin);

%%  Create
scene = []; wvf = [];
switch ieParamFormat(oiType)
    case {'diffractionlimited','default'}
        % Diffraction limited is implemented using the dlMTF method.
        % This is like the wvf case, but the dl MTF is computed on the fly
        % at the same sampling precision needed by the scene.
        oi.type = 'opticalimage';
        oi.name = vcNewObjectName('opticalimage');
        oi.metadata = [];  % Store metadata typically for machine-learning apps

        optics = opticsCreate('diffraction limited');
        oi = oiSet(oi,'optics',optics);
        
        % Set up the default glass diffuser with a 2 micron blur circle, but
        % skipped
        oi = oiSet(oi,'diffuser method','skip');
        oi = oiSet(oi,'diffuser blur',2*10^-6);  % If used, 2 um.
        
        % BW: Checking.
        oi = oiSet(oi,'compute method','opticsotf');

        % Camera lenses use transmittance, not human lens.
        if checkfields(oi.optics, 'lens')
            warning('How did a human lens get in diffraction limited?')
            oi.optics = rmfield(oi.optics, 'lens');
            oi.optics.transmittance.wave = (370:730)';
            oi.optics.transmittance.scale = ones(length(370:730), 1);
        end

    case {'pinhole'}
        % Pinhole optics in an OI. 
        % 
        % We set the f/# (focal length over the aperture) to be a very
        % small number. This image has zero-blur because the
        % diffraction aperture is very large. That is the goal of the
        % pinhole camera optics, but the way we achieve it is odd.
        % 
        % The absolute light level is high because a small fnumber
        % means the focal length is very short compared to the
        % aperture.
        %
        % With these default settings the focal length is 10 mm and the
        % aperture diameter is 10 m.        
        oi = oiCreate();
        oi = oiSet(oi, 'name', 'pinhole');
        oi = oiSet(oi, 'optics name','pinhole');
        
        % This makes the computation a pinhole
        oi = oiSet(oi,'optics model','skip');
        oi = oiSet(oi, 'optics offaxis method', 'skip');
        oi = oiSet(oi, 'diffuser method', 'skip');

        % Not sure why we set these, but it is true that when we have
        % a very small fnumber, we should have no blur - like a
        % pinhole.
        oi = oiSet(oi, 'optics fnumber',1e-3);
        oi = oiSet(oi, 'optics focal length',1e-2);

        % Pinhole do not have a focal length or fNumber.
        wvf = [];

    case {'empty'}
        % Just the basic shell of the oi struct
        % Other terms will get added by the calling function
        oi.type = 'opticalimage';
        oi.name = vcNewObjectName('opticalimage');
        oi.metadata = [];  % Store metadata typically for machine-learning apps
        oi = oiSet(oi, 'diffuser method', 'skip');
        oi = oiSet(oi,'wave',[]);

    case {'wvf','shiftinvariant'}
        % oiCreate('wvf') or 
        % oiCreate('wvf',wvf);
        %
        % Create the optics from a wavefront structure.  We create a
        % wvf, convert it to an oi using wvf2oi, which calls wvf2optics.
        %
        % The default uses a diffraction limited oi.
        %

        if ~isempty(varargin) && isequal(varargin{1}.type,'wvf')
            wvf = varargin{1};
        else
            wvf = wvfCreate('wave',(400:10:700)');

            % Set up the standard optics values we have used for years
            % For ISETCam these were 0.039 mm focal length and fnumber 4.

            % Set the f pupil diameter to this value because, well, DHB says
            % this is what it was.
            diameterMM = 9.6569e-01;
            wvf = wvfSet(wvf,'calc pupil diameter',diameterMM,'mm');

            % If the f-number is 4, then the focal length must have been
            % fN = fLength/aperture s0 fLength = fN*aperture
            wvf = wvfSet(wvf,'focal length',diameterMM*4,'mm');
        end

        % Always create the psf
        wvf = wvfCompute(wvf);

        % Create the oi
        oi  = wvf2oi(wvf);
        
        % Set up the default glass diffuser with a 2 micron blur circle, but
        % skipped
        oi = oiSet(oi,'diffuser method','skip');
        oi = oiSet(oi,'diffuser blur',2*10^-6);  % If used, 2 um.
        
        % Camera lenses use transmittance, not human lens.
        if checkfields(oi.optics, 'lens')
            % BW:  Haven't seen this for a while.
            warning('How did a human lens get in diffraction limited?')
            oi.optics = rmfield(oi.optics, 'lens');
            oi.optics.transmittance.wave = (370:730)';
            oi.optics.transmittance.scale = ones(length(370:730), 1);
        end        

        % Set compute method
        oi = oiSet(oi, 'compute method', 'opticspsf');

        % Enables the oiWindow to show fnumber and flength
        if isequal(ieParamFormat(oiType),'diffractionlimited')
            oi.optics.model = 'diffractionlimited';
        end
    case {'psf'}
        % Create optics from a PSF (e.g., siSynthetic). This is also a shift
        % invariant type of OI, but there is no wavefront representation
        
        oi = oiCreate('default');
        fNumber = oiGet(oi,'optics fnumber');
        wave = 400:10:700;
        oi = oiSet(oi,'wave',wave);

        % The Gaussian spread is the same for all wavelengths and set to
        % twice the size of the airy disk diameter
        diskradius = airyDisk(wave(end),fNumber,'units','um');        
        psfType = 'gaussian';
        sigma = 2*diskradius;

        % Make point spreads with a circular bivariate Gaussian
        xyRatio = ones(1,length(wave));

        % Now call the routine with these parameters
        optics  = siSynthetic(psfType,oi,sigma,xyRatio);
        oi      = oiSet(oi,'optics',optics);

        oi  = oiSet(oi,'optics model','shiftInvariant');

        % Should we set computeMethod to opticspsf?

    case {'raytrace'}
        % Create the default ray trace unless a file name is passed in
        oi = oiCreate('default');
        rtFileName = fullfile(isetRootPath,'data','optics','rtZemaxExample.mat');
        if ~isempty(varargin), rtFileName = varargin{1}; end
        load(rtFileName,'optics');
        oi = oiSet(oi,'optics',optics);
        oi = oiSet(oi, 'compute method', []);
        
    case {'humanmw'}
        % oi = oiCreate('human mw');
        %
        % Marimont and Wandell human optics model.
        %
        % Historically, 'human' defaulted to the Marimont and Wandell
        % case.  Changed July, 2023. So this could create some
        % trouble. But so far so good.
        oi = oiCreate('shift invariant');
        wvf = [];   % Not part of the M-W calculation

        oi = oiSet(oi,'diffuserMethod','skip');
        oi = oiSet(oi,'optics',opticsCreate('human mw'));
        oi = oiSet(oi,'name','human-MW');
        oi = oiSet(oi, 'optics lens', Lens('wave', oiGet(oi, 'optics wave')));
        oi = oiSet(oi, 'compute method', 'humanmw');

        % Used by ISETCam, but removed for human lens case.
        if checkfields(oi.optics, 'transmittance')
            oi.optics = rmfield(oi.optics, 'transmittance');
        end

    case {'human','wvfhuman','humanwvf'}
        % [oi, wvf] = oiCreate('wvf human', pupilMM, zCoefs, wave)
        %
        % Human optics specified from Thibos data.  The wavefront
        % structure has LCA set to use human.
        %
        % This is an alternative calculation compared to 'human mw'
        % (Marimont and Wandell), above.         

        oi = oiCreate('shift invariant');
        oi = oiSet(oi, 'diffuser method', 'skip');

        % These optics default to the Thibos zcoeffs for 3mm, unless
        % varargin has something else in mind.  The wvf is attached to
        % oi.optics.wvf but also returned by this function, oiCreate.
        [optics,wvf] = opticsCreate('wvf human', varargin{:});
        oi = oiSet(oi, 'optics', optics);
        oi = oiSet(oi, 'name', 'human-WVF');
        oi = oiSet(oi, 'optics lens', Lens('wave', oiGet(oi, 'optics wave')));
        oi = oiSet(oi, 'compute method', 'opticspsf');

        % Used by ISETCam, but removed for human lens case.
        if checkfields(oi.optics, 'transmittance')
            oi.optics = rmfield(oi.optics, 'transmittance');
        end

    case {'uniformd65'}
        % [oi,scene] = oiCreate('uniform d65',sz,wave);
        %
        % Uniform, D65 optical image.  No cos4th falloff, huge field of
        % view (120 deg). Used in lux-sec SNR testing and scripting
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        oi = oiCreateUniformD65(sz,wave);
        wvf = [];
        oi = oiSet(oi, 'compute method', []);

    case {'uniformee','uniformeespecify'}
        % [oi, scene] = oiCreate('uniform ee',sz,wave);
        %
        % Uniform, equal energy optical image. No cos4th falloff. Might be
        % used in lux-sec SNR testing or scripting.  
        % Not really used now, since (5.3.2005).
        wave = 400:10:700; sz = 32;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, wave = varargin{2}; end
        [oi,scene] = oiCreateUniformEE(sz,wave);
        wvf = scene;
        oi = oiSet(oi, 'compute method', []);

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
function [oi, scene] = oiCreateUniformD65(sz,wave)
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
function [oi,scene] = oiCreateUniformEE(sz,wave)
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
