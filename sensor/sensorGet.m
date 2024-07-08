function [val, type] = sensorGet(sensor,param,varargin)
%Get properties and derived quantities from ISET sensor object
%
%     val = sensorGet(sensor,param,varargin)
%
%  Unique sensor parameters are stored and many others are derived
%  from the stored values.
%
%  The (very long) sensor parameter list is described below.  The image
%  sensory array (ISA) is often referred to as sensor, or sensor in the
%  code.
%
%  The sensor structure contains the pixel structure in a slot.
%  Because of the importance of the pixel structure, it is possible to
%  retrieve the optics parameters from the sensorGet() function using the
%  syntax
%
%     sensorGet(sensor,'pixel <parameter name>'),
%     e.g., sensorGet(oi,'pixel voltage swing');
%
%  The key structures (scene, oi, sensor, ip, display) are stored in the
%  ISET database.  To retrieve the currently selected optical image, use
%
%     sensor = vcGetObject('sensor');
%
%  A '*' indicates that the syntax oiGet(scene,param,unit) can be used,
%  where unit specifies the spatial scale of the returned value:  'm'
%  'cm', 'mm', 'um', 'nm'.  Default is meters ('m').
%
%  There is a limitation in that we can only add one additional argument.
%  So it is possible to call
%
%    sensorGet(sensor,'pixel size','mm')
%
%  But we do not add a second argument to the list. If you need to have a
%  second argument, use
%
%       sensor = sensorGet(sensor,'pixel');
%       val = pixelGet(pixel,param1,param2);
%
% List of sensor parameters
%      'name'                 - this sensor name
%      'type'                 - always 'sensor'
%      'row'                  - sensor rows
%      'col'                  - sensor columns
%      'size'                 - (rows,cols)
%      'ncaptures'            -  Number of exposures captured
%      'height'*              - sensor height (units)
%      'width'*               - sensor width  (units)
%      'dimension'*           - (height,width)
%      'spatial support'*      - position of pixels.
%      'wspatial resolution'*  - spatial distance between pixels (width)
%      'hspatial resolution'*  - spatial distance between pixels (height)
%
%  Field of view and sampling density
%      'hfov'   - horizontal field of view (deg)
%      'vfov'   - vertical field of view (deg)
%      'h deg perpixel' - horizontal deg per pixel
%      'v deg perpixel' - vertical deg per pixel
%      'h deg perdistance' - deg per unit horizontal distance *
%      'v deg perdistance' - deg per unit vertical distance *
%
%  Sensor optics related
%      'fov'                  - sensor horizontal field of view
%      'chief Ray Angle'        - chief ray angle in radians at each pixel
%          sensorGet(sensor,'chiefRayAngle',sourceFocaLengthMeters)
%      'chief Ray Angle Degrees' - chief ray angle in degrees at each pixel
%          sensorGet(sensor,'chiefRayAngleDegrees',sourceFocaLengthMeters)
%      'sensor Etendue'        - optical efficiency at each pixel
%      'micro Lens'            - microlens data structure, accessed using
%          mlensGet() and mlensSet (optics toolbox only)
%
% Sensor array data
%      'volts'          - Sensor output in volts
%      'digital values' - Sensor output in digital units
%      'electrons'      - Sensor output in electrons
%         A single color plane can be returned
%         sensorGet(sensor,'electrons',2);
%      'electrons per area' - Normalize by the pixel area.  
%          Default units is meter^2, but you can specify unit, um^2          
%          sensorGet(sensor,'electrons per area','um')
%      'chromaticity'   - Sensor rg-chromaticity after Demosaicking (roiRect allowed)
%      'dv or volts'    - Return either dv if present, otherwise volts
%      'response ratio'  - Peak sensor volt divided by voltage swing
%      'response dr'     - Sensor response dynamic range.
%           If min is 0, we use (voltage swing / 2^12) as the smallest
%           value
%
%      'roi locs'       - Stored region of interest (roiLocs)
%      'roi rect'       - Rect.  Format is [cmin,rmin,width,height]
%      'roi volts'      - Volts inside of stored region of interest
%         If there is no stored region of interest, ask the user to select.
%      'roi electrons'  - Electrons inside of stored ROI, or user selects
%      'roi volts mean' - The mean values in each band
%      'roi electrons mean' - As above but electrons
%      'hline volts'    - Volts along a horizontal line
%          sensorGet(sensor,'hline volts',50);
%      'hline electrons' - horizontal line electrons
%      'vline volts'     - vertical line volts
%      'vline electrons' - vertical line electrons
%
% Sensor roi
%     'roi' - rectangle representing current region of interest.
%
% Sensor array electrical processing properties
%      'analog Gain'     - A scale factor that divides the sensor voltage
%                           prior to clipping
%      'analog Offset'   - Added to the voltage to stay away from zero, sometimes used
%                           to minimize the effects of dark noise at the low levels
%         Formula for offset and gain: (v + analogOffset)/analogGain)
%
%      'sensor Dynamic Range' - Computed
%
%      'response type'  - We allow a 'log' sensor type.  Default is
%                          'linear'.  For the 'log' type, we convert
%                          the pixel voltage by log10() on return.
%
%      'quantization'   -  Quantization structure
%        'nbits'        - number of bits in quantization method
%        'max voltage'  - max voltage
%        'max digital'  - 2^nbits
%        'quantization lut'    - If there is a LUT
%        'quantization method' - 'analog','linear','sqrt'
%      'zero level'    - The expected level to a black image
%
% Sensor color filter array and related color properties
%     'spectrum'    - structure about spectral information
%       'wave'      - wavelength samples
%       'binwidth'  - difference between wavelength samples
%       'nwave'     - number of wavelength samples
%     'color'
%       'filter transmissivities' - Filter transmissivity as a function
%            of wave (also 'filter spectra')
%       'infrared filter' - Normally the IR, but we sometimes put other
%            filters, such as macular pigment, in the ir slot.
%
%      'cfa Name'     - Best guess at conventional CFA architecture name
%      'filter Names' - Cell array of filter names. The first letter of
%        each filter should indicate the filter color see sensorColorOrder
%        comments for more information
%      'nfilters'    - number of color filters
%      'filter Color Letters' - A string with each letter being the first
%        letter of a color filter; the letters are from the list in
%        sensorColorOrder. The pattern field(see below) describes their
%        position in array.
%      'filter Color Letters Cell' -  As above, but returned in a cell array
%         rather than a string
%      'filter plotcolors' - one of rgbcmyk for plotting for this filter
%      'spectral QE' - Product of photodetector QE, IR and color filters
%           Does not include vignetting or pixel fill factor.
%      'pattern'     - Matrix that defines the color filter array
%        pattern; e.g. [1 2; 2 3] if the spectrra are RGB and the pattern
%        is a conventional Bayer [r g; g b]
%
% Noise properties
%      'dsnu sigma'           - Dark signal nonuniformity (DSNU) parameter (volts)
%      'prnu sigma'           - Photoresponse nonuniformity (PRNU) parameter (std dev percent)
%      'fpn parameters'       - (dsnusigma,prnusigma)
%      'dsnu image'           - Dark signal non uniformity (DSNU) image
%      'prnu image'           - Photo response non uniformity (PRNU) image
%      'column fpn'           - Column (offset,gain) parameters
%      'column dsnu'          - The column offset parameters (Volts)
%      'column prnu'          - The column gain parameters (std dev in Volts)
%      'col offset fpnvector'  - The sensor column offset data
%      'col gain fpnvector'    - The sensor column gain data
%      'black level'         - set a zero level in volts or digital value,
%                              depending on the quantization method (analog or bits)
%      'noise flag'           - Governs sensorCompute noise calculations
%                                 0 no noise at all
%                                 1 shot noise, no electronics noise
%                                 2 shot noise and electronics noise
%      'reuse noise'         - Use the stored noise seed
%      'noise seed'          - Stored noise seed from last run
%
%  The pixel structure
%      'pixel'  - pixel structure is complex; accessed using pixelGet();
%
%  Sensor computation parameters
%      'auto exposure'   - Auto-exposure flag (0,1)
%      'exposure time'   - Exposure time (sec)
%      'unique exptimes'  - Unique values from the exposure time list
%      'exposure plane'  - Select exposure for display when bracketing
%      'cds'            - Correlated double-sampling flag
%      'pixel vignetting'- Include pixel optical efficiency in
%             sensorCompute.
%             val = 1 Means vignetting only.
%             val = 2 means microlens included. (Microlens shifting NYI).
%             otherwise, skip both vignetting and microlens.
%      'sensor compute','sensor compute method'
%         % Swap in a sensorCompute routine.  If this is empty, then the
%         % standard vcamera\sensor\mySensorCompute routine will be used.
%      'nsamples perpixel','npixel samples for computing'
%         % Default is 1.  If not parameter is not set, we return the default.
%      'consistency'
%         % If the consistency field is not present, assume false and set it
%         % false.  This checks whether the parameters and the displayed
%         % image are consistent/updated.
%
% Human sensor special case
%    'human' - The structure with all human parameters.  Applies only
%      when the name contains the string 'human' in it
%      'cone type' - K=1, L=2, M=3 or S=4 (K means none)
%      'densities' - densities used to generate mosaic (K,L,M,S)
%      'rSeed'     - seed for generating mosaic
%      'xy'        - xy position of the cones in the mosaic
%
% Sensor motion
%       'sensor movement'     - A structure of sensor motion information
%       'movement positions'  - Nx2 vector of (x,y) positions in deg
%       'frames per position' - N vector of exposures per position
%       'sensor positions x'  - 1st column (x) of sensor positions (deg)
%       'sensor positions y'  - 2nd column (y) of sensor positions (deg)
%
% Miscellaneous - Macbeth color checker (MCC)
%   More chart handling is being introduced.  See chart<TAB>
%
%     'mcc rect handles'  - Handles for the rectangle selections in an MCC
%                           (deprecated)
%     'mcc corner points' - Corner points for the MCC chart
%     'corner points'     - Corner points for the any chart.  This will
%                           replace the MCC calls
%
%     'rgb'               - Display image in sensorWindow
%     'gamma'             - Display gamma level
%
% The source file contains examples.
%
% See also:  sensorSet
%
% Copyright ImagEval Consultants, LLC, 2005.

