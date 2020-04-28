function vci = ipSet(vci,param,val,varargin)
%Set image processor parameters and transforms.
%
%       ip = ipSet(ip,param,val,varargin)
%
% Image processing (ip) structure describes parameters and methods used in
% the image processing pipeline.  The structure also includes information
% about the target display.  This structure is also called the virtual
% camera image (vci) for many years.  (I am trying to switch over from vci
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
%   {'name'}                  - Unique name for this processor
%   {'type'}                  - Always 'vcimage'
%
% Processing pipeline options
%      {'demosaic'}              - The demosiac structure
%      {'demosaic method'}       - Name of the demosaic method (function)
%         Currently supported are listed in Demosaic
%         'bilinear','adaptive laplacian','laplacian','nearest neighbor'
%
%  Computational approach
%      {'transform method'} - 
%         'current'  - Use the current transform. 
%         'new'      - Enter a new matrix manually. 
%         'adaptive' - Use the image processing algorithms for sensor and
%                      illuminant corrections to determine the matrix on
%                      this image  
%
%  Correction of the sensor data to a standard space
%      {'conversion sensor '}        - Sensor conversion structure
%      {'conversion method sensor'}  - Name of the method
%         Options: 'none', 'manual matrix entry', 
%                  'mcc optimized', 'esser optimized', 'multisurface'
%      {'conversion matrix sensor'}  - The sensor conversion matrix
%
%  Calibrated color space (sensor spectral QE is allowed).
%      {'internal colorspace'}      - Name of the internal color space
%          Options: 'sensor', 'XYZ', 'Stockman', 'linear srgb'
%      {'internal cs 2 display space'} - Transform from internal to display
%
%  Correction for the illuminant
%      {'correction illuminant'}               - Color balance structure
%      {'correction method illuminant'}        - Name of the method (function)
%        Currently supported
%          'none', 'gray world', 'white world', 'manual matrix entry'
%      {'correction matrix illuminant'}        - Color balance transform
%
%      {'spectrum'}           - Wavelength structure
%        {'wavelength'}
%
%      {'transforms'} - The sensor and illuminant correction transforms
%                       are stored in this cell array.  
%       (ip.transform{1}) - sensor conversion transform.  
%              The second is the illuminant correction
%              The third is the internal color to display
%
%  Display properties will be removed from this function in the future
%      {'display'}  - Target display structure
%      {'display viewing distance'} - Subject's distance in meters
%
%      {'data'}
%        {'sensor input'}        - Data from sensor
%        {'maximum sensor value'} - Largest possible sensor value
%        {'display output'}      - Data to be rendered on display
%        {'data white point'}     - If not the display, then this
%        {'scale display output'} - Scaled to display max RGB
%
%  Miscellaneous
%     {'mccRectHandles'}  - Handles for the rectangle selections in an MCC
%     {'mccCornerPoints'} - Outer corners of the MCC
%     {'roi'}             - Rect used for an ROI
%     {'gamma display'}   - Gamma for rendering data to ipWindow image
%     {'scale display'}   - True or false for scaling the ipWindow image
%
% Copyright ImagEval Consultants, LLC, 2005.

% Set display parameters to match the new ones in ipGet

if ~exist('vci','var') || isempty(vci),  error('VCI parameter required'); end
if ~exist('param','var') || isempty(param), error('param required'); end

param = ieParamFormat(param);

switch param
    case 'type'
        vci.type = val;
    case 'name'
        vci.name = val;
    case {'spectrum'}
        vci.spectrum = val;
    case {'wave','wavelength'}
        vci.spectrum.wave = val;
        
                
    % This is a calibrated color space we use for calculating.
    % Most of the spaces are international standards though we allow the
    % known sensor spectral QE to be considered calibrated, too.
    case {'internalcs','internalcolorspace'}
        % Color spaced used for calculations such as color balancing.
        % see ieColorTransform or header of this document for options.
        vci.internalCS = val;
    case {'ics2display','ics2displaytransform','internalcs2displayspace'}
        % vci = imageSet(vci,'ics2display',val,3);
        % Internal color space to display primaries
        vci.data.transforms{3} = val;
        
    case {'demosaicstructure','demosaic'}
        vci.demosaic = val;
    case {'demosaicmethod'}
        if isempty(val), val = 'None'; end
        vci.demosaic.method = val;
        
    % Accounting for the difference between the sensors and the internal
    % color space linear span.
    case {'sensorconversion','conversionsensor'}
        vci.sensorCorrection = val;
    case {'sensorconversionmethod','conversionmethodsensor'}
        % Options (10/26/2009):
        %  'manual matrix entry', 'mcc optimized', 
        %  'esser optimized', 'multisurface', 'none'
        if isempty(val), val = 'None'; end
        vci.sensorCorrection.method = val;
    case {'sensorconversionmatrix','conversiontransformsensor','conversionmatrixsensor'}
        % Equivalent to
        % vci = imageSet(vci,'colorconversiontransform',val,1);
        vci.data.transforms{1} = val;
        
    % Accounting for acquisition illuminant.  This will become much more
    % complex over time.
    case {'illuminantcorrection','correctionilluminant'}
        vci.illuminantCorrection = val;
    case {'illuminantcorrectionmethod','correctionmethodilluminant'}
        % Possible illuminant correction methods:
        %  'manual matrix entry', 
        %  'grayWorld'
        %  'WhiteWorld'
        %  'None'
        if isempty(val), val = 'None'; end
        vci.illuminantCorrection.method = val;
        
    case {'correctionmatrixilluminant','illuminantcorrectionmatrix','correctiontransformilluminant','illuminantcorrectiontransform'}
        % vci = imageSet(vci,'whitebalancetransform',val,2);
        vci.data.transforms{2} = val;

        % Display properties are managed via displayGet/Set. 
    case {'display','displaystructure'}
        vci.display = val;
    case {'displayviewingdistance'}
        % Subject viewing distance in meters, typically 0.5 meters 
        d = ipGet(vci,'display');
        d = displaySet(d,'viewing distance',val);
        vci = ipSet(vci,'display',d);       
    case {'displaydpi'}
        % Pixel density (dots per inch)
        d   = ipGet(vci,'display');
        d   = displaySet(d,'dpi',val);
        vci = ipSet(vci,'display',d);
        
        % Image data, inputs and outputs
    case {'data','datastructure'}
        vci.data = val;
    case {'input','sensorinput'}
        % A copy of the sensor data is stored here
        vci.data.input = val;
    case {'result','displayrgb','displayoutput'}
        % The image processed data 
        vci.data.result = val;
    case {'datawhitepoint','datawp'}
        % Hmm.  Probably used for rendering.
        vci.data.wp = val;
        
    case {'sensorspace'}
        % What is this?  Comment, please.  Should probably go away.
        vci.data.sensorspace = val;
 
    case {'transforms'}
        % vci = ipSet(vci,'transforms',eye(3),2);
        % vci = ipSet(vci,'transforms',cellArrayOfTransforms);
        if ~isempty(varargin)
            n = varargin{1};
            vci.data.transforms{n} = val;
        else
            vci.data.transforms = val;
        end
    case {'transformmethod'}
        % vci = ipSet(vci,'transform method','Adaptive')
        % Other options are 'New' and 'Current'
        vci.transformMethod = val;
        
    case {'datamax','rgbmax','sensormax','maximumsensorvalue','maximumsensorvoltageswing'}
        % This should probably account for the type of exposure condition.
        % I am not sure it is always set properly (i.e., accounting for
        % bracketing)
        vci.data.max=val;
        
        % Manage image rendering
    case {'render','renderstructure'}  % This is the entire render structure.
        vci.render = val;
    case {'rendermethod','renderingmethod','customrendermethod'}
        vci.render.method = val;
    case {'scaledisplay','scaledisplayoutput'}
        % This is a binary 1 or 0 for one or off
        vci.render.scale = val;
    case {'gammadisplay','rendergamma','gamma'}
        % Controls the gamma for rendering the result data to the
        % GUI display.
        vci.render.gamma = val;
        hdl = ieSessionGet('ip handles');
        if ~isempty(hdl)
            set(hdl.editGamma,'string',num2str(val));
            ipWindow;
        end
    % Consistency (red button)
    case {'consistency','computationalconsistency','parameterconsistency'}
        vci.consistency = val;
    
    % Special case for ROIs and macbeth color checker.  This should get
    % generalized to chart and chart parameter calls.  Too special now for
    % MCC case.  See related comments in sensorSet.
    case {'mccrecthandles'}
        % These are handles to the squares on the MCC selection regions
        % see macbethSelect
        if checkfields(vci,'mccRectHandles')
            if ~isempty(vci.mccRectHandles)
                try delete(vci.mccRectHandles(:));
                catch
                end
            end
        end
        vci.mccRectHandles = val;
    case {'cornerpoints','mccpointlocs','mcccornerpoints'}
        % Corner points for the whole chart.  These have been MCC charts,
        % but we should update to a chartP struct and have these be
        % chartP.cornerPoints.
        vci.mccCornerPoints=  val;

    % Slot for holding a current retangular region of interest    
    case {'roi','currentrect'}
        % [colMin rowMin width height]
        % Used for ROI display and management.
        vci.currentRect = val;

    % Needs more comments and development    
    case {'combineexposures','combinationmethod'}
        % Method for combining multiple exposures in bracketed case
        % Implemented:
        %   longest - Longest not saturated
        %   Others to come, I hope
        vci.combineExposures = val;
        
    % Special case for L3 work with unconventional CFAs
    case {'l3'}
        % L^3 (local linear learned) method
        % This should contain all values needed for processing.  None of
        % the other vci fields should be set except type should be 'L3'.
        vci.L3 = val;
        
    otherwise
        error('Unknown ip parameter %s',param);
end

end
