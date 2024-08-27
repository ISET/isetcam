function ip = ipCompute(ip,sensor,varargin)
% Image processing pipeline from image sensor to a display
%
% Synopsis
%    ip = ipCompute(ip,sensor,varargin);
%
% Brief description
%   The image processing pipeline (ip) converts  sensor data (sensor) into
%   a display image.
%
% Inputs:
%   ip:      The image processor struct
%   sensor:  The sensor struct
%
% Optional key/val:
%   hdr white:  Apply hdr bright light whitening at the end
%   hdr level:  The signal level for saturation (default: max data)
%   wgt blur:   How much to blur the hdr weight map (default: 2)
%   network demosaic:  Demosaic with a named neural network.  Options
%     now are only 'rgb' and 'rgbw', which were trained for the ar0123at
%     network.  We should change the names to plan for the future. The
%     user has to have the Python environment setup and the ONNX
%     demosaicking files on their path.  These are not part of the
%     usual ISETCam distribution.
%
% Output:
%   ip:      The ip now has the processed data stored in it
%
% Description
%  The sensor data (either the voltage or digital values) are
%  processed by a series of steps in ipCompute. A sequence of image
%  data are stored within the ip.data slot.
%
%   input:  the voltage (or digital values, dv) from the sensor object.
%   sensorspace:  The demosaicked input
%   result:       The processed data demosaic data in lrgb format
%                 (between 0 and 1), ready for conversion to srgb as
%                 part of the display
%
%  The main processing routine is ipComputeSingle, below. Single
%  refers to a single exposure.
%
%  If the sensor is monochrome, the pipeline copies the sensor data to the
%  display output as a monochrome image.
%
%  If the sensor has multiple color channels, the ip applies demosaic,
%  sensor color conversion to a 3D internal color space (ICS), and
%  illuminant correction (white balancing)
%
%  Which algorithms are applied is controlled by setting the
%  parameters of the ip (i.e., ipSet). The parameters control features
%  like the demosaicking method, the sensor conversion approach, and
%  the illuminant correction.
%
% Special cases
%
%    'network demosaic' - 
%    We have a means of incorporating a neural network for demosaicing (and
%    denoising).  This is used in the isethdrsensor repository. The method
%    is special cased for that (not general).  But it works well and we are
%    considering whether we build it up.  The basic idea is to train a
%    network, store it as an ONNX format, and then run it using the python
%    environment in Matlab. The ISETHDRSENSOR paper has examples and the
%    repository has code.
%
%    'hdr *'     
%    When processing high dynamic range scenes through the pipeline, there
%    will be fully saturated regions (i.e., pixels that are all at full
%    well capacity).  In that case it is inappropriate to use the same
%    image processing parameters to render the color. If you do, the fully
%    saturated pixels may show up as colored, rather than white.  The
%    parameters related to hdr call a routine (ipHDRWhite) that forces
%    fully saturated pixels to be rendered as white.  The algorithm takes
%    three parameters.
%       'hdr white' - logical that says use the method.
%       'hdr level' - scalar that defines when we start worrying about
%                   saturation.  
%       'wgt blur'  - blurring parameter that smooths out the region
%                     identified as saturated
%
% About L3
%   We will deprecate the L3 approach from here.  It will be handled
%   elsewhere.  We now are training networks rather than using the L3
%   methods.
%
%   Deprecated comments:
%
%    We are writing other rendering pipelines based on different
%    architectures in the future.  One special one is L3.
%
%    If the ip.name begins with 'L3' then the data are rendered using
%    the L3 render method. The option 'L3global' uses the global
%    parameters of the L3 structure.  In this case, we expect an L3
%    structure that was learned is attached to the ip. (More
%    documentation needed, sorry! BW)
%
% See also
%   ipWindow, ipPlot, ipGet/Set

%% Parse arguments
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('ip',@(x)(isstruct(x) && isequal(x.type,'vcimage')));
p.addRequired('sensor',@(x)(isstruct(x) && isequal(x.type,'sensor')))
p.addParameter('saturation',[],@isscalar);   % ipHDRWhite parameters
p.addParameter('hdrwhite',false,@islogical);
p.addParameter('hdrlevel',.95,@isscalar);
p.addParameter('wgtblur',1,@isscalar);
p.addParameter('networkdemosaic',[],@ischar);
p.parse(ip,sensor,varargin{:});

