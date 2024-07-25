function val = ipGet(ip,param,varargin)
%Get image processor parameters and derived quantities.
%
% Synopsis
%   val = ipGet(ip,param,varargin)
%
% Brief
%  Returns stored and derived image processing (ip) parameters.  The
%  term data refers to the display primary linear intensities.
%
%  If the first part of the param is 'display', then we call
%  displayGet, using the part after display as the parameter.  For
%  example, ipGet(ip,'display spd');
%
% Image Processor parameters
%      'name'  - This image processing structure name
%      'type'  - Always 'vcimage'
%      'row'   - Display row number
%      'col'   - Display col number
%      'input size'  - [row,col]
%      'result size' - [row,col]
%
% Rendering methods and transforms (matrices)
%      'render'       - Render structure
%          Includes gamma and scale parameters
%      'demosaic'     - Demosaic structure
%      'demosaic method' - Spatial demosaicking function
%
%      'sensor conversion'  - Sensor conversion structure
%      'sensor conversion method'    - Function name for color conversion
%      'sensor conversion matrix'    - sensor conversion (transform{1})
%
%      'illuminant correction' - Illuminant correction structure
%      'illuminant correction method'  - Function name for color balance
%      'illuminant correction matrix'  - illuminant color balance    (transform{2})
%
%      'internal color space'          - Internal color space name (e.g.,'XYZ')
%      'internal color matching function' - Reads the file with the name
%
%      'transforms' - All rendering transforms in a cell array
%      'ics2display transform'      - Internal color space to display (transform{3})
%      'transform combined'         - Product of the other 3 matrices
%                                             tSC{1}*tIC{2}*tICS2D{3}
%      'each transform'             - cell array of three matrices
%
% Wavelength functions for the internal color space
%      'spectrum'   - Wavelength information structure
%      'wavelength' - wavelength samples
%      'binwidth'   - wavelength bin size
%      'nwave'      - number of wavelength samples
%
% DATA information (data generally means the display intensities)
%      'data'  - Data structure
%       'sensor mosaic'   - Sensor mosaic data that initiates rendering
%       'sensor channels' - Sensor data demosaicked into RGB format
%       'nSensor channels'- Number of sensor channel inputs
%       'maximum sensor value' - The maximum voltage (or dv) for the
%                                input sensor
%
%       'data display'  - Linear values for the primaries, [0,1]
%       'data srgb'     - sRGB rendering of the display data 
%                         (Shown in the GUI window)
%       'data xyz'      - CIE XYZ values of the display data
%       'data luminance'- The Y value of the CIE XYZ
%
%       'data ics'      - Internal color space representation 
%                         (often XYZ, but not always).
%       'data roi'      - Slot to store region of interest RGB data
%       'data scaled to max' - Display data scaled to display max
%       'data intensities max' - Maximum of the display linear
%                                intensities
%       'scale display'
%       'data white point'
%       'data or display white'  - Data white point if present, otherwise
%                                   display white point
%
% Miscellaneous
%     'roi xyz'           - Slot to store XYZ values of ROI data
%     'mcc Rect Handles'  - Handles for the rectangle selections in an MCC
%                           (deprecated in Matlab 2020a app version.)
%     'mcc Corner Points' - Outer corners of the MCC
%     'corner points'     - Four corners for general charts.  Will replace
%                            the MCC special case along with chart<>
%                            functions.
%     'center'            - (r,c) at the image center
%     'distance2center'   - Distance (in pixels) to image center
%     'angle'             - Angle around image center
%     'image grid'        - X,Y coords (in pixels) from image center
%                            Returned in a cell array
%     'L3'                - L3 structure.  Requires L3 repository.
%
% Description
%  The image processing parameters are stored in a struct (ip). The
%  parameters define both values and functions needed to perform,
%  say, demosaicking, sensor conversion or illuminant correction.
%  These transform parameters are the 3x3 linear transformations
%  applied in many of these cases.
%
%  The image processing structure contains a display structure. Because of
%  the importance of the display structure, it is possible to retrieve
%  display parameters from the ipGet() function using the syntax
%
%     ipGet(ip,'display <parameter name>'),
%     e.g., ipGet(ip,'display spd');
%
% See also
%   ipSet, sensorGet, ...
%

