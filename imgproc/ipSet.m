function ip = ipSet(ip,param,val,varargin)
%Set image processor parameters and transforms.
%
% Synopsis
%  ip = ipSet(ip,param,val,varargin)
%
% Image processing (ip) structure describes parameters and methods used in
% the image processing pipeline.  The structure also includes information
% about the target display.  
%
% Inputs
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
%  Correction for the illuminant
%      'correction illuminant'               - Color balance structure
%      'correction method illuminant'        - Name of the method (function)
%        Currently supported
%            'none', 'gray world', 'white world', 'manual matrix entry'
%
%      'correction matrix illuminant'        - Color balance transform
%
%  Calibrated color space (sensor spectral QE is allowed).
%      'internal colorspace'      - Name of the internal color space
%            Options: 'sensor', 'XYZ', 'Stockman', 'linear srgb'
%      'internal cs 2 display space' - Transform from internal to display
%
%      'spectrum'           - Wavelength structure
%        'wavelength'
%
%      'transforms' - The sensor and illuminant correction transforms
%                       are stored in this cell array.
%       (ip.data.transform{1}) - The sensor conversion transform.
%       (ip.data.transform{2}) - The second is the illuminant correction
%       (ip.data.transform{3}) - The third is the internal color to display
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
% Description
%
% The image processing methods in the default ISET pipeline are (a)
% demosaicking, (b) conversion from sensor space to the internal color
% space, (c) illuminant correction, and (d) conversion from the
% internal space to the display primaries.
%
% The parameters specify the methods for performing, say, sensor
% correction or illuminant correction. The transform parameters are
% the matrix transformations applied in these cases.
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
% This structure was  called the virtual camera image (vci) for many
% years.  (I am trying to switch over from ip naming to ip naming.)
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
        % ip = ipSet(ip,'ics2display',val,3);
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
        % ip = ipSet(ip,'colorconversiontransform',val,1);
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
        % ip = ipSet(ip,'whitebalancetransform',val,2);
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
    case {'result','displaylinearrgb'}
        % ipSet(ip,'result',val)
        %        
        % The ip has a display model. The parameter val contains the
        % primary intensities (linear) for the display, computed with
        % ipCompute.  If the display is RGB, these are the linear
        % primary intensities for the RGB display.
        %
        % ipGet uses ip to calculate the xyz and srgb images from
        % these values.
        %
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
    case {'nbits','quantizationnbits'}
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
    case {'renderflag','displaymode'}
        % ipSet(ip,'display mode','hdr');
        % Also refreshes the app when it is present.
        switch ieParamFormat(val)
            case {'rgb',1}
                val = 1;
            case {'hdr',2}
                val = 2;
            case {'gray',3}
                val = 3;
            otherwise
                fprintf('Permissible display modes: rgb, hdr, gray\n');
        end
        ip.render.renderflag = val;
        app = ieSessionGet('ip window');
        if isvalid(app)
            app.popupRender.Value = app.popupRender.Items{val};
            app.refresh(ip);
        end

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
            ip = ipSet(ip, 'transform method', 'current');
            ip = ipSet(ip,'ics2display transform', eye(3));
        end
        
    case {'renderscale','scaledisplay','scaledisplayoutput'}
        % This is a binary 1 or 0 for one or off
        ip.render.scale = val;
    case {'renderwhitept'}
        % ip = ipSet(ip,'whitept',[lightspectra],[sensorqe]);
        %
        % Force the sensor conversion matrix to map the scene
        % illuminant to [1 1 1] in the target space. 
        % 
        % This is run as a post-processing step. If you do not like
        % the default adaptive rendering, you can run this and have an
        % impact. It was particularly useful for RGBW in ISETAuto
        % calculations.  
        
        % Need to check parameters.
        ill = val;
        assert(isnumeric(val));
        if isstruct(varargin{1}) && isequal(varargin{1}.type,'sensor')
            sensorQE = sensorGet(varargin{1},'spectral qe');
        elseif isnumeric(varargin{1})
            sensorQE = varargin{1};
        else
            error('Bad sensor data');
        end

        % How the sensor responds to the illuminant
        sensorLight = ill(:)'*sensorQE;
        sensorLight = sensorLight / max(sensorLight);

        % Modify the conversion matrix to make the response all 1s for
        % this light.
        T = ipGet(ip,'sensor conversion matrix');
        sensorWhite = sensorLight*T;
        T = T * diag( 1 ./ sensorWhite);
        ip = ipSet(ip,'sensor conversion matrix',T);

        % Fix the transform so the next time ipCompute is run it will
        % use this modified transform.
        ip = ipSet(ip, 'transform method', 'current');
        disp('Fixing the transform method.')
        
    case {'gammadisplay','rendergamma','gamma'}
        % Controls the gamma for rendering the result data to the
        % GUI display.
        ip.render.gamma = val;
        ieReplaceObject(ip);
        % If the window is open and valid, set the edit box and refresh it.
        app = ieSessionGet('ip window');
        if ~isempty(app) && isvalid(app)
            app.refresh;
        end
        
        % Chart
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
        % Method for combining multiple exposures in bracketed or burst case
        % Implemented:
        %   longest - Longest not saturated
        %   sum -- for burst, just add values
        %   Others to come, I hope
        ip.combineExposures = val;
        ip.combinationMethod = val; % this is what the Get routine wants!
        
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