hdrWhite = p.Results.hdrwhite;
hdrLevel = p.Results.hdrlevel;
wgtBlur  = p.Results.wgtblur;
saturation = p.Results.saturation;

%% Handle sensor array case.  No special exposure cases are handled.

if length(sensor) > 1
    % Not sure about this whole subsection.  It isn't obvious we are
    % handling the sensor array case properly, or that we ever get
    % here.

    ip = ipSet(ip,'datamax',sensorGet(sensor(1),'max'));

    % The first processing step, Demosaic, will recognize sensor as
    % an array. It will pull the volts out of each of the
    % individual sensors.

    % Single exposure case.
    ip = ipComputeSingle(ip,sensor);
    return;
end

%% Process the sensor data.

% Store the sensor mosaic.  Either continuous or digital values.
[output, dataType] = sensorGet(sensor,'dv or volts');
ip = ipSet(ip,'input',double(output));

%  The max is either the max digital value or the voltage swing, depending
%  on whether we have computed DVs or Volts.  But this value is not
%  terribly important because we render into an RGB display in the unit
%  cube.
switch dataType
    case 'dv'
        ip = ipSet(ip,'datamax',sensorGet(sensor(1),'max digital value'));
    case 'volts'
        ip = ipSet(ip,'datamax',sensorGet(sensor(1),'max voltage'));
end

%% Pre-process multiple exposure cases

% Combine the exposure durations into a single planar array.  Then we
% process using the single exposure processing stream.
exposureMethod = sensorGet(sensor,'exposure method');
switch exposureMethod(1:3)
    case 'sin'  % singleExposure
        % Don't need to pre-process
    case 'bra'  % bracketedExposure
        % On return, the maximum sensible exposure time is set
        ip = ipComputeBracketed(ip,sensor);
    case 'cfa'  % cfaExposure
        ip = ipComputeCFA(ip,sensor);
    case 'bur'  % burst of images
        ip = ipComputeBurst(ip, sensor, 'hdr');
    otherwise
        error('Unknown exposure method %s\n',exposureMethod);
end

%% We introduce the L3 pipeline here, which is not really part of ISET.

% This will be deprecated in September, 2024.

% Perhaps we should test for the L3render function and warn the user if it
% does not exist on the path?
pType = ieParamFormat(ipGet(ip,'name'));
if ~strncmpi(pType,'l3',2)
    % Conventional pipeline of single exposure. Most common case. We
    % should probably remove the l3 case altogether.

    if ~isempty(p.Results.networkdemosaic)
        % 'rgb' or 'rgbw'
        ip = ipNetworkDemosaic(ip,sensor,p.Results.networkdemosaic);
    end

    ip = ipComputeSingle(ip,sensor);
else
    warning('L3 processing is deprecated.')
    return;
    %{
    % Special case that probably shouldn't be here
    % Perform L^3 processing, either local or global
    mode = 'local';
    if strncmpi(pType,'l3global',8), mode = 'global'; end
    fprintf('** Using L3render %s method **\n',mode);

    L3 = ipGet(ip,'L3');
    [L3xyz,lumIdx,satIdx,clusterIdx] = L3render(L3,sensor,mode);

    % Convert the results and save in the L3 structure and ip.
    % Shouldn't we be saving the srgb?  Or using xyz2lrgb?
    [srgb, lrgb] = xyz2srgb(L3xyz); %#ok<ASGLU>
    ip = ipSet(ip,'result',lrgb);

    L3  = L3Set(L3,'luminance index',lumIdx);
    L3  = L3Set(L3,'xyz result',L3xyz);
    L3  = L3Set(L3,'saturation index',satIdx);
    L3  = L3Set(L3,'cluster index',clusterIdx);
    ip = ipSet(ip,'L3',L3);
    %}
end

% Name the ip with its input sensor name
ip = ipSet(ip,'name',sensorGet(sensor,'name'));

%% If we are dealing with bright saturation case of HDR images?
if hdrWhite
    if isempty(saturation)
        switch dataType
            case 'volts'
                saturation = sensorGet(sensor,'max voltage');
            case 'dv'
                saturation = sensorGet(sensor,'max digital value');
        end
    end

    % Specifies all the key/val parameters.
    %
    % hdrLevel   - the fraction of the saturation level we start to act    
    % saturation - the saturation level
    % wgtBlur    - The blur size for the derived weight map.    
    ip = ipHDRWhite(ip,'hdr level', hdrLevel, 'saturation',saturation,'wgt blur',wgtBlur);