% Examples:
%{
   scene = sceneCreate;
   oi = oiCreate;
   oi = oiCompute(oi,scene);
   sensor = sensorCreate;
   sensor = sensorCompute(sensor,oi);
   val = sensorGet(sensor,'name')
   val = sensorGet(sensor,'size');          % row,col
   val = sensorGet(sensor,'dimension','um');
   val = sensorGet(sensor,'Electrons',2);   % Second color type
   val = sensorGet(sensor,'fov horizontal') % degrees
   val = sensorGet(sensor,'PIXEL')
   val = sensorGet(sensor,'exposureMethod');% Single, bracketed, cfa burst
   val = sensorGet(sensor,'nExposures')     % Number of exposures
   val = sensorGet(sensor,'filternames')
   val = sensorGet(sensor,'exposurePlane'); % For bracketing simulation
   val = sensorGet(sensor,'response type'); % {'linear','log'}
%}
%{
%   These can't run because sensorCFAName() is not exposed externally.
%   cfaName = sensorCFAName(sensor)
%   cfaNames = sensorCFAName
%}

if ~exist('param','var') || isempty(param), error('Param must be defined.'); end

% Should we check and call sensorArrayGet here?
% if length(sensor) > 1, val = sensorArrayGet(sensor,param); return; end

% Default return value.
val = [];

% Added this code so we can make many opticsGet calls using the oi.
% This is like the cameraGet call in which we now can use
%   oiGet(oi,'optics param')
% and that will be equivalent to
%
%   optics = oiGet(oi,'optics');
%   opticsGet(optics,param)
%
% Parse param to see if it indicates which object.  Store parameter.
[oType,param] = ieParameterOtype(param);

