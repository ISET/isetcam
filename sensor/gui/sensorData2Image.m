function img = sensorData2Image(sensor,dataType,gam,scaleMax)
% Produce the image data displayed in the sensor window.
%
% Synopsis
%   img = sensorData2Image(sensor,[dataType = 'volts'],[gam=1],[scaleMax=0 (false)])
%
% This function renders an image of the sensor CFA.
%
% Inputs
%   sensor   - ISETCam sensor
%   dataType - Default is volts
%   gam      - Gamma for rendering
%   scaleMax - Scaling to max display intensity (false, not sure this is
%              handled correctly in the code!) 
%
% Optional key/val
%   N/A
%
% Return:
%  img: If the sensor has multiple filters, the image is RGB. If the sensor
%       is monochrome, the image is a single matrix.
%
% Description
%  This routine creates the color at each pixel resemble the
%  transmissivity of the color filter at that pixel. The intensity
%  measures the size of the data.  The dataType is normally volts.
%
%  Normally, the function takes in one CFA plane. It can also handle
%  the case of multiple exposure durations.
%
%  While it is usally used for volts, the routine converts the image
%  from the 'dv' fields or even 'electrons' (I think).
%
%  The returned images can be written out as a tiff file by
%  sensorSaveImage.
%
% Examples:
%  sensor = vcGetObject('sensor');
%  oi     = vcGetObject('oi');
%  sensor = sensorCompute(sensor,oi);
%  img    = sensorData2Image(sensor,'volts',0.6);
%  figure; imagesc(img)
%
%  sensor = sensorSet(sensor,'expTime',[.01 .3 ; 0.3 0.01]);
%  sensor = sensorCompute(sensor,oi);
%  img    = sensorData2Image(sensor,'volts',0.6);
%  figure; imagesc(img)
%
%  sensor = sensorSet(sensor,'expTime',[0.05 .1 .2 0.4]);
%  sensor = sensorCompute(sensor,oi);
%  img    = sensorData2Image(sensor,'volts',0.6);
%  figure; imagesc(img)
%
%  vcReplaceAndSelectObject(sensor); sensorImageWindow();
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%  sensorDisplayTransform
%

%%
if ieNotDefined('sensor'),     sensor = vcGetObject('sensor'); end
if ieNotDefined('dataType'),   dataType = 'volts'; end
if ieNotDefined('gam') ,       gam = 1; end
if ieNotDefined('scaleMax'),   scaleMax = 0; end

img = sensorGet(sensor,dataType);
if isempty(img), return; end

%% Determine the scale factor for the maximum of the display
if scaleMax,     mxImage = max(img(:));
else
    % The maximal value will depend on whether we are working with voltages
    % or digital values.
    switch dataType
        case 'volts'
            mxImage = sensorGet(sensor,'max output');
        case 'dv or volts'
            % If we have a digital value, we assume that's the
            % case we are in.  Otherwise we assume volts.
            mxImage = sensorGet(sensor,'max digital value');
            if isempty(mxImage)
                mxImage = sensorGet(sensor,'max output');
            end
        otherwise
            error('Unknown data type %s\n',dataType);
    end
end

% Call the an imaging routine; the choice depends on the sensor data type.
% Because of noise, it is possible that the img data will be < 0.
%
% Applying img.^ gam makes the data out of range.  So we need to trap this
% condition.
%
% A mosaicked color image.  This is the main routine to convert
% the planar image to an RGB image.  The conversion depends on the
% nature of the color filters in the cfa.
nSensors   = sensorGet(sensor,'nFilters');
expTimes   = sensorGet(sensor,'expTimes');
nExposures = sensorGet(sensor,'nExposures');