end

end

%%
function ip = ipComputeSingle(ip,sensor)
% Process image for single exposure case, or after pre-processing for
% bracketed and CFA cases.
%
%    ip = ipComputeSingle(ip,sensor)
%
% The processing steps through
%   1. Demosaicing
%   2. Sensor correction to ICS
%   3. Illuminant correction in ICS
%   4. Display rendering
%
% Steps 2-4 are often a linear transform. The transform is scaled so that
% the image output maximum matches the ratio of the maximum sensor data
% value to the saturation level of the sensor.
%

% We handle the case of different number of filters somewhat differently.
nFilters = sensorGet(sensor(1),'nfilters');
nSensors = length(sensor);

% We need to know about the quantization before we get to displayRender.
ip = ipSet(ip,'quantization',sensorGet(sensor,'quantization'));

if nFilters == 1 && nSensors == 1
    % If monochrome sensor, just copy the sensor values to the RGB values
    % of the display, but normalize between 0 and 1 based on the kind of
    % data.
    img = ip.data.input / sensorGet(sensor,'max');

    % No need to demosaic, but we put the scaled input into sensorspace
    ip = ipSet(ip,'sensor space',img);

    % The image data are RGB, even though the sensor is monochrome.
    ip = ipSet(ip,'result',repmat(img,[1,1,3]));
    ip = ipSet(ip,'sensor space',repmat(img,[1,1,3]));    % saveimg = img;
    return;

elseif nFilters == 2
    % For 2-color filter case, we only Demosaic, like the monochrome case
    % (above).
    %
    % The only computational path we have now is for the demosaic algorithm
    % 'analog rccc'.
    if ~isequal(ieParamFormat(ipGet(ip,'demosaic method')),ieParamFormat('analog rccc'))
        error('2D is only implemented for RCCC demosaic case');
    end

    img = Demosaic(ip,sensor);    % Returns a monochrome image
    ip = ipSet(ip,'result',repmat(img,[1,1,3]));
    ip = ipSet(ip,'sensor space',repmat(img,[1,1,3]));    % saveimg = img;
    return;