switch oType
    case 'pixel'
        pixel = sensor.pixel;
        if isempty(param), val = pixel;
        elseif   isempty(varargin), val = pixelGet(pixel,param);
        else,     val = pixelGet(pixel,param,varargin{:}); % July 2023. BW.
        end
    otherwise
        param = ieParamFormat(param);
        switch param
            
            case {'name'}
                if checkfields(sensor,'name'), val = sensor.name; end
            case {'type'}
                if checkfields(sensor,'type'), val = sensor.type; end
                
            case {'rows','row'}
                % There should not be a rows/cols field at all, right, unless the
                % data field is empty?
                if checkfields(sensor,'data','volts')
                    val = size(sensor.data.volts,1);
                    return;
                elseif checkfields(sensor,'rows'), val = sensor.rows;
                end
            case {'cols','col'}
                % We keep rows/cols field at all, right, unless the
                % data field is empty?
                if checkfields(sensor,'data','volts')
                    val = size(sensor.data.volts,2);
                    return;
                elseif checkfields(sensor,'cols'), val = sensor.cols;
                end
            case {'size','arrayrowcol'}
                % row by col samples
                % sensorGet(sensor,'size')
                val = [sensorGet(sensor,'rows'),sensorGet(sensor,'cols')];
            case {'height','arrayheight'}
                val = sensorGet(sensor,'rows')*sensorGet(sensor,'deltay');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
            case {'width','arraywidth'}
                val = sensorGet(sensor,'cols')*sensorGet(sensor,'deltax');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
            case {'dimension'}
                % height by width in length units
                % sensorGet(sensor,'dimension','mm')
                val = [sensorGet(sensor,'height'), sensorGet(sensor,'width')];
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
            case {'ncaptures'}
                % sensorGet(sensor,'captures')
                %
                % When we use multiple exposure times we have multiple
                % captures in the 3rd dimension of volts or dv.  So after
                % sensor compute this value should be equal to the number
                % of exposure times.  Before sensor compute it can be
                % empty.
                val = sensorGet(sensor,'dv or volts');
                if isempty(val), return;
                elseif ismatrix(val)
                    val = 1;
                else
                    val = size(val,3);
                end
                % The resolutions also represent the center-to-center spacing of the pixels.
            case {'wspatialresolution','wres','deltax','widthspatialresolution'}
                PIXEL = sensorGet(sensor,'pixel');
                val = pixelGet(PIXEL,'width') + pixelGet(PIXEL,'widthGap');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'hspatialresolution','hres','deltay','heightspatialresolultion'}
                PIXEL = sensorGet(sensor,'pixel');
                val = pixelGet(PIXEL,'height') + pixelGet(PIXEL,'heightGap');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'spatialsupport','xyvaluesinmeters'}
                % ss = sensorGet(sensor,'spatialSupport',units)
                nRows = sensorGet(sensor,'rows');
                nCols = sensorGet(sensor,'cols');
                pSize = pixelGet(sensorGet(sensor,'pixel'),'size');
                val.y = linspace(-nRows*pSize(1)/2 + pSize(1)/2, nRows*pSize(1)/2 - pSize(1)/2,nRows);
                val.x = linspace(-nCols*pSize(2)/2 + pSize(2)/2,nCols*pSize(2)/2 - pSize(2)/2,nCols);
                if ~isempty(varargin)
                    val.y = val.y*ieUnitScaleFactor(varargin{1});
                    val.x = val.x*ieUnitScaleFactor(varargin{1});
                end
                
            case {'chiefrayangle','cra','chiefrayangleradians','craradians','craradian','chiefrayangleradian'}
                % Return the chief ray angle for each pixel in radians
                % sensorGet(sensor,'chiefRayAngle',sourceFLMeters)
                support = sensorGet(sensor,'spatialSupport');   %Meters
                
                % Jst flipped .x and .y positions
                [X,Y] = meshgrid(support.x,support.y);
                if isempty(varargin)
                    optics = oiGet(vcGetObject('OI'),'optics');
                    sourceFL = opticsGet(optics,'focalLength'); % Meters.
                else
                    sourceFL = varargin{1};
                end
                
                % Chief ray angle of every pixel in radians
                val = atan(sqrt(X.^2 + Y.^2)/sourceFL);
                
            case {'chiefrayangledegrees','cradegrees','cradegree','chiefrayangledegree'}
                % sensorGet(sensor,'chiefRayAngleDegrees',sourceFL)
                % Returns a matrix containing the chief ray angles of each
                % pixel
                if isempty(varargin)
                    oi = vcGetObject('oi');
                    if isempty(oi)
                        fprintf('No focal length provided, and no oi or optics defined in vcSESSION.');
                        fprintf('To add an oi object use: oi = oiCreate; ieAddObject(oi)');
                        error('No focal length in meters provided');
                    else
                        sourceFL    = oiGet(oi,'optics focal length');
                    end
                else, sourceFL = varargin{1};
                end
                val = rad2deg(sensorGet(sensor,'cra',sourceFL));
            case {'etendue','sensoretendue'}
                % The size of etendue entry matches the row/col size of the sensor
                % array. The etendue is computed using the chief ray angle at each
                % pixel and properties of the microlens structure. Routines exist
                % for calculating the optimal placement of the microlens
                % (mlRadiance). We store the bare etendue (no microlens) in the
                % vignetting location.  The improvement due to the microlens array
                % can be calculated by sensor.etendue/sensor.data.vignetting.  We
                % need to be careful about clearing these fields and data
                % consistency.
                if checkfields(sensor,'etendue'), val = sensor.etendue; end
                
            case {'voltage','volts'}
                % sensorGet(sensor,'volts',ii) gets the ith sensor data in
                % a vector. 
                %
                % sensorGet(sensor,'volts') gets all the sensor data in a
                % single mosaic.
                %
                % When you request a single channel, the data are returned
                % as a vector. If the channel is present twice (e.g., two
                % greens in the Bayer) all the data are concatenated into
                % the vector.
                
                if checkfields(sensor,'data','volts'), val = sensor.data.volts; end
                if ~isempty(varargin), val = sensorColorData(val,sensor,varargin{1}); end

            case{'voltimages'}
                % images = sensorGet(sensor,'volt images')
                %
                % Return the mosaic preserving only the values in the
                % specific channel.  The other channel data are set to
                % zero. The sensor can have more than three color channels.
                rgb = plane2rgb(sensorGet(sensor,'volts'),sensor);

            case{'responseratio','volts2maxratio'}
                % sensorGet(sensor,'response ratio')
                %
                % Ratio of peak data voltage to voltage swing.  Used in
                % displayRender to make sure the image display range
                % matches the sensor data range.
                v = sensorGet(sensor,'volts');
                if isempty(v)
                    % This can happen if we only have digital values
                    dv = sensorGet(sensor,'dv');
                    sm = double(sensorGet(sensor,'max digital value'));

                    % dv might be uint16 or some such.  We force the
                    % return to be a double.
                    val = double(max(dv(:))/sm);
                    return;
                else
                    sm = sensorGet(sensor,'pixel voltage swing');
                    val = max(v(:))/sm;
                end
            case {'responsedr'}
                % sensorGet(sensor,'response dr') - Sensor response dynamic range
                % Dynamic range of the sensor response (minimum to maximum) In the
                % case when there is a very small, say zero, voltage value, we use
                % a 12 bit assumption on the voltage range.
                v = sensorGet(sensor,'volts');
                if isempty(v), warndlg('No sensor voltage'); return; end
                pixel  = sensorGet(sensor,'pixel');
                vSwing = pixelGet(pixel,'vSwing');
                vMax = max(v(:)); vMin = max(min(v(:)),vSwing/(2^12));
                val = vMax/vMin;
                
            case {'analoggain','ag'}
                % Formula for gain and offset
                %   volts = (voltsRaw + ao)/ag;
                if checkfields(sensor,'analogGain'), val = sensor.analogGain;
                else, val = 1;
                end
            case {'analogoffset','ao'}
                if checkfields(sensor,'analogGain'), val = sensor.analogOffset;
                else,   val = 0;
                end
            case {'dv','digitalvalue','digitalvalues'}
                if checkfields(sensor,'data','dv'),val = sensor.data.dv; end
                % Pull out a particular color plane
                if ~isempty(varargin) && ~isempty(val)
                    val = sensorColorData(val,sensor,varargin{1});
                end
                
            case {'electron','electrons'}
                % sensorGet(sensor,'electrons');
                % sensorGet(sensor,'electrons',[colorband]);
                % sensorGet(sensor,'electrons',2);
                %
                % Removed 'photons' from the list March 25, 2024 (BW)
                pixel = sensorGet(sensor,'pixel');

                % The volts also have an analog gain and offset that must
                % be discounted.  Until March 25, 2024 we did not account
                % for this.  Mostly gain/offset was 1/0, and we didn't
                % notice. Then with the imx490 gain manipulations, the bug
                % was found.  This was never a problem with computed
                % voltage or dv.  But if we estimated the electrons in a
                % sensor with a nonunity gain or an offset, the estimated
                % number of electrons at capture was off.
                
                % The sensor compute function applies gain and offset
                % to the raw voltage like this:
                %
                %     volts = (voltsRaw + ao)/ag;
                %
                % Hence, to invert from the stored voltage to the raw,
                % which is a correct estimate of the number of
                % electrons and thus also the intensity of the
                % incident light, we use
                %
                %     voltsRaw = volts*ag - ao                
                %
                ag = sensorGet(sensor,'analog gain');
                ao = sensorGet(sensor,'analog offset');
                volts = double(sensorGet(sensor,'volts'));

                % Maybe clipping should be part of sensorGet for
                % 'volts'.  The reason we need it, I think, is because
                % we are probably not clipping properly on the ao
                % value in sensorCompute. So maybe that should happen.
                % (BW).
                vSwing = sensorGet(sensor,'pixel voltage swing');
                
                % Delete this after a while.  I don't know what the
                % criterion should be.
                assert( min(volts(:)) - ao > -1e-3);                
                volts = ieClip(volts,ao,vSwing);

                % This is the 'raw' voltage times the conversion gain.
                cg = pixelGet(pixel,'conversion gain');
                val = (volts*ag - ao)/cg;

                % Pull out a particular color plane
                if ~isempty(varargin)
                    val = sensorColorData(val,sensor,varargin{1}); 
                end
                
                % Electrons are integers and > 0.  Sometimes because
                % of noise near zero or the offset, we have a negative
                % value.
                val = round(val);
                val = max(val,0);

            case {'electronsperarea'}
                % sensorGet(sensor,'electrons per area','unit',channel)
                % sensorGet(sensor,'electrons per area','m',2)
                % Default is 'um'
                units = 'm';
                if ~isempty(varargin), units = varargin{1}; end
                
                val    = sensorGet(sensor,'electrons');
                pdArea = sensorGet(sensor,'pixel pd area');
                val    = (val/pdArea)/(ieUnitScaleFactor(units)^2);
                % Pull out a particular color plane
                if length(varargin) > 1
                    val = sensorColorData(val,sensor,varargin{2}); 
                end

            case {'dvorvolts'}
                val = sensorGet(sensor,'dv');
                if isempty(val)
                    val = sensorGet(sensor,'volts');
                    type = 'volts';
                else
                    type = 'dv';
                end
                
                % Region of interest for data handling
            case {'roi','roilocs'}
                % roiLocs = sensorGet(sensor,'roi');
                %
                % The roi is stored either as a rect or as an Nx2 matrix of
                % row,col locations.  If the oType is roi we return
                % whatever is there.  If oType is roilocs, we convert the
                % rect to locs.
                if checkfields(sensor,'roi')
                    % The data can be stored as a rect or as roiLocs.
                    val = sensor.roi;
                end
                
                % Convert to locs because the user specified roilocs
                if isequal(param,'roilocs') && size(val,2) == 4
                    val = ieRect2Locs(val);
                end
            case {'roirect'}
                % sensorGet(sensor,'roi rect')
                % Return ROI as a rect
                if checkfields(sensor,'roi')
                    % The data can be stored as a rect or as roiLocs.
                    val = sensor.roi;
                    if size(val,2) ~= 4, val =  ieLocs2Rect(val); end
                end
            case {'roivolts','roidata','roidatav','roidatavolts'}
                % V = sensorGet(sensor,'roi volts');
                %
                % If sensor.roi exists, it is used.  Otherwise, empty
                % is returned and a warning issued.
                if checkfields(sensor,'roi')
                    roiLocs = sensorGet(sensor,'roi locs');
                    val = vcGetROIData(sensor,roiLocs,'volts');
                else, warning('ISET:nosensorroi','No sensor.roi field.  Returning empty voltage data.');
                end
            case {'roielectrons','roidatae','roidataelectrons'}
                % e = sensorGet(sensor,'roi electrons');
                %
                % If sensor.roi exists, it is used.  Otherwise, empty
                % is returned and a warning issued.
                if checkfields(sensor,'roi')
                    roiLocs = sensorGet(sensor,'roi locs');
                    val = vcGetROIData(sensor,roiLocs,'electrons');
                else, warning('ISET:nosensorroi','No sensor.roi field.  Returning empty electron data.');
                end
            case {'roidv','roidigitalcount'}
                % V = sensorGet(sensor,'roi dv');
                %
                % If sensor.roi exists, it is used.  Otherwise, empty
                % is returned and a warning issued.
                if checkfields(sensor,'roi')
                    roiLocs = sensorGet(sensor,'roi locs');
                    val = vcGetROIData(sensor,roiLocs,'dv');
                else, warning('ISET:nosensorroi','No sensor.roi field.  Returning empty voltage data.');
                end
                
            case {'roivoltsmean'}
                % sensorGet(sensor,'roi volts mean')
                % Mean value for each of the sensor types
                % sensorGet(sensor,'roi volts mean');
                d = sensorGet(sensor,'roi volts');
                if isempty(d), return;
                else
                    nSensor = sensorGet(sensor,'n sensor');
                    val = zeros(nSensor,1);
                    for ii=1:nSensor
                        thisD = d(:,ii);
                        val(ii) = mean(thisD(~isnan(thisD)));
                    end
                end
            case {'chromaticity'}
                % rg = sensorGet(sensor,'chromaticity',rect, mode)
                % Estimate the sensor chromaticities
                %
                % Options are: varargin{1}: rect. varargin{2}: mode: 2d (matrix) 
                % or vectorized (vec) chromaticities.
                if isempty(varargin), rect = [];
                else, rect = varargin{1};
                end
                
                % By default, mode is vec
                mode = 'vec';
                if numel(varargin) == 2
                    if ismember(varargin{2}, {'vec', 'matrix'})
                        mode = varargin{2};
                    else
                        warning('Mode should be either %s or %s, using matrix', 'vec', 'matrix')
                    end
                end
                
                
                % Make sure rect starts at odd numbers and height and width
                % are odd numbers to align with a Bayer pattern 
                % (or at least a even number by even number pattern).
                lst = ~isodd(rect); rect(lst) = rect(lst)-1;
                mosaic   = sensorGet(sensor,'volts');
                mosaicDV = sensorGet(sensor, 'dv');
                if ~isempty(rect)
                    mosaic = mosaic(rect(2):rect(2)+rect(4),...
                        rect(1):rect(1)+rect(3),:);
                    if ~isempty(mosaicDV)
                        mosaicDV = mosaicDV(rect(2):rect(2)+rect(4),...
                            rect(1):rect(1)+rect(3),:);
                    end
                end
                
                nChannel = numel(unique(sensorGet(sensor, 'pattern')));
                exp = sensorGet(sensor, 'exp time');
                switch mode
                    case 'vec'
                        res = zeros(size(mosaic, 1) * size(mosaic, 2), nChannel - 1, size(mosaic, 3));
                    case 'matrix'
                        res = zeros(size(mosaic, 1), size(mosaic, 2), nChannel - 1, size(mosaic, 3));
                end
                                        
                for ii=1:size(mosaic, 3)
                    % Use ipCompute to interpolate the mosaic and produce a
                    % chromaticity value at every point.
                    sensorC = sensorSet(sensor,'volts',mosaic(:,:,ii));
                    sensorC = sensorSet(sensorC, 'exp time', exp(ii));
                    sensorC = sensorSet(sensorC, 'dv', mosaicDV(:,:,ii));
                    ip = ipCreate; ip = ipCompute(ip,sensorC);
                    imgDemos = ipGet(ip,'sensor space');   % Just demosaic'd
                    s = sum(imgDemos,3); 
                    for jj=1:nChannel - 1
                        thisChannelChrom = imgDemos(:,:,jj)./s;
                        switch mode
                            case 'vec'
                                res(:,jj,ii) = thisChannelChrom(:);
                            case 'matrix'
                                res(:,:,jj,ii) = thisChannelChrom;
                        end
                            
                    end
                end
                
                val = squeeze(res);
            case {'roichromaticitymean'}
                val = sensorGet(sensor, 'chromaticity', varargin{1});
                val = mean(val, 1,'omitnan');
            case {'roielectronsmean'}
                % sensorGet(sensor,'roi electrons mean')
                %   Mean value for each of the sensor types
                % sensorGet(sensor,'roi electrons mean');
                % Mean value for each of the sensor types
                % sensorGet(sensor,'roi volts mean');
                d = sensorGet(sensor,'roi electrons');
                if isempty(d), return;
                else
                    nSensor = sensorGet(sensor,'n sensor');
                    val = zeros(nSensor,1);
                    for ii=1:nSensor
                        thisD = d(:,ii);
                        val(ii) = mean(thisD(~isnan(thisD)));
                    end
                end
            case {'hlinevolts','hlineelectrons','vlinevolts','vlineelectrons'}
                % sensorGet(sensor,'hline volts',row)
                % Returns: val.data and val.pos
                % Each sensor with values on this row in data
                % The positions of the data in pos.
                if isempty(varargin), error('Specify row or col.');
                else, rc = varargin{1};  % Could be a row or col
                end
                nSensors = sensorGet(sensor,'n sensors');
                
                % Check if the data are in sensor
                if     ieContains(param,'volts'), d = sensorGet(sensor,'volts');
                elseif ieContains(param,'electrons'), d = sensorGet(sensor,'electrons');
                end
                if isempty(d)
                    warning('sensorGet:Nolinedata','No data');
                    return;
                end
                
                support = sensorGet(sensor,'spatial support');
                d = plane2rgb(d,sensor);
                if isequal(param(1),'h')
                    pos = support.x;
                elseif isequal(param(1),'v')
                    % To handle 'h' and 'v' case, we transpose the  'v' data to the
                    % 'h' format, and we get the y-positions.
                    pos = support.y;
                    d = imageTranspose(d);
                else, error('Unknown orientation.');
                end
                
                % Go get 'em
                val.data   = cell(nSensors,1);
                val.pixPos = cell(nSensors,1);
                for ii=1:nSensors
                    thisD = d(rc,:,ii);   % OK because we transposed
                    l = find(~isnan(thisD));
                    if ~isempty(l)
                        val.data{ii} = thisD(l);
                        val.pos{ii}  = pos(l)';
                    end
                end
                
                % Quantization structure
            case {'quantization','quantizationstructure'}
                val = sensor.quantization;
            case {'nbits','bits'}
                if checkfields(sensor,'quantization','bits'), val = sensor.quantization.bits; end
            case {'maxvoltage','max','maxoutput'}
                % sensorGet(sensor,'max voltage')
                pixel = sensorGet(sensor,'pixel');
                val   = pixelGet(pixel,'voltageswing');
            case {'maxdigital','maxdigitalvalue'}
                % sensorGet(sensor,'max digital value')
                nbits = sensorGet(sensor,'nbits');
                if isempty(nbits), return; end

                % ipCompute always removes the zerolevel as part of
                % the input.  So the biggest value we can have is
                % this.
                zeroLevel = sensorGet(sensor,'zero level');
                val = 2^nbits - zeroLevel;                
                
            case {'lut','quantizationlut'}
                if checkfields(sensor,'quantization','lut'), val = sensor.quantization.lut; end
            case {'qMethod','quantizationmethod'}
                if checkfields(sensor,'quantization','method'), val = sensor.quantization.method; end
            case {'responsetype'}
                % Values can be 'log' or 'linear'
                val = 'linear';
                if checkfields(sensor,'responseType'), val = sensor.responseType; end
                
                % Color structure
            case 'color'
                val = sensor.color;
            case {'filterspectra','colorfilters','filtertransmissivities'}
                val = sensor.color.filterSpectra;
            case {'filternames'}
                val = sensor.color.filterNames;
            case {'filtercolorletters'}
                % The color letters returned here are in the order of the filter
                % column position in the matrix of filterSpectra. Only the first
                % letter of the filter name is returned.  This information is used
                % in combination with sensorColorOrder to determine plot colors.
                % The letters are a string.
                %
                % The pattern field(see below) describes the position for each
                % filter in the block pattern of color filters.
                names = sensorGet(sensor,'filter names');
                val = blanks(length(names));
                for ii=1:length(names), val(ii) = names{ii}(1); end
                val = char(val);
            case {'filtercolorletterscell'}
                cNames = sensorGet(sensor,'filterColorLetters');
                nFilters = length(cNames);
                val = cell(nFilters,1);
                for ii=1:length(cNames), val{ii} = cNames(ii); end
                
            case {'filternamescellarray','filtercolornamescellarray','filternamescell'}
                % N.B.  The order of filter colors returned here corresponds to
                % their position in the columns of filterspectra.  The values in
                % pattern (see below) describes their position in array.
                names = sensorGet(sensor,'filternames');
                val = cell(length(names),1);
                for ii=1:length(names), val{ii} = char(names{ii}(1)); end
            case {'filterplotcolor','filterplotcolors'}
                % Return an allowable plotting color for this filter, based on the
                % first letter of the filter name.
                % letter = sensorGet(sensor,'filterPlotColor');
                letters = sensorGet(sensor,'filterColorLetters');
                if isempty(varargin), val = letters;
                else,                 val = letters(varargin{1});
                end
                % Only return an allowable color.  We could allow w (white) but we
                % don't for now.
                for ii=1:length(val)
                    if ~ismember(val(ii),'rgbcmyk'), val(ii) = 'k'; end
                end
            case {'ncolors','nfilters','nsensors','nsensor'}
                val = size(sensorGet(sensor,'filterSpectra'),2);
            case {'ir','infraredfilter','irfilter','otherfilter'}
                % We sometimes put other filters, such as macular pigment, in this
                % slot.  Perhaps we should have an other filter slot.
                if checkfields(sensor,'color','irFilter'), val = sensor.color.irFilter; end
            case {'spectralqe','sensorqe','sensorspectralqe'}
                val = sensorSpectralQE(sensor);
                
                % There should only be a spectrum associated with the
                % sensor, not with the pixel.  I am not sure how to change over
                % to a single spectral representation, though.  If pixels never
                % existed without an sensor, ... well I am not sure how to get the sensor
                % if only the pixel is passed in.  I am not sure how to enforce
                % consistency. -- BW
            case {'spectrum','sensorspectrum'}
                val = sensor.spectrum;
            case {'wave','wavelength'}
                val = sensor.spectrum.wave(:);
            case {'binwidth','waveresolution','wavelengthresolution'}
                wave = sensorGet(sensor,'wave');
                if length(wave) > 1, val = wave(2) - wave(1);
                else, val = 1;
                end
            case {'nwave','nwaves','numberofwavelengthsamples'}
                val = length(sensorGet(sensor,'wave'));
                
                % Color filter array quantities
            case {'cfa','colorfilterarray'}
                val = sensor.cfa;
                
                % I removed the unitBlock data structure because everything that
                % was in unit block can be derived from the cfa.pattern entry.  We
                % are coding the cfa.pattern entry as a small matrix.  So, for
                % example, if it is a 2x2 Bayer pattern, cfa.pattern = [1 2; 2 3]
                % for a red, green, green, blue pattern.  The former entries in
                % unitBlock are redundant with this value and the pixel size.  So,
                % we got rid of them.
            case {'unitblockrows'}
                % sensorGet(sensor,'unit block rows')
                
                % Human patterns don't have block sizes.
                if sensorCheckHuman(sensor), val=1;
                else, val = size(sensorGet(sensor,'pattern'),1);
                end
                
            case 'unitblockcols'
                % sensorGet(sensor,'unit block cols')
                
                % Human patterns don't have block sizes.
                if sensorCheckHuman(sensor), val=1;
                else, val = size(sensorGet(sensor,'pattern'),2);
                end
                
            case {'cfasize','unitblocksize'}
                % We use this to make sure the sensor size is an even multiple of
                % the cfa size. This could be a pair of calls to cols and rows
                % (above).
                
                % Human patterns don't have block sizes.
                if sensorCheckHuman(sensor), val= [1 1];
                else,    val = size(sensorGet(sensor,'pattern'));
                end
                
            case 'unitblockconfig'
                % val = sensor.cfa.unitBlock.config;
                % Is this still used?
                pixel = sensorGet(sensor,'pixel');
                p = pixelGet(pixel,'pixelSize','m');
                [X,Y] = meshgrid((0:(size(cfa.pattern,2)-1))*p(2),(0:(size(cfa.pattern,1)-1))*p(1));
                val = [X(:),Y(:)];
                
            case {'patterncolors','pcolors','blockcolors'}
                % patternColors = sensorGet(sensor,'patternColors');
                % Returns letters suggesting the color of each pixel
                
                pattern = sensorGet(sensor,'pattern');  %CFA block
                filterColorLetters = sensorGet(sensor,'filterColorLetters');
                knownColorLetters = sensorColorOrder('string');
                knownFilters = ismember(filterColorLetters,knownColorLetters);
                % Assign unknown color filter strings to black (k).
                l = find(~knownFilters, 1);
                if ~isempty(l), filterColorLetters(l) = 'k'; end
                % Create a block that has letters instead of numbers
                val = filterColorLetters(pattern);
                
            case {'cfapattern','pattern'}
                if checkfields(sensor,'cfa','pattern'), val = sensor.cfa.pattern; end
            case 'cfaname'
                % We look up various standard names
                val = sensorCFAName(sensor);
                
                % Pixel related parameters
            case 'pixel'
                val = sensor.pixel;
                
            case {'dr','drdb20','dynamicrange','sensordynamicrange'}
                % Calculated using 20 log10 formula.  Not sure that is
                % a great idea.  Also, different from what we are
                % doing in scene and oi
                val = sensorDR(sensor);
                
            case 'diffusionmtf'
                val = sensor.diffusionMTF;
                
                % These are pixel-wise FPN parameters
            case {'fpnparameters','fpn','fpnoffsetgain','fpnoffsetandgain'}
                val = [sensorGet(sensor,'sigmaOffsetFPN'),sensorGet(sensor,'sigmaGainFPN')];
            case {'dsnulevel','sigmaoffsetfpn','offsetfpn','offset','offsetsd','dsnusigma','sigmadsnu'}
                % This value is stored in volts
                val = sensor.sigmaOffsetFPN;
            case {'sigmagainfpn','gainfpn','gain','gainsd','prnusigma','sigmaprnu','prnulevel'}
                % This is a percentage, between 0 and 100, always.
                val = sensor.sigmaGainFPN;
                
            case {'dsnuimage','offsetfpnimage'} % Dark signal non uniformity (DSNU) image
                % These should probably go away because we compute them afresh
                % every time.
                if checkfields(sensor,'offsetFPNimage'), val = sensor.offsetFPNimage; end
            case {'prnuimage','gainfpnimage'}  % Photo response non uniformity (PRNU) image
                % These should probably go away because we compute them afresh
                % every time.
                if checkfields(sensor,'gainFPNimage'), val = sensor.gainFPNimage; end
                
                % These are column-wise FPN parameters
            case {'columnfpn','columnfixedpatternnoise','colfpn'}
                % This is stored as a vector (offset,gain) standard deviations in
                % volts.  This is unlike the storage format for array dsnu and prnu.
                if checkfields(sensor,'columnFPN'), val = sensor.columnFPN;
                else
                    val = [0,0];
                end
            case {'columndsnu','columnfpnoffset','colfpnoffset','coldsnu'}
                tmp = sensorGet(sensor,'columnfpn'); val = tmp(1);
            case {'columnprnu','columnfpngain','colfpngain','colprnu'}
                tmp = sensorGet(sensor,'columnfpn'); val = tmp(2);
            case {'coloffsetfpnvector','coloffsetfpn','coloffset'}
                if checkfields(sensor,'colOffset'), val = sensor.colOffset; end
            case {'colgainfpnvector','colgainfpn','colgain'}
                if checkfields(sensor,'colGain'),val = sensor.colGain; end
                
            case {'blacklevel', 'zerolevel'}
                % Calculate the zero level for the user, who sent in an
                % empty value.  This level depends on the analog offset and
                % gain.  We return either the voltage or if the
                % quantization method is used we return the digital value.
                %
                % In some cases we have a digital zero level in the file
                % (e.g., DNG data from the pixel4a).  In that case, we
                % should be able to simply set the value and read it.
                if checkfields(sensor,'blackLevel')
                    val = sensor.blackLevel;
                else
                    oiBlack = oiCreate('black');
                    sensor2 = sensorSet(sensor,'noiseflag',0); % Little noise
                    sensor2 = sensorCompute(sensor2,oiBlack);
                    switch sensorGet(sensor,'quantization method')
                        case 'analog'
                            val = sensorGet(sensor2,'volts');
                        otherwise
                            val = sensorGet(sensor2,'dv');
                    end
                    val = mean(val(:));
                end
                
                % Noise management
            case {'noiseflag','shotnoiseflag'}
                % 0 means no noise
                % 1 means shot noise but no electronics noise
                % 2 means shot noise and electronics noise
                if checkfields(sensor,'noiseFlag'), val = sensor.noiseFlag;
                else, val = 2;    % Compute both electronic and shot noise
                end
            case {'reusenoise'}
                if checkfields(sensor,'reuseNoise'), val = sensor.reuseNoise;
                else, val = 0;    % Do not reuse
                end
            case {'noiseseed'}
                if checkfields(sensor,'noiseSeed'), val = sensor.noiseSeed;
                else
                    try
                        rng('default');
                    catch
                        rng('seed');
                    end% Compute both electronic and shot noise
                end
                
            case {'ngridsamples','pixelsamples','nsamplesperpixel','npixelsamplesforcomputing'}
                % Default is 1.  If not parameter is not set, we return the default.
                if checkfields(sensor,'samplesPerPixel'),val = sensor.samplesPerPixel;
                else, val = 1;
                end
                
                % Exposure related
            case {'exposuremethod','expmethod'}
                % We plan to re-write the exposure parameters into a sub-structure
                % that lives inside the sensor, sensor.exposure.XXX
                % add support for manually setting exposure type
                if isfield(sensor, 'exposureMethod') && ~isempty(sensor.exposureMethod)
                    val = sensor.exposureMethod;
                else
                    tmp = sensorGet(sensor,'exptimes');
                    p   = sensorGet(sensor,'pattern');
                    if     isscalar(tmp), val = 'singleExposure';
                    elseif isvector(tmp),  val = 'bracketedExposure';
                    elseif isequal(size(p),size(tmp)),  val = 'cfaExposure';
                    end
                end
            case {'integrationtime','integrationtimes','exptime','exptimes','exposuretimes','exposuretime','exposureduration','exposuredurations'}
                % This can be a single number, a vector, or a matrix that matches
                % the size of the pattern slot. Each one of these cases is handled
                % differently by sensorComputeImage.  The units are seconds by
                % default.
                % sensorGet(sensor,'expTime','s')
                % sensorGet(sensor,'expTime','us')
                val = sensor.integrationTime;
                if ~isempty(varargin)
                    val = val*ieUnitScaleFactor(varargin{1});
                end
            case {'uniqueintegrationtimes','uniqueexptime','uniqueexptimes'}
                val = unique(sensor.integrationTime);
            case {'centralexposure','geometricmeanexposuretime'}
                % We return the geometric mean of the exposure times
                % We should consider making this the geometric mean of the unique
                % exposures.
                eTimes = sensorGet(sensor,'exptimes');
                val = prod(eTimes(:))^(1/length(eTimes(:)));
            case {'autoexp','autoexposure','automaticexposure'}
                val = sensor.AE;
            case {'nexposures'}
                % We can handle multiple exposure times.
                val = numel(sensorGet(sensor,'expTime'));
            case {'exposureplane'}
                % When there are multiple exposures, show the middle integration
                % time, much like a bracketing idea.
                %
                % N.B. When there is a different exposure for every
                % position in the CFA, we wouldn't normally use this.  In
                % that case we only have a single integrated CFA.
                if checkfields(sensor,'exposurePlane'), val = sensor.exposurePlane;
                else, val = floor(sensorGet(sensor,'nExposures')/2) + 1;
                end
                
            case {'cds','correlateddoublesampling'}
                val = sensor.CDS;
                
                % Microlens related
            case {'vignettingflag','vignetting','bareetendue','sensorbareetendue','nomicrolensetendue'}
                % If the vignetting flag has not been set, treat it as 'skip',
                % which is 0.
                if checkfields(sensor,'data','vignetting')
                    if isempty(sensor.data.vignetting), val = 0;
                    else,                            val = sensor.data.vignetting;
                    end
                else
                    val = 0;
                end
            case {'vignettingname'}
                pvFlag = sensorGet(sensor,'vignettingFlag');
                switch pvFlag
                    case 0
                        val = 'skip';
                    case 1
                        val = 'bare';
                    case 2
                        val = 'centered';
                    case 3
                        val = 'optimal';
                    otherwise
                        error('Bad pixel vignetting flag')
                end
                
            case {'microlens','ulens','mlens','ml'}
                if checkfields(sensor,'ml'), val = sensor.ml; end
                
                % Field of view and sampling density
            case {'hfov','fov','sensorfov','fovhorizontal','fovh'}
                % sensorGet(sensor,'fov',sDist,oi); - Explicit scene dist in m
                % sensorGet(sensor,'fov',scene,oi); - Explicit scene
                % sensorGet(sensor,'fov');          - Uses defaults.  Dangerous.
                %
                % This is the horizontal field of view (default)
                %
                % I think this is too complex.  The assumption here is that
                % the sensor is at the proper focal distance for the scene.
                % If the scene is at infinity, then the focal distance is
                % the focal length. But if the scene is close, then we
                % might correct.
                %
                % But we should probably just compute it assuming the scene
                % is infinitely far away and the distance to the lens is
                % the focal distance.
                %
                if isempty(varargin) || isempty(varargin{1})
                    scene = ieGetObject('scene');
                    if isempty(scene), sDist = 1e6;
                    else,              sDist = sceneGet(scene,'distance');
                    end
                else
                    scene = varargin{1};
                    if isstruct(scene), sDist = sceneGet(scene,'distance','m');
                    else,               sDist = scene;
                    end
                end
                
                % The image distance depends on the scene distance and
                % focal length via the lensmaker's formula, (we assume the
                % sensor is at the proper focal distance).
                if length(varargin) > 1, oi = varargin{2};
                else,                    oi = ieGetObject('oi');
                end
                if isempty(oi)
                    distance = opticsGet(opticsCreate,'focal length');
                else
                    distance = oiGet(oi,'optics focal plane distance',sDist);
                end
                width = sensorGet(sensor,'arraywidth');
                val = rad2deg(2*atan(0.5*width/distance));
                
            case {'fovvertical','vfov','fovv'}
                % This is  the vertical field of view
                % sensorGet(sensor,'fov vertical',sDist,oi); - Explicit scene dist in m
                % sensorGet(sensor,'fov vertical',scene,oi); - Explicit scene
                % sensorGet(sensor,'fov vertical');          - Uses defaults.  Dangerous.
                %
                % This is the horizontal field of view (default)
                % We compute it from the distance between the lens and the sensor
                % surface and we also use the sensor array width.
                % The assumption here is that the sensor is at the proper focal
                % distance for the scene.  If the scene is at infinity, then the
                % focal distance is the focal length.  But if the scene is close
                % then we might correct.
                %
                if ~isempty(varargin), scene = varargin{1};
                else,                  scene = vcGetObject('scene');
                end
                if length(varargin) > 1, oi = varargin{2};
                else,                    oi = vcGetObject('oi');
                end
                % If no scene is sent in, assume the scene is infinitely far away.
                if isempty(scene), sDist = Inf;
                else
                    % The user might have sent a scene struct or a scene distance
                    % in meters.
                    if isstruct(scene), sDist = sceneGet(scene,'distance');
                    else,               sDist = scene;
                    end
                end
                % If there is no oi, then use the default optics focal length. The
                % image distance depends on the scene distance and focal length via
                % the lensmaker's formula, (we assume the sensor is at the proper
                % focal distance).
                if isempty(oi)
                    distance = opticsGet(opticsCreate,'focal length');
                    % fprintf('Sensor fov estimated using focal length = %f m\n',distance);
                else
                    distance = opticsGet(oiGet(oi,'optics'),'focal plane distance',sDist);
                end
                
                height = sensorGet(sensor,'array height');
                val = rad2deg(2*atan(0.5*height/distance));
                
            case {'hdegperpixel','degpersample','degreesperpixel'}
                % degPerPixel = sensorGet(sensor,'h deg per pixel',oi);
                %
                % Horizontal field of view divided by number of pixels
                sz =  sensorGet(sensor,'size');
                
                if isempty(varargin), oi = vcGetObject('oi');
                else, oi = varargin{1};
                end
                
                % The horizontal field of view should incorporate information from
                % the optics.
                sDist = 1e6;   % Assume the scene is very far away.
                val = sensorGet(sensor,'hfov',sDist,oi)/sz(2);
            case {'vdegperpixel','vdegreesperpixel'}
                sz =  sensorGet(sensor,'size');
                val = sensorGet(sensor,'vfov')/sz(1);
            case {'hdegperdistance','degperdistance'}
                % sensorGet(sensor,'h deg per distance','mm')
                % sensorGet(sensor,'h deg per distance','mm',scene,oi);
                % Degrees of visual angle per meter or other spatial unit
                if isempty(varargin), unit = 'm'; else, unit = varargin{1}; end
                width = sensorGet(sensor,'width',unit);
                
                if length(varargin) < 2, scene = vcGetObject('scene');
                else, scene = varargin{2};
                end
                
                % We want the optics to do this right.
                if length(varargin) < 3, oi = vcGetObject('oi');
                else, oi = varargin{3};
                end
                
                fov   =  sensorGet(sensor,'fov',scene, oi);
                val   = fov/width;
                
            case {'vdegperdistance'}
                % sensorGet(sensor,'v deg per distance','mm') Degrees of visual
                % angle per meter or other spatial unit
                if isempty(varargin), unit = 'm'; else, unit = varargin{1}; end
                width = sensorGet(sensor,'height',unit);
                fov =  sensorGet(sensor,'vfov');
                val = fov/width;
                
            case {'chartparameters'}
                % Struct of chart parameters
                if checkfields(sensor,'chartP'), val = sensor.chartP; end
            case {'cornerpoints','chartcornerpoints','chartcorners'}
                % fourPoints = sensorGet(sensor,'chart corner points');
                if checkfields(sensor,'chartP','cornerPoints'), val = sensor.chartP.cornerPoints; end
            case {'chartrects','chartrectangles'}
                % rects = sensorGet(sensor,'chart rectangles');
                if checkfields(sensor,'chartP','rects'), val = sensor.chartP.rects; end
            case {'currentrect'}
                % [colMin rowMin width height]
                % Used for ROI display and management.
                if checkfields(sensor,'chartP','currentRect'), val = sensor.chartP.currentRect; end
                
                % Display image
            case {'rgb'}
                % sensorGet(sensor,'rgb',dataType,gam,scaleMax)
                dataType = 'volts';
                gam = 1;
                scaleMax = 0;
                if ~isempty(varargin), dataType = varargin{1}; end
                if length(varargin) > 1, gam = varargin{2}; end
                if length(varargin) > 2, scaleMax = varargin{3}; end
                val = sensorData2Image(sensor,dataType,gam,scaleMax);
                
            case {'gamma'}
                % The gamma display in the sensor window
                % sensorGet(sensor,'gamma')
                app = ieSessionGet('sensor window');
                if ~isempty(app)
                    val = str2double(app.GammaEditField.Value);
                end
            case {'maxbright','scalemax'}
                % Scale the displayed image to max (1,1,1)
                % Returns true (scale to max) or false
                % sensorGet(sensor,'scale max')
                app = ieSessionGet('sensor window');
                val = true;
                if ~isempty(app) && strcmpi(app.MaxbrightSwitch.Value,'Off')
                    val = false;
                end
                
                % Metadata - more to be added.  See sensorSet()
            case 'metadatacrop'
                val = sensor.metadata.crop;
            case 'metadatascenename'
                val = sensor.metadata.scenename;
            case 'metadataopticsname'
                val = sensor.metadata.opticsname;

                % Human cone case - Many of these should go way (BW)
            case {'human'}
                % Structure containing information about human cone case
                % Only applies when the name field has the string 'human' in it.
                if checkfields(sensor,'human'), val = sensor.human; end
            case {'humancone type','conetype'}
                % Blank (K) K=1 and L,M,S cone at each position
                % L=2, M=3 or S=4 (K means none)
                % Some number of cone types as cone positions.
                if checkfields(sensor,'human','coneType'), val = sensor.human.coneType; end
            case {'humanconedensities','densities'}
                %- densities used to generate mosaic (K,L,M,S)
                if checkfields(sensor,'human','densities'), val = sensor.human.densities; end
            case   {'humanconelocs','conexy','conelocs','xy'}
                %- xy position of the cones in the mosaic
                if checkfields(sensor,'human','xy'), val = sensor.human.xy; end
            case {'humanrseed','humanconeseed'}
                % random seed for generating cone mosaic
                % Should get rid of humanrseed alias
                if checkfields(sensor,'human','rSeed'), val = sensor.human.rSeed; end
                
                % Sensor motion -  used for eye movements or camera shake
            case {'sensormovement','eyemovement'}
                % A structure with sensor motion information
                if checkfields(sensor,'movement')
                    val = sensor.movement;
                end
            case {'movementpositions','sensorpositions'}
                % Nx2 vector of (x,y) positions in deg
                if checkfields(sensor,'movement','pos'), val = sensor.movement.pos;
                else, val = [0,0];
                end
            case {'sensorpositionsx'}
                if checkfields(sensor,'movement','pos')
                    val = sensor.movement.pos(:,1);
                else, val = 0;
                end
            case {'sensorpositionsy'}
                if checkfields(sensor,'movement','pos')
                    val = sensor.movement.pos(:,2);
                else, val = 0;
                end
            case {'framesperposition','exposuretimesperposition','etimeperpos'}
                % Exposure frames for each (x,y) position
                % This is a vector with some number of exposures for each x,y
                % position (deg)
                if checkfields(sensor,'movement','framesPerPosition')
                    val = sensor.movement.framesPerPosition;
                else
                    val = 1;
                end
                %
            otherwise
                error('Unknown sensor parameter.');
        end
