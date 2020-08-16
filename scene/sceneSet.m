function scene = sceneSet(scene,parm,val,varargin)
%Set scene parameter values
%
%   scene = sceneSet(scene,parm,val,varargin)
%
%  The scene structure parameters are set through the calls to this
%  routine.
%
%  Inputs:
%    scene - the scene structure
%    parm  - the parameter name (Indifferent to case; spaces allowed)
%    val   - value of the parameter
%    varargin allows some additional parameters in certain cases.
%
%  Many fewer parameters are available for 'sceneSet' than 'sceneGet'. This
%  is because many of the parameters derived from sceneGet are derived from
%  the few parameters that can be set, and sometimes the derived quantities
%  require some knowledge of the optics as well.
%
%  Examples:
%    scene = sceneSet(scene,'name','myScene');      % Set the scene name
%    scene = sceneSet(scene,'fov',3);               % Set scene field of view to 3 deg
%    oi = sceneSet(oi,'optics',optics);
%    oi = sceneSet(oi,'oicomputemethod','myOIcompute');
%
% Scene description
%      'name'          - An informative name describing the scene
%      'type'          - The string 'scene'
%      'distance'      - Object distance from the optics (meters)
%      'wangular'      - Width (horizontal) field of view
%      'magnification' - Always 1 for scenes.
%
% Scene radiance
%      'data'   - structure containing the data
%        'photons' - row x col x nwave array representing the radiance
%
%         N.B. After writing to the 'photons' field, the luminance and mean
%         luminance fields are set to empty. To update luminance use
%            lum = sceneCalculateLuminance(scene);
%            scene = sceneSet(scene,'luminance',lum);
%
%         'peak photon radiance' - Used for monochromatic scenes mainly;
%         not a variable, but a function
% Depth
%      'depthMap' - Stored in meters.  Used with RenderToolbox
%      synthetic scenes.  (See scene3D pdcproject directory).
%
% Reflectance chart parameters
%      'chart parameters'  - When we use sceneCreate('reflectance chart')
%      the key parameters are attached to the scene object.
%
% Scene color information
%      'spectrum'   - structure that contains wavelength information
%        'wavelength' - Wavelength sample values (nm)
%
% Some multispectral scenes have information about the illuminant
%     'illuminant'  - Scene illumination structure
%      'illuminant Energy'  - Illuminant spd in energy is stored W/sr/nm/sec
%      'illuminant Photons' - Photons are converted to energy and stored 
%      'illuminant Comment' - Comment
%      'illuminant Name'    - Identifier for illuminant.
%
% Auxiliary
%      'consistency'  - Display consistent with window data
%      'gamma'        - Gamma parameter for displaying image data
%      'display mode' - Sets sceneWindow display 'rgb','hdr','gray','clip'
%      'rect'         - A rect region of interest
%
% Used to store the scene luminance rather than recompute (i.e., cache)
%    'luminance'
%    'mean luminance' - Set the mean scene luminance (calls
%                           sceneAdjustLuminance)
%    'max luminance'  - Set the maximum scene luminance
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('parm','var') || isempty(parm), error('Param must be defined.'); end
if ~exist('val','var'), error('Value field required.'); end  % empty is OK

parm = ieParamFormat(parm);