elseif nFilters >= 3 || nSensors > 1
    % Basic color processing pipeline. Single exposure case.

    % 0.  Some sensor designs expect the zero level (response to a black
    % scene) should be a positive value.  If we store that level in the
    % sensor structure, the IP should subtract the zero level prior to
    % processing.
    %
    % We do that here by adjusting the ip.data.input by the zero level
    % amount, making sure that we do not have any negative values
    % (maybe because of noise).  This lets us use the same code as
    % usual below.  See also zerolevel = sensorZerolevel(sensor);
    %
    zerolevel = sensorGet(sensor,'zero level');
    if zerolevel ~= 0 && ~isnan(zerolevel)
        ip.data.input = max( (ip.data.input - zerolevel) ,0);
    end

    %% Demosaic the sensor data in sensor space.

    % For the NN cases (e.g., rgbwrestormer) we already computed the
    % sensor space data. We can always add the string nodemosaic to
    % any method to skip the demosaic step.
    if ~isequal(ipGet(ip,'demosaic method'),'skip')
        % The data remain in the sensor channels and there is no scaling.
        if ndims(ip.data.input) == nFilters, img = ip.data.input;
        elseif ismatrix(ip.data.input),      img = Demosaic(ip,sensor);
        else
            error('Not sure about input data structure');
        end

        % Save the demosaiced sensor space channel values. May be used later
        % for adaptation of color balance for IR enabled sensors.
        ip = ipSet(ip,'sensor space',img);    % saveimg = img;
    else
        % Make sure we have the demosaicked data from the restormer
        img = ipGet(ip,'sensor space');
        assert(~isempty(img));
    end


    %% Sensor and illuminant correction

    % Convert the demosaicked sensor data into an internal color
    % space. The choice of the internal color space conversion is
    % governed by the field ipGet(ip,'Sensor Correction Method').
    % Then do an illuminant correction.

    % Decide on the approach. Two of the options specify the matrix.
    % The third option, 'adaptive', processes based on the data.
    tMethod = ieParamFormat(ipGet(ip,'transform method'));
    switch tMethod
        case 'current'
            % Use the stored transform matrices, don't recompute based
            % on the image (adaptive).
            T   = ipGet(ip,'prodT');

            % This is supposed to be the linear primary intensities
            % because it incorporates all three transforms.
            img = imageLinearTransform(img,T);

            % See comments in displayRender.
            % We scale the transformed data to a max of 1, but then
            % multiply by how filled up the sensor was.  So if the
            % sensor was only at half well capacity, we scale by half.
            img = (img/max(img(:)))*sensorGet(sensor,'response ratio');

            % We make sure everything is positive.
            img = max(img,0);

            % Quantize
            qm = sensorGet(sensor,'quantization method');
            switch qm
                case 'analog'
                    % do nothing
                case 'linear'
                    % The primary levels have been linearly quantized. At this
                    % point, they are represented between 0 and 1. We multiply
                    % them out to digital values.
                    nbits = ipGet(ip,'quantization nbits');
                    img = round(img*(2^nbits))/2^nbits;

                otherwise
                    error('Unknown quantization method %s\n',qm);
            end

        case {'new','manualmatrixentry'}
            % Allow the user to specify a matrix from the GUI. When
            % the complete linear transform is set this way, we cannot
            % parse it into several parts.  We put the whole linear
            % transform into the slot for the sensor correction, and
            % that maps from the sensor to the display.

            Torig = ipGet(ip,'combined transform');
            Torig = Torig/max(Torig(:));
            T = ieReadMatrix(Torig,'%.3f   ','Color Transform');
            if isempty(T), return; end

            % Store and apply this transform.
            ip = ipSet(ip,'conversion matrix sensor',T);
            img = imageLinearTransform(img,T);  % vcNewGraphWin; imagesc(img)

            % See comments in displayRender.  This is the same set of
            % scaling operations as we perform there.
            img = (img/max(img(:)))*sensorGet(sensor,'response ratio');
            img = max(img,0);

            qm = sensorGet(sensor,'quantization method');
            switch qm
                case 'analog'
                    % do nothing
                case 'linear'
                    % The primary levels have been linearly quantized. At this
                    % point, they are represented between 0 and 1. We multiply
                    % them out to digital values.
                    nbits = ipGet(ip,'quantization nbits');
                    img = round(img*(2^nbits))/2^nbits;

                otherwise
                    error('Unknown quantization method %s\n',qm);
            end

            % Set the other transforms to empty.
            ip = ipSet(ip,'correction matrix illuminant',[]);
            % ip = ipSet(ip,'sensor correction transform',[]);
            ip = ipSet(ip,'ics2display',[]);
        case {'adaptive'}
            % Recompute a transform based on the image data and with
            % knowledge of the sensor color filters.

            N = length(sensor);
            if N > 1
                % If the sensor is an array of monochrome sensors, we
                % create a dummy version of the sensor,  that includes
                % all of the color filter channels. These are needed
                % for imageSensorCorrection and displayRender (below).
                %
                % Perhaps we should be checking that each one is
                % monochrome.
                s = sensor(1);
                filterSpectra = zeros(sensorGet(s,'n wave'),N);
                for ii=1:N
                    filterSpectra(:,ii) = sensorGet(sensor(ii),'filter spectra');
                end
                s = sensorSet(s,'filter spectra',filterSpectra);
            else
                s = sensor;
            end

            % Convert the sensor data to the internal color space
            [img,ip] = imageSensorCorrection(img,ip,s);
            if isempty(img), disp('User canceled'); return; end
            % imtool(img/max(img(:))); ii = 3; imtool(img(:,:,ii))

            %% Illuminant correction.

            % The 'illuminant correction method' transforms the data
            % within the ICS.
            [img,ip] = imageIlluminantCorrection(img,ip);

            %% Convert from the internal color space to linear display primaries

            % The data are scaled so that the largest value in display
            % space (0,1) is the same ratio as the peak sensor data
            % value to the maximum sensor output.
            %
            % N.B. The display on the user's desk is not likely to be the
            % calibrated display that is modeled.
            [img,ip] = displayRender(img,ip,s);
        case {'rgbwrestormer'}
            % In this case the demosaicked data are there and we have
            % set the transforms too.  So just apply the combined
            % transform.
            T = ipGet(ip,'transform combined');
            img = ipGet(ip,'sensor space');
            img = imageLinearTransform(img,T);            
            img = img/max(img(:))*sensorGet(sensor,'response ratio');
            img = ieClip(img,0,[]);

        case {'adaptivehdr'}
            % For the HDR case in which many pixels are saturated
            %
            % The idea is to first find the adaptive transformation.
        otherwise
            error('Unknown transform method %s\n',tMethod);
    end

    %% Save the linear primary data.
    %
    % These are always between 0 and 1, but they  might be quantized
    % within that range.
    ip = ipSet(ip,'display linear rgb',img);

