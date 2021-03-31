function ip = ipSet(ip,param,val,varargin)
%Set image processor parameters and transforms.
%
%       ip = ipSet(ip,param,val,varargin)
%
% Image processing (ip) structure describes parameters and methods used in
% the image processing pipeline.  The structure also includes information
% about the target display.  This structure is also called the virtual
% camera image (ip) for many years.  (I am trying to switch over from ip
% naming to ip naming.)
%
% The image processing methods in the default ISET pipeline are (a)
% demosaicking, (b) conversion from sensor space to the internal color
% space, (c) illuminant correction, and (d) conversion from the internal
% space to the display primaries.
%
% The method parameters speicfy the methods for performing, say, sensor
% correction or illuminant correction. The transform parameters are the
% matrix transformations applied in these cases.
%
% The display is a structure that is represented within the processing
% pipeline.   We are in the process of developing an extensive display
% simulation technology. The display object has its own create/set/get
% calls (i.e., displayGet).  Still, many of the parameters can be retrieved
% from this structure as well (see below).
%
% We expect that many people will want to write their own processing
% pipeline.  The methods included here are illustrative of current
% practice, we do not think of them as optimal.
%
% Image Processor parameters
%   'name'                  - Unique name for this processor
%   'type'                  - Always 'vcimage'
%
% Processing pipeline options
%    'demosaic'         - The demosiac structure
%    'demosaic method'  - Name of the demosaic method (function)
%         Currently supported are listed in Demosaic
%         'bilinear','adaptive laplacian','laplacian','nearest neighbor'
%
%  Computational approach
%    'transform method' - 
%       'current'  - Use the current transform. 
%       'new'      - Enter a new matrix manually. 
%       'adaptive' - Use the image processing algorithms for sensor and
%                      illuminant corrections to determine the matrix on
%                      this image  
%       'render demosaic only' - Sets the ip so only demosaicing and
%                                sensor zerolevel subtraction are included.
%
%  Correction of the sensor data to a standard space
%     'conversion sensor '        - Sensor conversion structure
%     'conversion method sensor'  - Name of the method
%         Options: 'none', 'manual matrix entry', 
%                  'mcc optimized', 'esser optimized', 'multisurface'
%     'conversion matrix sensor'  - The sensor conversion matrix
%
%  Calibrated color space (sensor spectral QE is allowed).
%      'internal colorspace'      - Name of the internal color space
%            Options: 'sensor', 'XYZ', 'Stockman', 'linear srgb'
%      'internal cs 2 display space' - Transform from internal to display
%
%  Correction for the illuminant
%      'correction illuminant'               - Color balance structure
%      'correction method illuminant'        - Name of the method (function)
%        Currently supported
%            'none', 'gray world', 'white world', 'manual matrix entry'
%      'correction matrix illuminant'        - Color balance transform
%
%      'spectrum'           - Wavelength structure
%        'wavelength'
%
%      'transforms' - The sensor and illuminant correction transforms
%                       are stored in this cell array.  
%       (ip.transform{1}) - sensor conversion transform.  
%              The second is the illuminant correction
%              The third is the internal color to display
%
%  Display properties will be removed from this function in the future
%      'display'  - Target display structure
%      'display viewing distance' - Subject's distance in meters
%
%      'data'
%        'sensor input'        - Data from sensor
%        'maximum sensor value' - Largest possible sensor value
%        'display output'      - Data to be rendered on display
%        'data white point'     - If not the display, then this
%        'scale display output' - Scaled to display max RGB
%
%  Miscellaneous
%     'render demosaic only' - Skip everything but demosaicing
%     'chart corner points'  - Outer corners of the chart, such as MCC
%     'roi'             - Rect used for an ROI
%     'gamma display'   - Gamma for rendering data to ipWindow image
%     'scale display'   - True or false for scaling the ipWindow image
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ipGet

% Set display parameters to match the new ones in ipGet

