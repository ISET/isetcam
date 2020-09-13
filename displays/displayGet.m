function val = displayGet(d, parm, varargin)
%Get display parameters and derived properties
%
%     val = displayGet(d,parm,varargin)
%
% Basic parameters
%     {'type'}        - Always 'display'
%     {'name'}        - Which specific display
%     {'is emissive'} - true (emissive) or false (reflective)
%
% Transduction
%     {'gamma table'}   - nLevels x nPrimaries
%     {'inverse gamma',[nSteps]} - invert gamma table, see ieLUTInvert
%     {'dac size'}      - number of bits (log2(nSamples))
%     {'nlevels'}       - number of levels
%     {'levels'}        - list of levels
%
% SPD calculations
%     {'wave'}                - wavelength samples in nanometers
%     {'n wave'}              - number of wave samples
%     {'spd primaries'}       - nWave x nPrimaries matrix, in energy units
%     {'rgb spd'}             - The RGB primaries, excluding the backlight
%                               and ambient term, which is the 4th.
%     {'white spd'}           - white point spectral power distribution
%     {'black spd'}           - spd when display is black
%     {'n primaries'}         - number of primaries
%
% Color conversion and metric
%     {'rgb2xyz'}
%     {'rgb2lms'}
%     {'white xyz'}
%     {'black xyz'}
%     {'white xy'}
%     {'white lms'}
%     {'primaries xyz'}
%     {'primaries xy'}
%     {'peak luminance'}
%     {'dark luminance'}
%     {'peak contrast'}
%
% Spatial parameters
%     {'dpi', 'ppi'}           - dots per inch
%     {'meters per dot'}
%     {'dots per meter'}
%     {'dots per deg'}         - dots per degree visual angle
%     {'viewing distance'}     - in meters
%
% Subpixel structure
%     {'dixel'}              - dixel structure describing repeating unit
%     {'pixels per dixel'}   - number of pixels in one dixel (see comments)
%     {'dixel size'}         - number of samples in one dixel
%     {'dixel intensity map'}
%     {'dixel control map'}  - control map, describing which regions are
%                              individually addressable
%     {'peak spd'}           - peak spd for each primary
%     {'oversample'}         - up-scale factor for subpixel rendering
%     {'sample spacing'}     - spacing between samples
%     {'fill factor'}        - fill factor of each primary
%     {'render function'}    - function handle used to convert rgb input to
%                              corresponding dixel image
%
% Examples
%   d = displayCreate;
%   w = displayGet(d,'wave');
%   p = displayGet(d,'spd');
%   vcNewGraphWin; plot(w,p); set(gca, 'ylim', [-.1 1.1])
%
%   chromaticityPlot(displayGet(d, 'white xy'))
%
%   vci = vcimageCreate('test',[],d);
%   plotDisplayGamut(vci)
%
% HJ/BW, ISETBIO TEAM, Copyright 2014

%% TODO
%  See drgb2xyz below.  In general, we need to integrate the ieLUT<> calls
%  with this displayGet() call.
%  We need to create routines to return the dixel size (height/width) in
%  units of meters
%  We need to return the size of the subpixel samples in the psf image.

%% Check parameters
if ~exist('parm','var')||isempty(parm) , error('Parameter not found.');  end

% Default is empty when the parameter is not yet defined.
val = [];

parm = ieParamFormat(parm);