end

end



%--------------------------------
function cfaName = sensorCFAName(sensor)
% Determine the cfa name in order to populate the lists in pop up boxes.
%
%     cfaName = sensorCFAName(sensor)
%
% If sensor is passed in, return a standard name for the CFA types.
% If sensor is empty or absent return the list of standard names.
%
% The normal naming convention for CFA is to read left to right.  For
% example,
%     G B
%     R G
% is coded as 'gbrg'
% The pattern matrix stored in sensor is a 2x2 array, usually.  Thus, the
% values are stored as
%     [2 1; 3 2]
%   =    2 1
%        3 2
%
% Copyright Imageval Consulting, LLC 2010

if ieNotDefined('sensor')
    cfaName = sensorCFANameList;
    return;
end

p = sensorGet(sensor,'pattern');
filterColors = sensorGet(sensor,'filterColorLetters');
filterColors = sort(filterColors);

if length(p(:)) == 1
    cfaName = 'Monochrome';
elseif ~isequal(size(p),[2,2])
    cfaName = 'Other'; return;
elseif strcmp(filterColors,'bgr')
    cfaName = 'Bayer RGB';
elseif strcmp(filterColors,'cmy')
    cfaName = 'Bayer CMY';
elseif strcmp(filterColors,'bgrw')
    cfaName = 'RGBW';