end

end

%% ------------------------
function ip = ipComputeBracketed(ip,sensor,combinationMethod)
% Compute for bracketed exposure case
%
% sensor = vcGetObject('sensor');
% ip = vcGetObject('vcimage');
%
if ~exist('ip','var'), error('IP required.'); end
if ~exist('sensor','var'), error('Sensor required.'); end
if ~exist('combinationMethod','var')
    combinationMethod = ipGet(ip,'combinationMethod');
end

% Could send this parameter in.  It is the value we accept as below saturation
satPercentage = 0.95;
expTimes      = sensorGet(sensor,'expTimes');

% Get the data, either as volts or digital values.
% Indicate which on return
img       = ipGet(ip,'input');
% inputImg = img; % save for debugging

% We might have gotten either volts or dv.
% Despite comment above I don't think we know which? So...
if isfield(sensor.data,'dv') && ~isempty(sensor.data.dv)
    sensorMax = sensorGet(sensor,'max digital value');
else
    sensorMax = ipGet(ip,'maximum sensor value');
end
satMax    = satPercentage*sensorMax;

% Set values > saturatation value to -1 in the img array
%   so that we know to set them to sensor max later
% ISSUE: img input may be dv while satMax is in volts
%   if nbits (quantization) hasn't been set for the sensor
%   that means all values go to NaN!
workImage = img; % make a copy for debugging
workImage(workImage > satMax) = -1;