if ~exist('ip','var') || isempty(ip),  error('ip parameter required'); end
if ~exist('param','var') || isempty(param), error('param required'); end

param = ieParamFormat(param);

switch param
    case 'type'
        ip.type = val;
    case 'name'
        ip.name = val;
    case {'spectrum'}
        ip.spectrum = val;
    case {'wave','wavelength'}
        ip.spectrum.wave = val;
        
                
    % This is a calibrated color space we use for calculating.
    % Most of the spaces are international standards though we allow the
    % known sensor spectral QE to be considered calibrated, too.
    case {'internalcs','internalcolorspace'}
        % Color spaced used for calculations such as color balancing.
        % see ieColorTransform or header of this document for options.
        ip.internalCS = val;
    case {'ics2display','ics2displaytransform','internalcs2displayspace'}
        % ip = imageSet(ip,'ics2display',val,3);
        % Internal color space to display primaries
        ip.data.transforms{3} = val;
        
    case {'demosaicstructure','demosaic'}
        ip.demosaic = val;
    case {'demosaicmethod'}
        if isempty(val), val = 'none'; end
        ip.demosaic.method = lower(val);
        
    % Accounting for the difference between the sensors and the internal
    % color space linear span.
    case {'sensorconversion','conversionsensor'}
        ip.sensorCorrection = val;
    case {'sensorconversionmethod','conversionmethodsensor'}
        % Options (10/26/2009):
        %  'manual matrix entry', 'mcc optimized', 
        %  'esser optimized', 'multisurface', 'none'
        if isempty(val), val = 'None'; end
        ip.sensorCorrection.method = val;
    case {'sensorconversionmatrix','conversiontransformsensor','conversionmatrixsensor'}
        % Equivalent to
        % ip = imageSet(ip,'colorconversiontransform',val,1);
        ip.data.transforms{1} = val;
        
    % Accounting for acquisition illuminant.  This will become much more
    % complex over time.
    case {'illuminantcorrection','correctionilluminant'}
        ip.illuminantCorrection = val;
    case {'illuminantcorrectionmethod','correctionmethodilluminant'}
        % We need the list of methods here!
        %
        if isempty(val), val = 'none'; end
        ip.illuminantCorrection.method = lower(val);
        
    case {'correctionmatrixilluminant','illuminantcorrectionmatrix','correctiontransformilluminant','illuminantcorrectiontransform'}
        % ip = imageSet(ip,'whitebalancetransform',val,2);
        ip.data.transforms{2} = val;

        % Display properties are managed via displayGet/Set. 
    case {'display','displaystructure'}
        ip.display = val;
    case {'displayviewingdistance'}
        % Subject viewing distance in meters, typically 0.5 meters 
        d = ipGet(ip,'display');
        d = displaySet(d,'viewing distance',val);
        ip = ipSet(ip,'display',d);       
    case {'displaydpi'}
        % Pixel density (dots per inch)
        d   = ipGet(ip,'display');
        d   = displaySet(d,'dpi',val);
        ip = ipSet(ip,'display',d);
        
        % Image data, inputs and outputs
    case {'data','datastructure'}
        ip.data = val;
    case {'input','sensorinput'}
        % A copy of the sensor data is stored here
        ip.data.input = val;
    case {'result','displayrgb','displayoutput'}
        % The image processed data 
        ip.data.result = val;
    case {'datawhitepoint','datawp'}
        % Hmm.  Probably used for rendering.
        ip.data.wp = val;
        
    case {'sensorspace'}
        % What is this?  Comment, please.  Should probably go away.
        ip.data.sensorspace = val;
    case {'quantization'}
        % Struct of quantization parameters.  Copied from sensor.  
        %
        % The quantization struct might be used to determine if the
        % input data were really digital values.  Not much used yet.
        ip.data.quantization = val;
    case {'nbits'}
        % ip = ipSet(ip,'nbits',val);
        %
        % Bit depth of the image representations
        ip.data.quantization.bits = val;
        
    case {'transforms'}
        % ip = ipSet(ip,'transforms',eye(3),2);
        % ip = ipSet(ip,'transforms',cellArrayOfTransforms);
        if ~isempty(varargin)
            n = varargin{1};
            ip.data.transforms{n} = val;
        else
            ip.data.transforms = val;
        end
    case {'transformmethod'}
        % ip = ipSet(ip,'transform method','Adaptive')
        % Other options are 'New' and 'Current'
        %
        % We need the list here!
        ip.transformMethod = lower(val);
        
    case {'datamax','rgbmax','sensormax','maximumsensorvalue','maximumsensorvoltageswing'}
        % This should probably account for the type of exposure condition.
        % I am not sure it is always set properly (i.e., accounting for
        % bracketing)
        ip.data.max=val;
        
        % Manage image rendering
    case {'render','renderstructure'}  % This is the entire render structure.
        ip.render = val;
    case {'rendermethod','renderingmethod','customrendermethod'}
        ip.render.method = val;
    case {'renderdemosaiconly'}
        % ipSet(ip,'render demosaic only',true)
        %
        % Set to true if you want to make sure only demosaicking and
        % zerolevel correction are used, but not sensor conversion or
        % illuminant correction.
        if val
            ip = ipSet(ip,'internal cs','Sensor');
            ip = ipSet(ip,'conversion method sensor','None');
            ip = ipSet(ip,'correction method illuminant','None');
        end
        
    case {'scaledisplay','scaledisplayoutput'}
        % This is a binary 1 or 0 for one or off
        ip.render.scale = val;
    case {'gammadisplay','rendergamma','gamma'}
        % Controls the gamma for rendering the result data to the
        % GUI display.
        ip.render.gamma = val;
        
        % If the window is open and valid, set the edit box and refresh it.
        app = ieSessionGet('ip window');
        if ~isempty(app) && isvalid(app)
            app.refresh;
        end
        
    % Consistency (red button)
    %{
    case {'consistency','computationalconsistency','parameterconsistency'}
        ip.consistency = val;
    %}
    % Special case for ROIs and macbeth color checker.  This should get
    % generalized to chart and chart parameter calls.  Too special now for
    % MCC case.  See related comments in sensorSet.
    %{
      case {'mccrecthandles'}
        % These are handles to the squares on the MCC selection regions
        % see macbethSelect
        if checkfields(ip,'mccRectHandles')
            if ~isempty(ip.mccRectHandles)
                try delete(ip.mccRectHandles(:));
                catch
                end
            end
        end
        ip.mccRectHandles = val;
    %}
    %{
    case {'mccpointlocs','mcccornerpoints'}
        % Corner points for the whole chart.  These have been MCC charts,
        % but we should update to a chartP struct and have these be
        % chartP.cornerPoints.
        warning('use chart corner points')
        ip.mccCornerPoints=  val;
    %}    
    case {'chartparameters'}
        % Reflectance chart parameters are stored here.
        ip.chartP = val;
    case {'cornerpoints','chartcornerpoints'}
        ip.chartP.cornerPoints=  val;
    case {'chartrects','chartrectangles'}
        ip.chartP.rects =  val;
        % Slot for holding a current retangular region of interest
    case {'currentrect'}
        % [colMin rowMin width height]
        % Used for ROI display and management.
        ip.chartP.currentRect = val;

    % Needs more comments and development    
    case {'combineexposures','combinationmethod'}
        % Method for combining multiple exposures in bracketed case
        % Implemented:
        %   longest - Longest not saturated
        %   Others to come, I hope
        ip.combineExposures = val;
        
    % Special case for L3 work with unconventional CFAs
    case {'l3'}
        % L^3 (local linear learned) method
        % This should contain all values needed for processing.  None of
        % the other ip fields should be set except type should be 'L3'.
        ip.L3 = val;
        
    otherwise
        error('Unknown ip parameter %s',param);
end

end