else
    cfaName = 'Other';
end

end
%------------------------------------------
function spectralQE = sensorSpectralQE(sensor)
% Compute the sensor spectral QE
%
%    spectralQE = sensorSpectralQE(sensor)
%
% Combine the pixel detector, the sensor color filters, and the infrared
% filter into a sensor spectral QE.   If the variable wave is in the
% calling arguments, the spectralQE is returned interpolated to the
% wavelengths in wave.
%

sensorIR = sensorGet(sensor,'irfilter');
cf = sensorGet(sensor,'filterspectra');
% isaWave = sensorGet(sensor,'wave');

pixelQE = pixelGet(sensor.pixel,'qe');
if isempty(pixelQE)
    warndlg('Empty pixel QE. Assuming QE(lambda) = 1.0');
    pixelQE = ones(size(sensorIR(:)));
end

% Compute the combined wavelength sensitivity including the ir filter, the
% pixel QE, and the color filters.
spectralQE = diag(pixelQE(:) .* sensorIR(:)) * cf;

end

%------------------------
function val = sensorColorData(data,sensor,whichSensor)
% Retrieve data from one of the sensor planes.
%
% The data are returned in a vector, not a plane.
%
% This should also be able to return a planar image with zeros, not just a
% vector.  But surely this form was written some time ago.