switch parm 
    case {'name','scenename'}
        scene.name = val;
    case 'type'
        scene.type = val;
    case {'filename'}
        % When the data are ready from a file, we may save the file name.
        % Happens, perhaps, when reading multispectral image data.
        % Infrequently used.
        scene.filename = val;
    case {'consistency','computationalconsistency'}
        % When parameters are changed, the consistency flag on the optical
        % image changes.  This is irrelevant for the scene case.
        scene.consistency = val;
    case {'gamma'}
        % sceneSet([],'gamma',1);
        % Should this be ieSessionSet('scene gamma',val)
        % hObj = ieSessionGet('scene window');
        sceneW = ieSessionGet('scene window');
        % eventdata = [];
        sceneW.editGamma.Value = num2str(val);
        sceneW.refresh;
    case {'displaymode'}
        % sceneSet(scene,'display mode','hdr');
        
        switch val
            case 'hdr'
                val = 3;
            case 'rgb'
                val = 1;
            case 'gray'
                val = 2;
            case 'clip'
                val = 4;
            otherwise
                fprintf('Legal display modes: rgb, gray, hdr, clip\n');
        end
        
        hdl = ieSessionGet('scene window handle');
        set(hdl.popupDisplay,'Value',val);
        
        % sceneWindow('sceneRefresh',hObj,eventdata,hdl);
        sceneWindow;
        
    case {'distance' }
        % Positive for scenes, negative for optical images
        scene.distance = val;

    case {'wangular','widthangular','hfov','horizontalfieldofview','fov'}
        if val > 180,   val = 180 - eps; warndlg('Warning: fov > 180');
        elseif val < 0, val = eps; warndlg('Warning fov < 0');
        end
        scene.wAngular = val;

    case 'magnification'
        % Scenes should always have a magnification of 1.
        if val ~= 1, warndlg('Scene must have magnification 1'); end
        scene.magnification = 1;

    case {'data','datastructure'}
        scene.data = val;
        
    case {'photons'}
        % scene = sceneSet(scene,'photons',val);
        % sceneSet(scene,'photons',val,[wave])
        % val is typically a 3D (row,col,wave) matrix.

        % Not sure we want 32/64 option any more.  32 is just good enough,
        % I think (BW).
        bitDepth = sceneGet(scene, 'bitDepth');
        if isempty(bitDepth)
            scene = sceneSet(scene,'bit depth',32);
        end
        if ~isempty(varargin)
            idx = ieFindWaveIndex(sceneGet(scene, 'wave'), varargin{1});
            idx = logical(idx);
        end
        
        switch bitDepth
            case 64 % Double
                if isempty(varargin)
                    scene.data.photons = val;
                else
                    scene.data.photons(:,:,idx) = val;
                end
            case 32 % Single
                if isempty(varargin)
                    scene.data.photons = single(val);
                else
                    scene.data.photons(:,:,idx) = single(val);
                end
            otherwise
                error('Unsupported data bit depth %f\n',bitDepth);
        end

        % Clear out luminance computation
        scene = sceneSet(scene, 'luminance', []);
        
    case 'energy'
        % scene = sceneSet(scene,'energy',energy,wave);
        % 
        % The user specified the scene in units of energy.  We convert to
        % photons and set the data as photons.
        %
        wave = sceneGet(scene,'wave');
        photons = zeros(size(val));
        [r,c,w] = size(photons);
        if w ~= length(wave), error('Data mismatch'); end
        
        % h = waitbar(0,'Energy to photons');
        for ii=1:w
            % waitbar(ii/w,h);           
            % Get the first image plane from the energy hypercube.
            % Make it a row vector
            tmp = val(:,:,ii); tmp = tmp(:)';
            % Convert the rwo vector from energy to photons
            tmp = Energy2Quanta(wave(ii),tmp);
            % Reshape it and place it in the photon hypercube
            photons(:,:,ii) = reshape(tmp,r,c);
        end
        % close(h);
        scene = sceneSet(scene,'photons',photons);
        
    case 'roiphotons'
        % Place new scene radiance data into an ROI
        %
        %    scene = sceneSet(scene,'roi energy',val, roi);
        %
        % The radiance data should be in XW format
        %
        % The ROI is specified as either an ROI box or as a set of
        % roilocs. If an ROI box then size(roi,2)is 4. If ROI Locs
        % then size(roi,2) is 2 (roiLocs is Nx2).
        %
        if isempty(varargin), error('ROI required')
        else, roi = varargin{1};
        end
        if size(roi,2) == 4, roiLocs = ieRect2Locs(roi);
        else,                roiLocs = roi;
        end

        wave = sceneGet(scene,'wave');
        photons = zeros(size(val));
        [~,w] = size(photons);
        if w ~= length(wave), error('Data mismatch'); end
        
        photons = sceneGet(scene,'photons');
        [photons, r, c] = RGB2XWFormat(photons);

        sz = sceneGet(scene,'size');
        roiLocs(:,1) = ieClip(roiLocs(:,1),1,r);
        roiLocs(:,2) = ieClip(roiLocs(:,2),1,c);

        imgLocs = sub2ind([sz(1),sz(2)],roiLocs(:,1),roiLocs(:,2));
        photons(imgLocs,:) = val;
        photons = XW2RGBFormat(photons,sz(1),sz(2));

        scene = sceneSet(scene,'photons',photons);
        
    case 'roienergy'
        % Place new scene radiance data into an ROI.  The ROI is
        % specified as either an ROI box or as a set of roilocs.  The
        % radiance data must be in XW format.
        %
        %    scene = sceneSet(scene,'roi energy',energy, roi);
        % 
        % The user specified the scene radiance in units of energy.
        %
        % The ROI is specified as either an ROI box or as a set of
        % roilocs. If an ROI box then size(roi,2)is 4. If ROI Locs
        % then size(roi,2) is 2 (roiLocs is Nx2).
        %
        
        if isempty(varargin), error('ROI required')
        else, roi = varargin{1};
        end
        
        wave = sceneGet(scene,'wave');
        photons = zeros(size(val));
        [~,w] = size(photons);
        if w ~= length(wave), error('Data mismatch'); end
        
        photons = Energy2Quanta(wave,val')';
        %
        %         % h = waitbar(0,'Energy to photons');
        %         for ii=1:w
        %             % waitbar(ii/w,h);
        %             % Get the first image plane from the energy hypercube.
        %             % Make it a row vector
        %             tmp = val(:,:,ii); tmp = tmp(:)';
        %             % Convert the rwo vector from energy to photons
        %             tmp = Energy2Quanta(wave(ii),tmp);
        %             % Reshape it and place it in the photon hypercube
        %             photons(:,:,ii) = reshape(tmp,r,c);
        %         end
        
        % close(h);
        scene = sceneSet(scene,'roi photons',photons,roi);
        

    case {'peakradiance','peakphotonradiance'}
        % Deprecated, I think.
        % Used with monochromatic scenes to set the radiance in photons.
        % scene = sceneSet(scene,'peak radiance',1e17);
        oldPeak = sceneGet(scene,'peak radiance');
        p  = sceneGet(scene,'photons');
        scene = sceneSet(scene,'photons',val*(p/oldPeak));
    case {'depthmap'}
        % Depth map is always in meters
        scene.depthMap = val;
        
    case {'datamin','dmin'}
        % These are photons (radiance)
        scene.data.dmin = val;
    case {'datamax','dmax'}
        % These are photon (radiance)
        scene.data.dmax = val;
    case 'bitdepth'
        scene.data.bitDepth = val;
        % scene = sceneClearData(scene);
        
        % Not sure this is used much or at all any more.  It is in
        % sceneIlluminantScale alone, as far as I can tell. - BW
        
    case 'roi'
        % Sometimes we want to attach a roi to a scene because we
        % processed the data with respect to that region of interest.  This
        % slot could become a real object some day.  For now, I only put a
        % rect in here, from time to time.
        scene.roi = val;
    case 'knownreflectance'
        % We  store a known reflectance at location (i,j) for wavelength
        % w. This information is used to set the illuminant level properly
        % and to keep track of reflectances.
        if length(val) ~= 4 || val(1) > 1 || val(1) < 0
            error('known reflectance is [reflectance,row,col,wave]'); 
        end
        scene.data.knownReflectance = val;
    case {'chartparameters'}
        % See sceneReflectanceChart 
        % Reflectance chart parameters are stored here.
        scene.chartP = val;
    case {'chartcorners'}
        scene.chartP.cornerPoints = val;
        
    case {'luminance','lum'}
        % sceneSet(scene,'luminance',array)
        % The luminance array is stored.  But this parameter is dangerous
        % because this value could be inconsistent with the photons if we
        % are not careful.
        if isempty(val), scene.data.luminance = val; return; 
        elseif ~isequal(size(val),size(scene.data.photons(:,:,1)))
            error('Lminance array does not match photon array size.');
        else
            scene.data.luminance = val;
        end
    case {'meanluminance','meanl'}
        % scene = sceneSet(scene,'mean luminance',val)
        scene = sceneAdjustLuminance(scene,val);
        scene.data.meanL = val;
    case {'maxluminance','maxl'}
        % sceneSet(scene,'max luminance',val);
        lum = sceneGet(scene,'luminance');
        meanL = sceneGet(scene,'mean luminance');
        currentMax = max(lum(:));
        newMean = meanL*(val/currentMax);
        scene = sceneAdjustLuminance(scene,newMean);
    case {'spectrum','wavespectrum','wavelengthspectrumstructure'}
        scene.spectrum  = val;
    case {'wave','wavelength','wavelengthnanometers'}
        % scene = sceneSet(scene,'wave',wave); 
        %
        % If there are photon data, we interpolate the data as well as
        % setting the wavelength. If there are no photon data, we just set
        % the wavelength.

        if ~checkfields(scene,'data','photons') || isempty(scene.data.photons)
            % No data, so just set the spectrum
            scene.spectrum.wave = val;
        else
            % Because there are data present, we must interpolate the
            % photon data
            scene = sceneInterpolateW(scene,val);
        end
        
        % Scene illumination information
    case {'illuminant'}
        % The whole structure
        scene.illuminant = val;
    case {'illuminantdata','illuminantenergy'}
        % This set changes the illuminant, but it does not change the
        % radiance SPD.  Hence, changing the illuminant (implicitly)
        % changes the reflectance. This might not be what you want.  If you
        % want to change the scene as if it is illuminanted differently,
        % use the function: sceneAdjustIlluminant()
        
        % The data can be a vector (one SPD for the whole image) or they
        % can be in spatial spectral format SPD with a different illuminant
        % at each position.
        illuminant = sceneGet(scene,'illuminant');
        illuminant = illuminantSet(illuminant,'energy',val);
        scene = sceneSet(scene,'illuminant',illuminant);
    case {'illuminantphotons'}
        % See comment above about sceneAdjustIlluminant.
        %
        % sceneSet(scene,'illuminant photons',data)
        %
        % We have to handle the spectral and the spatial spectral cases
        % within the illuminantSet.  At this point, val can be a vector or
        % an RGB format matrix.
        if checkfields(scene,'illuminant')
            scene.illuminant = illuminantSet(scene.illuminant,'photons',val);
        else
            % We use a default d65.  The user must change to be consistent
            wave = sceneGet(scene,'wave');
            scene.illuminant = illuminantCreate('d65',wave);
            scene.illuminant = illuminantSet(scene.illuminant,'photons',val);
        end
    case {'illuminantname'}
        scene.illuminant = illuminantSet(scene.illuminant,'name',val);
    case {'illuminantcomment'}
        scene.illuminant.comment = val;
    case {'illuminantspectrum'}
        scene.illuminant.spectrum = val;
        
    case {'rect'}
        % scene = sceneSet(scene,'rect',[x y h w]);
        % An ROI rect.
        scene.rect = val;
    case {'mccrecthandles'}
        if checkfields(scene,'mccRectHandles')
            if ~isempty(scene.mccRectHandles)
                try delete(scene.mccRectHandles(:));
                catch
                end
            end
        end
        scene.mccRectHandles = val;
    case {'mcccornerpoints'}
        scene.mccCornerPoints = val;

    otherwise
        disp(['Unknown sceneSet parameter: ',parm]);
end

return;