if nExposures > 1
    
    pSize = size(sensorGet(sensor,'pattern'));
    if isequal(pSize,size(expTimes))
        % Each plane goes into a different pixel in the constructed CFA.
        % If the pattern size is (r,c) the first r planes fill the first
        % row in the CFA pattern
        %
        %   ( 1 3 5
        %     2 4 6)
        nRows = sensorGet(sensor,'rows');
        nCols = sensorGet(sensor,'cols');
        cfa   = zeros(nRows,nCols);
        
        whichExposure = 1;
        for cc = 1:pSize(2)
            colSamps = cc:pSize(2):nCols;
            for rr=1:pSize(1)
                rowSamps = rr:pSize(1):nRows;
                cfa(rowSamps,colSamps) = img(rowSamps,colSamps,whichExposure);
                whichExposure = whichExposure + 1;
            end
        end
        img = cfa;
    else
        % In bracketing case we can select which exposure to render
        expPlane = sensorGet(sensor,'exposurePlane');
        img = sensorGet(sensor,dataType);
        img = img(:,:,expPlane);
    end
end

if nSensors > 1    % A color CFA
    
    % Converts sensor mosaic into an RGB format img
    img = plane2rgb(img,sensor,0);
    
    % Color method:
    %
    % In some cases we find a transformation, T, that maps the existing
    % sensors into RGB colors.  Then we apply that T to the image data.
    % This algorithm should work for any choice of color filter
    % spectra.  Perhaps the scaling (above) should be done below?  Or
    % at least T should be scaled.
    %
    % In other cases we look at the strings that define the rgb and bgr
    % filters. We do this because it looks nicer to have saturated R,G, and
    % B for those classic Bayer patterns or for patterns that are RGB with
    % a clear (white) filter. rgbw and wrgb are treated the same.  They are
    % both treated as WRGB.
    %
    % Some thoughts:
    %   We might try to  adjust T to get nice saturated colors.
    % One thought is to find the max value in each row and set that
    % to 1 and set the others to 0. That would handle a lot of
    % cases.
    % This trick forces a saturated color on every line ...
    %             mx = max(T,[],2);
    %             mx = diag( 1 ./ mx);
    %             T  = mx*T; T(T(:)<1) = 0;
    %
    % Another thought:
    %    T = colorTransformMatrix('cmy2rgb');
    %
    %    This is a good grbc case that could be handled as a special case,
    %    too.
    %    T = [1 0 0 ; 0 1 0 ; 0 0 1 ; 0 1 1];
    %
    % We could insert other switches.  For example, we could trap cmy and
    % cym cases here.
    
    switch sensorGet(sensor,'filterColorLetters')
        case 'rgb'
            % We just leave rgb data alone.
            % T = eye(3,3);  RGB case
            % We could always just run the case below, though.  It
            % seems to work OK.
            %                 T = sensorDisplayTransform(sensor);
            %                 img = imageLinearTransform(img,T);
        case 'wrgb'
            T = [1 1 1; 1 0 0; 0 1 0; 0 0 1];
            img = imageLinearTransform(img,T);
        case 'rgbw'
            T = [1 0 0; 0 1 0; 0 0 1; 1 1 1];
            img = imageLinearTransform(img,T);
        otherwise
            % I think this covers 3 and four color cases.  I am not
            % sure the other cases (above) should be handled
            % separately.
            T = sensorDisplayTransform(sensor);
            img = imageLinearTransform(img,T);
    end
    
    % Scale the displayed image intensity to the range between 0 and
    % the voltage swing.  RGB images are supposed to run from 0,1.
    %
    % If the dv data are ints, we need to cast the max as a double
    img = img/double(mxImage);
    img = ieClip(img,0,1).^gam;
    
elseif nSensors == 1
    % img = sensorDisplayTransform(sensor);
    % img = double(img);
    if isscalar(img)
        % In the CFA case, we have a single number, and we change that into
        % an RGB color
        img = sensorDisplayTransform(sensor);
        img = double(img);
        img = reshape(img,1,1,3);
    end
    % The general case of an image
    img = (img/mxImage).^gam;
end

%% Convert to an sRGB format

% At this point, the image is linear with respect to the voltage level in
% the pixels.
img = ieClip(img,0,1);

% If RGB, convert to display.  
if size(img,3) == 3
    % If just a monochrome array, leave it alone.
    
    % In other windows, we use xyz2srgb() to convert from the linear
    % representation to an sRGB representation.  Here, do the same kind of
    % transformation, but assuming we are lrgb, not xyz.
    img = lrgb2srgb(img);
end


end