%% Do the analysis
switch parm
    case {'name'}
        val = d.name;
    case {'type'}
        % Type should always be 'display'
        val = d.type;
    case {'gtable','dv2intensity','gamma','gammatable'}
        if isfield(d,'gamma'), val = d.gamma; end
    case {'inversegamma', 'inversegammatable'}
        if isfield(d, 'gamma')
            % Optional nSteps arg for inverse gamma table
            if (isempty(varargin))
                val = ieLUTInvert(d.gamma);
            else
                val = ieLUTInvert(d.gamma,varargin{1});
            end
        end
    case {'isemissive'}
        val = true;
        if isfield(d, 'isEmissive'), val = d.isEmissive; end
    case {'bits','dacsize'}
        % color bit depths, e.g. 8 bit / 10 bit
        % This is computed from size of gamma table
        gTable = displayGet(d, 'gTable');
        assert(ismatrix(gTable), 'Bit depth of display unkown');
        val = round(log2(size(gTable, 1)));
    case {'nlevels'}
        % Number of levels
        val = 2^displayGet(d,'bits');
    case {'levels'}
        % List of the levels, e.g. 0~255
        val = 1:displayGet(d,'nlevels') - 1;
        
        % SPD calculations
    case {'wave','wavelength'}  %nanometers
        % For compatibility with PTB.  We might change .wave to
        % .wavelengths.
        if checkfields(d,'wave'), val = d.wave(:);
        elseif checkfields(d,'wavelengths'), val = d.wavelengths(:);
        end
    case {'binwidth'}
        wave = displayGet(d, 'wave');
        if length(wave) > 1
            val = wave(2) - wave(1);
        end
        
    case {'nwave'}
        val = length(displayGet(d,'wave'));
    case {'nprimaries'}
        % SPD is always nWave by nPrimaries
        spd = displayGet(d,'spd');
        val = size(spd,2);
    case {'spd','spdprimaries'}
        % Units are energy (watts/....)
        % displayGet(dsp,'spd');
        % displayGet(d,'spd',wave);
        %
        % Always make sure the spd has rows equal to number of wavelength
        % samples. The PTB uses spectra rather than spd.  This hack makes
        % it compatible.  Or, we could convert displayCreate from spd to
        % spectra some day.
        if checkfields(d,'spd'),         val = d.spd;
        elseif checkfields(d,'spectra'), val = d.spectra;
        end
        
        % Sometimes users put the data in transposed, sigh.  I am one of
        % those users.
        nWave = displayGet(d,'nwave');
        if size(val,1) ~= nWave,  val = val'; end
        % Should check here!
        
        % Interpolate for alternate wavelength, if requested
        if ~isempty(varargin)
            % Wave interpolation
            wavelength = displayGet(d,'wave');
            wave = varargin{1};
            val = interp1(wavelength(:), val, wave(:),'linear',0);
        end
    case {'rgbspd'}
        % displayGet(d,'rgb spd',[wave])
        %
        % The new structure has RGB primaries as well as an ambient/black
        % primary.  That one is the fourth.  Often we just want the rgb
        % primaries.
        % Do we have a problem here if the display is not emissive?
        if ~isempty(varargin), wave = varargin{1}; 
        else, wave = displayGet(d,'wave');
        end
        spd = displayGet(d,'spd',wave);
        val = spd(:,1:3);
        
    case {'whitespd'}
        % SPD when all the primaries are at peak, this is the energy
        if ~isempty(varargin), wave = varargin{1};
        else                   wave = displayGet(d,'wave');
        end
        e = displayGet(d,'spd',wave);
        val = sum(e, 2);
        
        % Color conversion
    case {'rgb2xyz','lrgb2xyz'}
        % rgb2xyz = displayGet(dsp,'rgb2xyz',wave)
        % This is the linear rgb to xyz conversion.
        % 
        % RGB as a column vector mapped to XYZ column
        %  x(:)' = r(:)' * rgb2xyz
        % Hence, imageLinearTransform(img,rgb2xyz)
        % should work
        %
        wave = displayGet(d,'wave');
        spd  = displayGet(d,'spd',wave);        % spd in energy
        val  = ieXYZFromEnergy(spd',wave);  %         
    case {'rgb2lms'}
        % rgb2lms = displayGet(dsp,'rgb2lms')
        % rgb2lms = displayGet(dsp,'rgb2lms',wave)
        % 
        % This is for linear rgb to lms.
        %
        % The matrix is scaled so that L+M of white equals Y of white.
        %
        % RGB as a column vector mapped to LMS column
        %
        %     c(:)' = r(:)' * rgb2lms
        % We do this so we can use the routine:
        %
        %   imageLinearTransform(img,rgb2lms)
        %
        wave = displayGet(d,'wave');
        coneFile = fullfile(isetRootPath,'data','human','stockman');
        cones = ieReadSpectra(coneFile,wave);     % plot(wave,spCones)
        spd = displayGet(d, 'spd', wave);         % plot(wave,displaySPD)
        val = cones'* spd;                  
        val = val';
        
        % Scale the transform so that sum L and M values sum to Y-value of
        % white 
        %         e = displayGet(d,'white spd',wave);
        %         whiteXYZ = ieXYZFromEnergy(e',wave);
        %         whiteLMS = sum(val);
        %         val = val*(whiteXYZ(2)/(whiteLMS(1)+whiteLMS(2)));
        
    case {'drgb2xyz'}
        % This should be implemented.
        % Take an RGB image of digital values, convert them to linear
        % primary intensities, and then return the XYZ values
        
     case {'whitexyz','whitepoint'}
        % displayGet(dsp,'white xyz',wave)
        e = displayGet(d,'white spd');
        if isempty(varargin), wave = displayGet(d,'wave');
        else wave = varargin{1};
        end
        % Energy needs to be XW format, so a row vector
        val = ieXYZFromEnergy(e',wave);
    case {'peakluminance'}
        % Luminance of the white point in cd/m2
        % displayGet(dsp,'peak luminance')
        whiteXYZ = displayGet(d,'white xyz');
        val = whiteXYZ(2);
    case {'whitexy'}
        val = chromaticity(displayGet(d,'white xyz'));
    case {'primariesxyz'}
        spd  = displayGet(d,'spd primaries');
        wave = displayGet(d,'wave');
        val  = ieXYZFromEnergy(spd',wave);
    case {'primariesrgb','primariessrgb'}
        % The srgb values of the primaries are in the rows of val
        xyz = displayGet(d,'primaries xyz');
        nPrimaries = displayGet(d,'n primaries');
        val = xyz2srgb(XW2RGBFormat(xyz,nPrimaries,1));
        val = RGB2XWFormat(val);
        
    case {'primariesxy'}
        xyz = displayGet(d,'primaries xyz');
        val = chromaticity(xyz);
        
    case {'whitelms'}
        % displayGet(dsp,'white lms')
        rgb2lms = displayGet(d,'rgb2lms');        
        % Sent back in XW format, so a row vector
        val = sum(rgb2lms);

        % Spatial parameters
    case {'dpi', 'ppi'}
        if checkfields(d,'dpi'), val = d.dpi;
        else val = 96;
        end
    case {'metersperdot'}
        % displayGet(dsp,'meters per dot','m')
        % displayGet(dsp,'meters per dot','mm')
        % Useful for calculating image size in meters
        dpi = displayGet(d,'dpi');
        ipm = 1/.0254;   % Inch per meter
        dpm = dpi*ipm;   % Dots per meter
        val = 1/dpm;     % meters per dot
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'dotspermeter'}
        % displayGet(dsp,'dots per meter','m')
        mpd = displayGet(d,'meters per dot');
        val = 1/mpd;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'dotsperdeg','sampperdeg'}
        % Samples per deg
        % displayGet(d,'dots per deg')
        mpd = displayGet(d,'meters per dot');                      
        dist = displayGet(d,'Viewing Distance');  % Meters
        degPerPixel = atand(mpd / dist);
        val = round(1/degPerPixel);
        
    case {'degperpixel', 'degperdot'}
        % degrees per pixel
        % displayGet(d, 'deg per dot')
        mpd = displayGet(d,'meters per dot');                      
        dist = displayGet(d,'Viewing Distance');  % Meters
        val = atand(mpd / dist);
        
    case {'viewingdistance', 'distance'}
        % Viewing distance in meters
        if checkfields(d,'dist'), val = d.dist;
        else val = 0.5;   % Default viewing distance in meters, 19 inches
        end
        
    case {'refreshrate'}
        % display refresh rate
        if isfield(d, 'refreshRate'), val = d.refreshRate; end
        
    % Dixel (subpixel) information
    case {'dixel'}
        % The whole dixel structure
        % displayGet(d, 'dixel')
        if isfield(d, 'dixel'), val = d.dixel; end
        
    case {'dixelsize'}
        % number of samples in one dixel
        % displayGet(d, 'dixel size')
        %
        dixel_image = displayGet(d, 'dixel intensity map');
        val = size(dixel_image);
        val = val(1:2);
    
    case {'oversample', 'osample'}
        % Number of subpixel samples per pixel
        % displayGet(d, 'over sample')
        % I think each pixel is divided into equal area regions for the
        % different subpixels.  So, the routine here simply divides the
        % number of dixel samples by the number of subpixels, which here
        % are called pixels.  (Inhereted from HJ, but maybe we should
        % update notation).
        
        sz  = displayGet(d, 'dixel size');
        val = sz ./ displayGet(d, 'pixels per dixel');
        
    case {'samplespacing'}
        % spacing between psf samples
        % displayGet(d, 'sample sampling', units)
        val = displayGet(d, 'metersperdot') ./ displayGet(d, 'dixel size');
        
        % adjust for the number of pixels in one dixel
        val = val .* displayGet(d, 'pixels per dixel');
        
        if ~isempty(varargin)
            val = val*ieUnitScaleFactor(varargin{1});
        end
    case {'fillfactor','fillingfactor','subpixelfilling'}
        % Fill factor of subpixle for each primary
        % displayGet(d, 'fill factor')
        dixel_image = displayGet(d, 'dixel image');
        [r,c,~] = size(dixel_image);
        dixel_image = dixel_image ./ repmat(max(max(dixel_image)), [r c]);
        dixel_image = dixel_image > 0.2;
        val = sum(sum(dixel_image))/r/c;
        val = val(:);
    case {'subpixelspd'}
        % spectral power distribution for subpixels
        %
        % This is the real subpixel spd, not the spatial averaged one
        % To get the spd for the whole pixel, use displayGet(d, 'spd')
        % instead
        spd = displayGet(d, 'spd');
        ff  = displayGet(d, 'filling factor');
        val = spd ./ repmat(ff(:)', [size(spd, 1) 1]);
    case {'pixelsperdixel'}
        % number of (sub)pixels per dixel
        % returns number of pixels in one block (unit repeated pattern)
        % displayGet(d, 'pixels per dixel')
        % 
        % The field indicates how many pixels (defined as independent
        % addressable (R,G,B,etc) tuple) in one repeating pattern. In most
        % cases, this field is [1 1], meaning that one dixel contains one
        % pixel. For some displays (say samsung s-strip design), one
        % repeating pattern could contain four independent addressable
        % pixels and in that case pixelsperdixel is [2 2]. When HJ built
        % that structure, he assumed that the area occupied by the R,G,B
        % are the same (#R = #G = #B). This may be violated in some
        % displays. Might change this structure when we want to modify it
        % next time.
        if checkfields(d, 'dixel', 'nPixels')
            val = d.dixel.nPixels;
        else
            dixel_control = displayGet(d, 'dixel control map');
            val = max(dixel_control(:));
        end
    case {'dixelintensitymap', 'dixelimage'}
        % dixel intensity map  
        % This field specify the intensity (scale factor) at each sample
        % point in dixel
        %
        % displayGet(d, 'dixel intensity map')
        dixel = displayGet(d, 'dixel');
        if isempty(dixel) % error('dixel structure does not exist');
            val = []; return;
        end
        if isfield(dixel, 'intensitymap')
            val = dixel.intensitymap;
        end
        
        % adjust the size of the intensity map if required
        if ~isempty(varargin)
            sz = varargin{1};
            if isscalar(sz), sz = [sz sz]; end
            
            % resize the intensity map
            val = imresize(val, sz);
            
            % crop the intensity map and make it non-negative
            val(val < 0) = 0;
            
            % scale the intensity map
            scale = prod(sz) ./ sum(sum(val));
            val = bsxfun(@times, val, scale);
        end
    case {'dixelcontrolmap'}
        % dixel control map
        % This field specify which region in one dixel is individually
        % addressable
        %
        % The control map contains integer values from 1 ~ n, its value
        % indicates which control group (actual pixel) it belongs to
        %
        % displayGet(d, 'dixel control map')
        dixel = displayGet(d, 'dixel');
        if isempty(dixel), error('dixel structure not exist'); end
        if isfield(dixel, 'controlmap')
            val = dixel.controlmap;
        end
        
        % adjust the size of the control map if required
        if ~isempty(varargin)
            sz = varargin{1};
            if isscalar(sz), sz = [sz sz]; end
            % resize
            val = imresize(val, sz, 'nearest');
        end
    case {'renderfunction'}
        % render function
        % returns user defined subpixel render function handle. If user
        % does not specify this render function, return empty
        %
        % displayGet(d, 'render function')
        if checkfields(d, 'dixel', 'renderFunc')
            val = d.dixel.renderFunc;
        end
    case {'contrast', 'peakcontrast'}
        % peak contrast
        % returns the black/white contrast of the display
        %
        % displayGet(d, 'peak contrast')
        peakLum = displayGet(d, 'peak luminance');
        darkLum = displayGet(d, 'dark luminance');
        val = peakLum / darkLum;
    case {'darklevel'}
        % dark level
        % returns the first line in the gamma table
        %
        % displayGet(d, 'dark level')
        gTable = displayGet(d, 'gTable');
        val = gTable(1, :);
    case {'blackspd', 'blackradiance'}
        % black radiance
        % computes dark spd (radiance) of the display in units of energy
        % (watts / ...)
        %
        % displayGet(d, 'black radiance')
        dark_level = displayGet(d, 'dark level');
        val = displayGet(d, 'spd') * dark_level';
    case {'darkluminance', 'blackluminance'}
        % dark luminance
        % returns the luminance of display when all pixels are turned off
        %
        % displayGet(d, 'dark luminance')
        blackSpd = displayGet(d, 'black spd');
        blackXYZ = ieXYZFromEnergy(blackSpd', displayGet(d, 'wave'));
        val = blackXYZ(2);
    otherwise
        error('Unknown parameter %s\n',parm);
end

end