% In most cases, we can convert the data to a 3D and return the values in
% the RGB 3D.  In human, we have the whole pattern.  Probably we should
% always get the
%
% This might work in both cases ... but sensorDetermineCFA may not be
% running right for the human case.  Have a look.  For now, we are only
% using the 'ideal' condition with human.
%
% electrons = sensorGet(sensor,'electrons');
% [tmp,n] = sensorDetermineCFA(sensor);
% b = (n==whichSensor);
% val = electrons(b);

% The one we have been using
rgb        = plane2rgb(data,sensor);
thisSensor = rgb(:,:,whichSensor);
l   = ~isnan(thisSensor);
val = thisSensor(l);

end

% TODO:
%
% The pixel height and width may differ from the center-to-center distance
% between pixels in the sensor.  This is because of additional gaps between
% the pixels (say for wires). The center-to-center spacing between pixels
% is contained in the deltaX, deltaY parameters.
%
% For consistency with the other structures, I also introduced the
% parameters hspatialresolution and wspatialresolution to refer to the
% deltaY and deltaX center-to-center spacing of the pixels.  We might
% consider adding just hresolution and wresolution for spatial, with
% angular being special.
%
% In several cases we use the spatial coordinates of the sensor array to
% define a coordinate system, say for the optical image.  In this case, the
% integer coordinates are defined by the deltaX and deltaY values.
%
% get cfa matrix as letters or numbers via sensorDetermineCFA in here.

