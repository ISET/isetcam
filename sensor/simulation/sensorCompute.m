function outSensor = sensorCompute(sensor,oi,showBar)
% Compute sensor response from optical image data
%
% Synopsis
%   sensor = sensorCompute([sensor],[oi],[showBar = 1])
%
% Brief
%  Calculates the sensor volts (electrons) at each pixel from the
%  optical image (oi). The computation checks a variety of sensor
%  parameters and flags in the sensor structure to perform the
%  calculation.
%
% Inputs
%    sensor:   Image sensor, possibly a cell array of sensors
%    oi:       Optical irradiance data
%   showBar:   Display the show bar during the computation (default
%              from ieSessionGet('waitbar')
% Return
%    sensor: Image sensor (possibly an array of sensors). The computed
%            voltage data are stored in the sensor.
%
% COMPUTATIONAL OUTLINE:
%
%   1. Manage exposure duration and bracketing (autoExposure)
%   2. Compute the mean voltage image (sensorComputeImage)
%   3. Account for pixel vignetting (sensorVignetting)
%   4. Noise cases (sensorAddNoise)
%   5. Apply analog gain and offset (sensorGainOffset)
%   6. Clipping and quantization (analog2digital)
%   7. Macbeth ROI management
%
% NOISE FLAG
%  The types of noise, and their levels, can be individually
%  controlled. The noise flag is used to simplify turning off
%  different types of noise for certain experiments, without changing
%  the sensor parameters.
%
%  The default is noiseFlag = 2. This case is standard operating mode
%  with photon noise, read/reset, dsnu, prnu. 
%
%    sensor = sensorSet(sensor,'noise flag',noiseFlag);
%
% The noise flag conditions are:
%
%  noiseFlag | photon   e-noises   FPN     
%    -2      |   +         0        0     ('no electrical no FPN')
%    -1      |   0         0        0     ('no photon no electrical no FPN')
%     0      |   0         0        0     ('no photon no electrical no FPN')
%     1      |   +         0        +     ('no electrical')
%     2      |   +         +        +     ('all')
%
%  photon noise:  Also called shot noise
%  pixel noise:   Electrical noise (read, reset, dark) (eNoise)
%  FPN:           Prnu, dsnu
%
%  * The setting noiseFlag = -2 is very useful for evaluating a purely
%    photon noise limited system.
%  * 0 and -1 are no noise at all.  They are both there for historical
%    reasons.  Use noiseFlag = 0 because we might change the meaning of
%    -1 some day.
%
% OTHER CONTROLS
%  There are additional, less frequently modeled,  noise
%  properties.You can control these processes individually.
%
%  * CDS:           Correlated double sampling (needs checking)
%  * Column FPN:    This is a specialized type of FPN
%
% When noiseFlag 0,1,2, you can still control the analog gain/offset values. 
% FPN can be eliminated by setting 'prnu sigma' and 'dsnu sigma' to 0.
% Similarly you can set the read noise and dark voltage to 0.
% Quantization can be elimited by setting 'quantization method' to
% 'analog'.
%
% The value of showBar determines whether the waitbar is displayed to
% indicate progress during the computation.
%
% Copyright ImagEval Consultants, LLC, 2011
%
% See also:
%   sensorComputeNoise, sensorAddNoise

% Examples:
%{
  scene = sceneCreate; scene = sceneSet(scene,'hfov',4);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate; sensor = sensorCompute(sensor,oi);
  sensorWindow(sensor);
%}

%% Define and initialize parameters
if ~exist('sensor','var') || isempty(sensor), sensor = vcGetSelectedObject('sensor'); end
if ~exist('oi','var') || isempty(oi),         oi = vcGetSelectedObject('oi');         end
if ~exist('showBar','var') || isempty(showBar), showBar = ieSessionGet('waitbar');    end

wBar = [];

% We allow sensor arrays as input, though this is rarely used.
sensorArray = sensor;
clear sensor;

for ss=1:length(sensorArray)   % Number of sensors
    if iscell(sensorArray)
        sensor = sensorArray{ss};
    else
        sensor = sensorArray(ss);
    end

    %% Standard compute path
    if showBar, wBar = waitbar(0,sprintf('Sensor %d image:  ',ss)); end
    
    % Determine the exposure model - At this point we use either the
    % default auto-exposure or we use the time the user set.  If you
    % would like to use a different autoExposure model, run it before
    % the sensorCompute call and set the integration time determined
    % by that call.  Some day, we might allow the user to set the
    % model here, but that is not currently the case.
    integrationTime = sensorGet(sensor,'integration Time');
    pattern = sensorGet(sensor,'pattern');
    if isscalar(integrationTime) && ...
            ( (integrationTime == 0) || sensorGet(sensor,'auto exposure') )
        % The autoexposure will need to work for the cases of 1 value for the
        % whole array and it will need to work for the case in which the
        % exposure times have the same shape as the pattern.  If neither holds
        % then we have to use the vector of numbers that are sent in.
        % We could decide that if autoexposure is on and there is a vector of
        % values we replace them with a single value.
        if showBar, wBar = waitbar(0,wBar,'Sensor image: Auto Exposure'); end
        sensor.integrationTime  = autoExposure(oi,sensor,0.95,'default');
        
    elseif isvector(integrationTime)
        % We are in bracketing or burst mode, do nothing.
        
    elseif isequal( size(integrationTime),size(pattern) )
        % Find best exposure for each color filter separately
        if sensorGet(sensor,'autoexposure')
            sensor = sensorSet(sensor,'exp time',autoExposure(oi,sensor,0.95,'cfa'));
        end
    end
    
    %% Calculate current
    % This factor converts pixel current to volts for this integration time.
    % The conversion units are
    %
    %   sec * (V/e) * (e/charge) = V / (charge / sec) = V / current (amps).
    %
    % Given the basic rule V = IR, k is effectively a measure of resistance
    % that converts current into volts given the exposure duration.
    %
    % We handle the case in which the integration time is a vector or matrix,
    % by creating a matching conversion from current to volts.
    q = vcConstants('q');     %Charge/electron
    pixel = sensorGet(sensor,'pixel');
    
    % Convert current (Amps) to volts
    % Check the units:
    %  S * (V / e) * (Coulombs / e)^-1   % https://en.wikipedia.org/wiki/Coulomb
    %    = S * (V / e) * (( A S ) / e) ^-1
    %    = S * (V / e) * ( e / (A S)) = (V / A)
    cur2volt = sensorGet(sensor,'integrationTime')*pixelGet(pixel,'conversionGain') / q;
    cur2volt = cur2volt(:);
    
    % Calculate the signal current assuming cur2volt = 1;
    if showBar, unitSigCurrent = signalCurrent(oi,sensor,wBar);
    else,       unitSigCurrent = signalCurrent(oi,sensor);
    end
    
    %% Convert to volts
    % Handle multiple exposure value case.
    if isscalar(cur2volt)
        % There is only one exposure time.  Conventional calculation
        voltImage = cur2volt*unitSigCurrent;
    else
        % Multiple exposure times, so we copy the unit term into multiple
        % dimensions
        voltImage = repmat(unitSigCurrent,[1 1 length(cur2volt)]);
        % Multiply each dimension by its own scale factor
        for ii=1:length(cur2volt)
            voltImage (:,:,ii) = cur2volt(ii)*voltImage (:,:,ii);
        end
    end
    
    %% Calculate etendue from pixel vignetting
    % We want an array (wavelength-independent) of scale factors that account
    % for the loss of light() at each pixel as a function of the chief ray
    % angle. This method only works for wavelength-independent relative
    % illumination. See notes in signalCurrentDensity for another approach that
    % we might use some day, say in ISET-3.0
    if showBar, waitbar(0.4,wBar,'Sensor image: Optical Efficiency'); end
    sensor    = sensorVignetting(sensor);
    etendue   = sensorGet(sensor,'sensorEtendue');  % vcNewGraphWin; imagesc(etendue)
    voltImage = voltImage .* repmat(etendue,[1 1 sensorGet(sensor,'nExposures')]);
    % ieNewGraphWin; imagesc(voltImage); colormap(gray(64))
    
    % This can be a single matrix or it can a volume of data.  We should
    % consider whether we want to place the volume elsewhere and always have
    % voltImage be a matrix is displayed into the sensor window.
    sensor = sensorSet(sensor,'volts',voltImage);
    
    % Something went wrong.  Return data empty,  including the noise images.
    if isempty(voltImage)
        % Something went wrong.  Clean up the mess and return control to the main
        % processes.
        delete(wBar); return;
    end
    
    %% We have the mean image computed.  Now add noise, clip and quantize
    
    % See sensorComputeNoise to run just this noise section when you have a
    % mean image and just want many noisy, clipped, quantized examples.
    noiseFlag = sensorGet(sensor,'noise flag');

    % We calculate the noise without the analog offset and gain. We
    % set analog gain/offset to 1 and 0 here, and then after adding in
    % the noises we apply the gain and offsets. We will restore these
    % later to the struct.    
    ag = sensorGet(sensor,'analog gain');
    ao = sensorGet(sensor,'analog offset');
    sensor = sensorSet(sensor,'analog gain',1);
    sensor = sensorSet(sensor,'analog offset',0);

    % The noise flag rules for different integer values are described in
    % the header to this function.    
    if noiseFlag == 0 || noiseFlag == -1
        % No noise added at all.

    elseif noiseFlag == 1 || noiseFlag == 2
        
        % See the comments in the header for the definition of the
        % noiseFlag. N.B. The noiseFlag  governs clipping and
        % quantization (GCQ), not just noise (photon, electrical).

        % if noiseFlag = 1, add photon noise, but not electrical.  It
        % does have FPN.
        % 
        % if noiseFlag = 2, add photon noise, electrical, FPN .

        % The noise is added in here so we can loop over multiple
        % exposures, say for exposure bracketing.  The loop in this
        % function is for multiple sensors.
        sensor = sensorAddNoise(sensor);
        
        %% Correlated double sampling
        if  sensorGet(sensor,'cds')
            disp('CDS on')

            % Needs checking and fixing. 2024.

            % Read a zero integration time image that we subtract from the
            % simulated image.  This removes much of the effect of dsnu.
            integrationTime = sensorGet(sensor,'integration time');
            sensor = sensorSet(sensor,'integration time',0);

            if showBar, waitbar(0.6,wBar,'Sensor image: CDS');  end
            cdsVolts = sensorComputeImage(oi,sensor);    %THIS WILL BREAK!!!!
            sensor = sensorSet(sensor,'integration time',integrationTime);
            sensor = sensorSet(sensor,'volts',ieClip(sensor.data.volts - cdsVolts,0,[]));
        end

                
    elseif noiseFlag == -2
        % Only adds the photon noise.  Used for applications when we
        % want to compare to the best possible performance, limited
        % only by shot noise.  These are 'ideal' sensor cases.
        sensor = sensorAddNoise(sensor);         
    else
        error('Bad noiseFlag %d\n',noiseFlag);
    end
    
    %% Apply gain and offset.  This also restores the values into sensor
    sensor = sensorGainOffset(sensor,ag,ao);

    %% Clipping - always applied

    % We clip the voltage because everything must fall between 0 and
    % voltage swing.  To avoid clipping, set vSwing very large.
    vSwing = sensorGet(sensor,'pixel voltage swing');

    % This is the place where we clip, after dealing with all the
    % noise, not before.
    sensor = sensorSet(sensor,'volts',ieClip(sensorGet(sensor,'volts'),0,vSwing));
        
    %% Quantization - Always applied.  If analog, no real quantization
    
    % Run the quantization, no matter the noise flag. This writes to
    % the DV slot but does not impact the volts/electrons. The results are
    % written into sensor.data.dv.  If 'analog' is set, however, no
    % quantization is applied.
    if showBar, waitbar(0.95,wBar,'Sensor image: A/D'); end
    switch lower(sensorGet(sensor,'quantization method'))
        case 'analog'
            % If the quantization method is Analog, then the data are
            % stored only in data.volts.  We used to run this line.
            % sensor = sensorSet(sensor,'volts',analog2digital(sensor,'analog'));
        case 'linear'
            sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
        case 'sqrt'
            sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'sqrt'));
        case 'lut'
            warning('sensorComputeNoise:LUT','LUT quantization not yet implemented.')
        otherwise
            % Changed to analog July, 2024.
            % sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
    end
    
    
    %% Check
    if isempty(sensorGet(sensor,'volts'))
        % Something went wrong.  Clean up the mess and return control to the main
        % processes.
        delete(wBar); return;
    end
       
    if showBar, close(wBar); end

    %% Metadata management
    
    % Copy metadata from oi to the sensor
    sensor = sensorSet(sensor,'metadata sensorname',sensorGet(sensor,'name'));
    sensor = sensorSet(sensor,'metadata scenename',oiGet(oi,'name'));
    optics = oiGet(oi,'optics');
    if ~isempty(optics)
        sensor = sensorSet(sensor,'metadata opticsname',oiGet(optics,'name'));
    end

    % The sensor structure has fields that are not present in the
    % input sensor. So we have a new outSensor.  There will be as many
    % outSensor members as there are slots in the sensorArray.
    outSensor(ss) = sensor; %#ok<AGROW>

    % Preserve metadata from the OI & originally the scene
    outSensor(ss).metadata = appendStruct(oi.metadata, sensor.metadata); %#ok<AGROW> 

end

end


%{
    responseType = sensorGet(sensor,'response type');
    switch responseType
        case 'log'
            warning('We are deprecating the log sensor model.  Send BW a message if you see this.')
            % We need to keep the smallest value above zero. We also
            % want the read noise level to make sense with respect to
            % the voltage swing.  Very little tested (BW).
            readNoise = sensorGet(sensor,'pixel read noise');
            if readNoise == 0
                warning('Invalid read noise for log response type.  Using 2^16 of voltage swing');
                readNoise = sensorGet(sensor,'pixel voltage swing')/(2^16);
            end
            voltImage = log10(voltImage + readNoise) - log10(readNoise);
        otherwise
            % Linear case.  Do nothing.
    end
%}