% Examples:
%{
  camera = cameraCreate;
  scene  = sceneCreate;
  camera = cameraCompute(camera,scene);
  ip  = cameraGet(camera,'ip');
  center = ipGet(ip,'center')
  d2c    = ipGet(ip,'distance2Center'); 
  ieNewGraphWin; mesh(d2c)
  ct = ipGet(ip,'combined transform')
  sum(ct)
  ipGet(ip,'display')
  spd = ipGet(ip,'display spd'); 
  plotRadiance(ipGet(ip,'wave'),spd);
%}

%% Check parameters, deal with display syntax and also apply ieParamFormat

val = [];
if ~exist('ip','var') || isempty(ip),   error('Valid ip required'); end
if ~exist('param','var') || isempty(param), error('Valid param required'); end

% Interpret the param
[oType,oParam] = ieParameterOtype(param);
param = ieParamFormat(param);

%% Switch on
switch oType
    
    case 'display'
        % This is for the display object attached to image processor
        display = ip.display;
        if isempty(oParam), val = display;
        elseif   isempty(varargin), val = displayGet(display,oParam);
        else,    val = displayGet(display,oParam,varargin{1});
        end
        
    case 'l3'
        % This should be deprecated
        %
        % L3 object is attached to image processor.  Code for L3, though
        % is in a separate repository. 
        
        % If there is no L3, return empty
        if isfield(ip,'L3'), L3 = ip.L3;
        else, return;
        end
        
        % Either return L3 or the L3 param
        if isempty(oParam), val = L3;
        elseif   isempty(varargin), val = L3Get(L3,oParam);
        else,    val = L3Get(L3,oParam,varargin{1});
        end
        
    otherwise
        % Parameters
        
        switch param
            case {'type'}
                val = ip.type;
            case {'name'}
                val = ip.name;
            case {'spectrum','spectrumstructure'}
                val = ip.spectrum;
            case {'wave','wavelength'}
                val = ip.spectrum.wave;
            case {'binwidth','waveresolution'}
                wave = ipGet(ip,'wave');
                if length(wave) > 1, val = wave(2) - wave(1);
                else, val = 1;
                end
            case {'nwave','nwaves'}
                val = length(ipGet(ip,'wave'));
            case {'row','rows'}
                if checkfields(ip,'data','input'),val = size(ip.data.input,1); end
            case {'col','cols'}
                if checkfields(ip,'data','input'),val = size(ip.data.input,2); end
            case {'inputsize'}
                if checkfields(ip,'data','input'), val = size(ip.data.input); end
            case {'rgbsize','resultsize','displaysize','size'}
                if checkfields(ip,'data','result'), val = size(ip.data.result); end
                
                % Calibrated color space, or sensor spectral QE.
            case {'internalcs','internalcolorspace'}
                % ipGet(ip,'interal color space')
                %
                % Color space used for calculations such as color balancing. This
                % should always be the name of a file that can be read (see
                % intermal cmf, below).
                val = ip.internalCS;
            case {'internalcmf','internalcolormatchingfunction'}
                % ipGet(ip,'internal cmf')
                % Wavelength functions for the internal color space
                fName = ipGet(ip,'internalcs');
                if strcmpi(fName,'sensor'), return;
                else
                    val = ieReadSpectra(fName,ipGet(ip,'wave'));
                end
                
                % Imageval pipeline management
            case {'illuminantcorrection'}
                val = ip.illuminantCorrection;
            case {'illuminantcorrectionmethod'}
                val = ip.illuminantCorrection.method;
                if isempty(val), val = 'None'; end
                
            case {'demosaic','demosaicstructure'}
                val = ip.demosaic;
            case {'demosaicmethod'}
                val = ip.demosaic.method;
                if isempty(val), val = 'None'; end
                
                % We consider color conversion to mean sensor correction, that is
                % conversion of sensor data to the internal color space.
            case {'sensorconversion','conversionsensor'}
                val = ip.sensorCorrection;
            case {'sensorconversionmethod','conversionmethodsensor'}
                val = ip.sensorCorrection.method;
                if isempty(val), val = 'None'; end
            case {'sensorconversionmatrix'}
                val = ip.data.transforms{1};

                % Image processing matrices (transforms)
            case {'transformcellarray','transforms'}
                if checkfields(ip,'data','transforms'), val = ip.data.transforms; end
            case {'transformmethod'}
                % tMethod = ipGet(ip,'transform method')
                % Other options are 'New' and 'Current'
                if checkfields(ip,'transformMethod'),val = ip.transformMethod; end
            case {'conversiontransformsensor','correctionmatrixsensor'}
                transforms = ipGet(ip,'transforms');
                if length(transforms) >= 1 && ~isempty(transforms{1})
                    val = transforms{1};
                else,  val = eye(3,3);
                end
            case {'illuminantcorrectionmatrix','correctiontransformilluminant','correctionmatrixilluminant'}
                transforms = ipGet(ip,'transforms');
                if length(transforms) >= 2 && ~isempty(transforms{2})
                    val = transforms{2};
                else,   val = eye(3,3);
                end
            case {'ics2display','ics2displaymatrix','ics2displaytransform','internalcs2displayspace'}
                transforms = ipGet(ip,'transforms');
                if length(transforms) >= 3 && ~isempty(transforms{3})
                    val = transforms{3};
                else,  val = eye(3,3);
                end
            case {'transformcombined','combinedtransform','prodt'} %product of transforms (prodT)
                % This is meant to be rowVec*M were rowVec = (r,g,b). If the
                % transform is empty for any of these, the 3x3 identity is returned
                % by the ipGet
                C = ipGet(ip,'conversion transform sensor');
                B = ipGet(ip,'correction transform illuminant ');
                D = ipGet(ip,'ics2display transform');
                val = C*B*D;
            case {'transformlist','eachtransform'}
                % cell array of the three transforms
                val = cell(1,3);
                val{1} = ipGet(ip,'conversion transform sensor');
                val{2} = ipGet(ip,'correction transform illuminant ');
                val{3} = ipGet(ip,'ics2Display transform');
                
                % ISET window rendering management
            case {'renderstructure','render'}
                % Structure
                if checkfields(ip,'render'), val = ip.render; end
            case {'renderflag'}
                % Interpretations
                % 1 -> rgb, 2 -> hdr, 3 -> gray
                if checkfields(ip,'render','renderflag')
                    val = ip.render.renderflag; 
                end
            case {'renderscale','scaledisplay','scaledisplayoutput'}
                % Returns a scale factor to apply to display output
                if checkfields(ip,'render','scale')
                    val = ip.render.scale;
                else
                    app = ieSessionGet('ip window');
                    if ~isempty(app) && isvalid(app)
                        switch lower(app.MaxbrightSwitch.Value)
                            case 'on'
                                val = 1;
                            case 'off'
                                val = 0;
                        end
                        
                    else
                        val = 0;
                    end
                    ip.render.scale = val;
                end
                
            case {'rendergamma','gamma'}
                % Gamma value used to render the display in the ipWindow
                if checkfields(ip,'render','gamma')
                    % Stored, so return it
                    val = ip.render.gamma;
                else
                    % Not yet stored.  See if we can get it from the
                    % app window
                    app = ieSessionGet('ip window');
                    if ~isempty(app) && isvalid(app)
                        val = str2double(app.editGamma.Value);
                    else
                        % Nowhere to be found.  Treat it as 1.
                        val = 1;
                    end
                    % Whatever we decided, store it now.
                    ip.render.gamma = val;
                end
            case {'renderwhitept'}
                % Logical.  If true, forces the sensor conversion matrix to
                % convert the scene illuminant to [1 1 1].
                % Used in imageSensorCorrection.
                val = ip.render.whitept;

                % Image processor data
            case {'data','datastructure'}
                val = ip.data;
            case {'roidata','dataroi','roiresult'}
                % h = ipWindow;
                % roiLocs = vcROISelect(ip,h);
                % ipGet(ip,'roiData',roiLocs);
                if ~isempty(varargin)
                    roiLocs = varargin{1};
                    val = vcGetROIData(ip,roiLocs,'result');
                end
            case {'roixyz','xyzroi'}
                % ipGet(ip,'roixyz',roiLocs)
                if ~isempty(varargin)
                    roiLocs = varargin{1};
                    val = imageDataXYZ(ip,roiLocs);
                else
                    val = imageDataXYZ(ip);
                end
                
                % Sensor information.
            case {'sensorinput','sensormosaic','input'}
                % ipGet(ip,'sensor input')
                % The sensor mosaic data.  row x col
                % Not sure why a 1 is returned when no data.
                if checkfields(ip,'data','input'), val = ip.data.input;
                else,                              val = 1;
                end
            case {'quantization'}
                if checkfields(ip,'data','quantization')
                    val = ip.data.quantization;
                end
            case {'quantizationmethod'}
                if checkfields(ip,'data','quantization','method')
                    val = ip.data.quantization.method;
                end
            case {'quantizationnbits','nbits','bits'}
                if checkfields(ip,'data','quantization','bits')
                    val = ip.data.quantization.bits;
                end
            case {'maxdigitalvalue'}
                % ipGet(ip,'max digital value')
                %
                % Either the max digital value or 1 if there is no
                % representation of the nbits.
                nbits = ipGet(ip,'nbits');
                if isempty(nbits), val = 1;
                    return
                else, val = 2^nbits;
                end
                
            case {'ninputfilters','numbersensorchannels','nsensorinputs'}
                if checkfields(ip,'data','sensorspace')
                    val = size(ip.data.sensorspace,3);
                end
                
            case {'datasensor','sensordata','sensorchannels','sensorspace','demosaicsensor'}
                % ipGet(ip,'sensor data')
                %
                % The demosaicked sensor (device) values
                % This has dimension row,col,nChannel
                if checkfields(ip,'data','sensorspace')
                    val = ip.data.sensorspace;
                end                 
                
                % Result and display are mixed up together here.
                % We should decide which to use
            case {'lineardisplayrgb','datadisplay','result','results'}
                % ipGet(ip,'linear display rgb')
                %
                % Deleted aliases:
                %   'dataresult','quantizedresult',
                %   'dataintensities','rgbintensities'
                %
                % The values are the linear intensities of the ip display
                % primaries that show the illuminant corrected ICS data.
                % The primary linear intensities are values between 0 and 1
                % (off to maximum intensity).  They may have been
                % quantized, but in that range.
                %
                % We use imageShowImage to convert these data into an
                % sRGB image that the user is shown on their screen in
                % the ipWindow.
                % 
                if checkfields(ip,'data','result')
                    val = ip.data.result; 
                end

            case {'dataics'}
                % ipGet(ip,'data ics')
                % 
                % The image processor has an internal color space.
                % Often, but not always, XYZ.  The sensor data are
                % transformed into this space, corrected for the
                % illumination, and then transformed to the display
                % primary intensities by the mapping in
                % ieInternal2Display.
                val = ipGet(ip,'sensor space');
                T   = ipGet(ip,'sensor conversion matrix');
                val = imageLinearTransform(val,T);

            case {'dataicsilluminantcorrected'}
                % img = ipGet(ip,'data ics illuminant corrected');
                %
                % Data in the ICS space, after illuminant correction.
                %
                val = ipGet(ip,'dataics');
                T   = ipGet(ip,'illuminant correction matrix');
                val = imageLinearTransform(val,T);

            case {'dataxyz'}
                % ipGet(ip,'display data xyz');
                %
                % The display data into XYZ values, accounting for the
                % display primaries.                
                val = imageDataXYZ(ip);
            case {'dataluminance'}
                % ipGet(ip,'data luminance');
                % The Y value from the CIE XYZ
                val = imageDataXYZ(ip);
                val = val(:,:,2);
            case {'datasrgb','srgb'}
                % ipGet(ip,'data srgb');
                %
                % The display data in 'result' are transformed into
                % XYZ and then sRGB for display.  
                %
                %    val = imageDataXYZ(ip);
                %    val = xyz2srgb(val);
                %
                % The returned image applies the gamma value from the
                % ip window, if the window is open.
                val = imageShowImage(ip,[],[],0);
                
            case {'dataintensitiesscaled','scaledresult','resultscaledtomax','resultscaled'}
                % srgb = ipGet(ip,'scaled result')
                %
                % Get the srgb image, scaled to max of 1, from the ip
                % result data.
                ip = ipSet(ip,'scale display output',true);
                val = imageShowImage(ip,[],[],0);

            case {'dataintensity','resultprimary','resultprimaryn'}
                % A single display channel
                % redPrimary = ipGet(ip,resultprimary,1);
                %
                % p4 = ipGet(ip,resultprimary,4);
                if isscalar(varargin), n = varargin{1};
                else, errordlg('You must specify a primary number.')
                end
                if size(ip.data.result,3) >= n
                    val = ip.data.result(:,:,n);
                else, error('No such display primary.');
                end
            case {'dataintensitiesmax','resultmax'}
                if checkfields(ip,'data','result'), val = max(ip.data.result(:)); end
            case {'dataintensitiesdv','dataintensitiesdigitalvalues'}
                % Digital value of the display intensities
                val = ipGet(ip,'data intensities');
                nbits = ipGet(ip,'nbits');
                val = val*(2^nbits);
            case {'maxsensor','maximumsensorvalue','maximumsensorvoltageswing'}
                if checkfields(ip,'data','max'), val = ip.data.max;
                else
                    sData = ipGet(ip,'input');
                    val = max(sData(:));
                end
            case {'whitepoint','wp','datawhitepoint','datawp','imagewhitepoint','imagewp'}
                % Data white point.
                % We used to return the monitor white point here.  This
                % change broke a lot of CIELAB calculations.  But it is right to
                % fix them.
                if checkfields(ip,'data','wp'), val = ip.data.wp;  end
            case {'dataordisplaywhitepoint','dataormonitorwhitepoint'}
                val = ipGet(ip,'data white point');
                if isempty(val), val = ipGet(ip,'display white point'); end
                
                % Chart related
            case {'chartparameters'}
                % Struct of chart parameters
                if checkfields(ip,'chartP'), val = ip.chartP; end
            case {'cornerpoints','chartcornerpoints'}
                % fourPoints = oiGet(scene,'chart corner points');
                if checkfields(ip,'chartP','cornerPoints'), val = ip.chartP.cornerPoints; end
            case {'chartrects','chartrectangles'}
                % rects = ipGet(sensor,'chart rectangles');
                if checkfields(ip,'chartP','rects'), val = ip.chartP.rects; end
            case {'currentrect'}
                % [colMin rowMin width height]
                % Used for ROI display and management.
                if checkfields(ip,'chartP','currentRect'), val = ip.chartP.currentRect; end
                
            case {'imagecenter','center'}
                % row,col at the image center.  We do it this way because there is
                % some ambiguity about the center calculation and the way to
                % calculate the distance from the center
                sz = ipGet(ip,'size');
                if isempty(sz), return; end
                val = (sz(1:2)+1)/2;
            case {'distance2center'}
                % Distance from the image center in units of pixels
                % val = ipGet(ip,'distance2center'); figure; surf(val)
                G =  ipGet(ip,'imageGrid');
                if isempty(G), return; end
                val = sqrt(G{1}.^2 + G{2}.^2);
                
            case {'angle'}
                % Angle with respect to image center
                % val = ipGet(ip,'angle'); figure; surf(val)
                G =  ipGet(ip,'imageGrid');
                if isempty(G), return; end
                val = atan2(G{2},G{1});
                
            case {'imagegrid'}
                % Returns a cellarray of X,Y coordinates
                % val = ipGet(ip,'imageGrid');
                sz = ipGet(ip,'size');
                if isempty(sz), return; end
                center = ipGet(ip,'center');
                [X,Y] = meshgrid(1:sz(2),1:sz(1));
                val{1} = X - center(2);
                val{2} = Y - center(1);
                
                % Special computational needs
            case {'combineexposures','combinationmethod'}
                % Method for combining multiple exposures in bracketed case
                % Implemented:
                %   longest - Longest not saturated
                %   Others to come, I hope
                if checkfields(ip,'combinationMethod'), val = ip.combineExposures;
                else, val = 'longest';
                end
                
            case {'l3'}
                % Should never get here (see top)
                warning('l3 get fell through to otherwise condition in ipGet')
                val = ip.L3;
                
            otherwise
                error('Unknown parameter: %s\n',param);
        end
end

end