%% Estimate a sensor value accounting for all of the exposures
%
switch combinationMethod
    case 'longest'
        % Choose the max at each point
        %
        % NB: This wasn't originally designed for different size photosites
        %     So I think it needs help for the Corner Pixel case:(
        %
        [workImage,loc] = max(workImage,[],3);
        expByLoc  = expTimes(loc);
        workImage = workImage ./ expByLoc;

        % Put back saturated highlights
        workImage(workImage < 0) = sensorMax/min(expTimes);
        % Now we need to normalize our data back to a single sensor image value
        % this doesn't work well? ip = ipSet(ip,'sensorMax',sensorMax/min(expTimes));
        % this under-exposes in many cases
        %workImage = workImage * min(expTimes);
        %
        % so try to simply scale to fit:
        workImage = workImage * (satMax / max(workImage,[],'all'));

    case 'largest'
        % For the case where we want to "protect" darker areas,
        % Such as Auto HDR. Experiment with ignoring exposure times
        [workImage,loc] = max(workImage,[],3);

        % Put back saturated highlights
        % Don't divide by exposure in this case
        workImage(workImage < 0) = sensorMax;
        % For now simply scale to fit:
        workImage = workImage * (satMax / max(workImage,[],'all'));

    otherwise
        error('Unknown combination method: %s\n', combinationMethod)
end

ip = ipSet(ip,'input',workImage);

end

function ip = ipComputeCFA(ip,sensor)
% Compute for CFA exposure case
%
% In this case the img is N different CFA arrays, with each N corresponding
% to an exposure for one of the color filters.
% Our goal is to normalize the four CFA arrays by their exposure times, and
% then to pick out the relevant color terms from each of the exposures and
% merge them back into a single CFA.
%

if ~exist('ip','var'),     error('IP required.'); end
if ~exist('sensor','var'), error('Sensor array required.'); end

% Read the exposure times - same as number of filters
expTimes = sensorGet(sensor,'expTimes');
nExps    = length(expTimes(:));
% Get the data, either as volts or digital values.
% Indicate which on return
img       = ipGet(ip,'input');
sensorMax = ipGet(ip,'maximum sensor value');

% We are not sure how to handle the fact that channels can be saturated but
% with different exposure durations.  In that case, when we normalize by
% the exposure time, they may end up at different levels - even though in
% fact they were both saturated pxiels.
mx     = sensorMax/min(expTimes(:));

%% Normalize the values as if they had been captured at the same duration
%
cfaSize = size(sensorGet(sensor,'pattern'));
nRows   = sensorGet(sensor,'row');
nCols   = sensorGet(sensor,'col');

% We haven't dealt properly with saturation.  Must fix - MP

% Make one array that will hold CFA data after getting the color intensity
% values from appropriate exposure planes
newImg  = zeros(nRows,nCols);


for kk = 1:nExps

    % Note: The value for the kkth position in the CFA block (in
    % vectorized form) comes from the kkth exposure plane
    tmp = zeros(nRows,nCols);

    [ii,jj] = ind2sub(cfaSize,kk);
    rows = ii:cfaSize(1):nRows;
    cols = jj:cfaSize(2):nCols;

    tmp(rows,cols) = img(rows,cols,kk);

    % Check to see if any of these pixels are saturated
    satInd = (tmp > 0.99*sensorMax);

    % Normalize intensity values to get intensity/s
    tmp = tmp/expTimes(ii,jj);

    % Set saturated pixels to the maximum possible pixel value
    tmp(satInd) = mx;

    % Now replace the rows and columns corresponding to the current color
    % into identical positions in newImg
    newImg(rows,cols) = tmp(rows,cols);

end

% Update sensorMax with the largest value we can ever get
ip = ipSet(ip,'sensorMax',mx);
ip = ipSet(ip,'input',newImg);

end

function ip = ipComputeBurst(ip,sensor, combinationMethod)
% Compute for Burst exposure case

if ~exist('ip','var'), error('IP required.'); end
if ~exist('sensor','var'), error('Sensor required.'); end
if ~exist('combinationMethod','var')
    combinationMethod = ipGet(ip,'combinationMethod');
end

% Read the exposure times - same as number of filters
expTimes = sensorGet(sensor,'expTimes');
sensorMax = ipGet(ip,'maximum sensor value');

nExps    = length(expTimes(:));
% Get the data, either as volts or digital values.
% Indicate which on return
img       = ipGet(ip,'input');

switch combinationMethod
    case 'hdr'
        % Here we hope the images are aligned and try to
        % get the maximum dynamic range by combining the
        % exposures. This is of course too simple for cases
        % with motion.

        %burstMax = sensorMax * numel(expTimes);
        maxImg = sum(img,3);

        newImg = maxImg / numel(expTimes);
        ip = ipSet(ip, 'input', newImg);

    case 'sum'
        % simplest case where we just sum the burst of images
        img = sum(img, 3);
        ip = ipSet(ip, 'input', img);
    otherwise
        error("Don't know how to combine burst of images");
end

% Pass sensor metadata along, if it exists.
if isfield(sensor,'metadata')
    ip.metadata = appendStruct(ip.metadata,sensor.metadata);
end

end

%% ---------- Network demosaic

function ip = ipNetworkDemosaic(ip,sensor,networkName)
% Preprocess the demosaicking and set up the parameters for compute
% call.  The user has to have the Python environment setup.  More
% comments above.  Developed as part of ISETHDRSENSOR project.

exrDir = fullfile(isetRootPath,'local');
baseName = fullfile(exrDir,'rgbw');
fname  = sensor2EXR(sensor,[baseName,'.exr']);
ipName = sprintf('%s-demosaic.exr',baseName);

%'rgbw' and 'rgb' for now.  These were trained on the ar0132at sensor.
% We should probably check.
isetDemosaicNN(networkName, fname, ipName);

% img = exrread(fname);
% ieNewGraphWin; imagesc(abs(img.^0.3)); truesize

% Create the rendering transforms
wave     = sensorGet(sensor,'wave');
sensorQE = sensorGet(sensor,'spectral qe');
targetQE = ieReadSpectra('xyzQuanta',wave);
T{1} = imageSensorTransform(sensorQE(:,1:3),targetQE,'D65',wave,'mcc');
T{2} = eye(3,3);
T{3} = ieInternal2Display(ip);

ip = ipSet(ip,'demosaic method','skip');
ip = ipSet(ip,'transforms',T);
ip = ipSet(ip,'transform method','current');

img = exrread(ipName);
% ieNewGraphWin; imagesc(abs(img.^0.2));

ip = ipSet(ip,'sensor space',img);

% We should remove the exr files here.
end
