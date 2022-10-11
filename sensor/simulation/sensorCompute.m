function [outSensor, unitSigCurrent] = sensorCompute(sensor,oi,showBar)
%Compute sensor response from optical image data
%
%   sensor = sensorCompute([sensor],[oi],[showBar = 1])
%
%  This function calculates the sensor volts (electrons) at each pixel from
%  the optical image (oi).
%
% Inputs
%    sensor:   Image sensor, possibly a cell array of sensors
%    oi:       Optical irradiance data
%
% Return
%    sensor: Image sensor (possibly an array of sensors). The computed
%            voltage data are stored in the sensor.
%
%  The computation checks a variety of parameters and flags in the sensor
%  structure to perform the calculation.  These parameters and flags can be
%  set either through the graphical user interface (sensorWindow) or
%  by scripts.
%
% NOISE FLAG
%  The noise flag is an important way to control the details of the
%  calculation.  The default value of the noiseFlag is 2.  This case is
%  standard operating mode with photon noise, read/reset, dsnu, prnu,
%  analog gain/offset, clipping, quantization, included.
%
%  Each of the noises can be individually controlled, but the noise flag
%  simplifies turning off different types of noise for certain experiments
%
%   sensor = sensorSet(sensor,'noise flag',noiseFlag);
%
% The conditions are:
%
%  noiseFlag | photon   e-noises gain/offset clipping  CDS
%    -2      |   +         0            0         0     0   ('no pixel no system')
%    -1      |   0         0            0         0     0   ('no photon no pixel no system')
%     0      |   0         0            +         +     +   ('no photon no pixel')
%     1      |   +         0            +         +     +   ('no pixel noise')
%     2      |   +         +            +         +     +   ('default')
%
%  photon noise:  Photon noise
%  pixel noise:   Electrical noise (read, reset, dark)
%  system noise:  gain/offset (prnu, dsnu), clipping, quantization
%
% noiseFlag = -2 - photon noise,    no eNoises, no GCQ
% noiseFlag = -1 - no photon noise, no eNoises, no GCQ
% noiseFlag =  0 - no photon noise, no eNoises, yes GCQ
% noiseFlag =  1 - photon noise, no eNoises, yes GCQ
% noiseFlag =  2 - photon noise, yes eNoises,yes GCQ
%
% In addition to controlling factors through the noise flag, it is possible
% to manage them by individually setting sensor parameters. For example,
% when noiseFlag 0,1,2, you can still control the analog gain/offset noise
% can be eliminated by setting 'prnu sigma' and 'dsnu sigma' to 0.
% Similarly you can set the read noise and dark voltage to 0.
%
% Quantization noise can be turned off by setting the quantization method
% to 'analog'
%
%   * quantization       - set 'quantization method' to 'analog' (default)
%   * CDS                - set the cds flag to false (default)
%   * Clipping           - You can avoid clipping high with a large
%        voltage swing.  But other noise factors might drive the
%        voltage below 0, and we would clip.
%
% COMPUTATIONAL OUTLINE:
%
%   1. Check exposure duration: autoExposure default, or use the set
%      time.
%   2. Compute the mean image: sensorComputeImage()
%   3. Etendue calculation to account for pixel vignetting
%   4. Noise, analog gain, clipping, quantization
%   5. Correlated double-sampling
%   6. Macbeth ROI management
%
%  The value of showBar determines whether the waitbar is displayed to
%  indicate progress during the computation.
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
if ~exist('showBar','var') || isempty(showBar), showBar = ieSessionGet('waitbar'); end

wBar = [];

% We allow sensor arrays as input, though this is rarely used.
sensorArray = sensor;
clear sensor;

for ss=1:length(sensorArray)   % Number of sensors
    sensor = sensorArray(ss);
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
    if numel(integrationTime) == 1 && ...
            ( (integrationTime == 0) || sensorGet(sensor,'auto exposure') )
        % The autoexposure will need to work for the cases of 1 value for the
        % whole array and it will need to work for the case in which the
        % exposure times have the same shape as the pattern.  If neither holds
        % then we have to use the vector of numbers that are sent in.
        % We could decide that if autoexposure is on and there is a vector of
        % values we replace them with a single value.
        if showBar, wBar = waitbar(0,wBar,'Sensor image: Auto Exposure'); end
        sensor.integrationTime  = autoExposure(oi,sensor);
        
    elseif isvector(integrationTime)
        % We are in bracketing mode, do nothing.
        
    elseif isequal( size(integrationTime),size(pattern) )
        % Find best exposure for each color filter separately
        if sensorGet(sensor,'autoexposure')
            sensor = sensorSet(sensor,'exp time',autoExposure(oi,sensor,[],'cfa'));
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
    if numel(cur2volt) == 1
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
    
    responseType = sensorGet(sensor,'response type');
    switch responseType
        case 'log'
            % We need to keep the smallest value above zero. We also
            % want the read noise level to make sense with respect to
            % the voltage swing.
            readNoise = sensorGet(sensor,'pixel read noise');
            if readNoise == 0
                warning('Invalid read noise for log response type.  Using 2^16 of voltage swing');
                readNoise = sensorGet(sensor,'pixel voltage swing')/(2^16);
            end
            voltImage = log10(voltImage + readNoise) - log10(readNoise);
        otherwise
            % Linear case.  Do nothing.
    end
    
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
    
    % The noise flag rules for different integer values are described in
    % the header to this function.
    %
    if noiseFlag >= 0
        % Apply this block if noiseFlag >= 0.
        
        % See the comments in the header for the definition of the
        % noiseFlag. N.B. The noiseFlag  governs clipping and
        % quantization, not just noise.
        if noiseFlag > 0
            % if noiseFlag = 1, add photon noise, but not other noises
            % if noiseFlag = 2, add photon noise and other noises
            sensor = sensorAddNoise(sensor);
        end
        
        %% Analog gain simulation
        
        % We check for an analog gain and offset.  For many years there was
        % no analog gain parameter. This was added in January, 2008 when
        % simulating some real devices. The manufacturers were clamping at
        % zero and using the analog gain like wild men, rather than
        % exposure duration. If these parameters are not set, they default
        % to 1 (gain) and 0 (offset).
        %
        % Also, some people use gain as a multipler and some as a divider.
        % Sorry for that.  Here you can see the formula.  We divide by the
        % gain.
        ag = sensorGet(sensor,'analogGain');
        ao = sensorGet(sensor,'analogOffset');
        if ag ~=1 || ao ~= 0
            if strcmp(responseType,'log')
                % We added a warning for the 'log' sensor type. Offset
                % and gain for a log sensor is a strange thing to do.
                warning('log sensor with gain/Offset');
            end
            volts = sensorGet(sensor,'volts');
            
            % Some people prefer a gain and offset formula like this:
            %
            %    volts/ag + ao
            %
            % If you are one of those people, then when you set the ISETCam
            % analog offset level parameter think of the formula as
            %
            %   volts/ag + ao = volts/ag + (ao'/ag)
            %
            % where ao' is the ISETCam analog offset. Your analog offset
            % (ao) should be equal to the ISETCam analog offset (ao')
            % divided by the gain (ao'/ag).  Thus, the ISETCam analog
            % offset should be ao' = ao*ag.
            %
            volts = (volts + ao)/ag;
            sensor = sensorSet(sensor,'volts',volts);
        end
        
        %% Clipping
        
        % Applied for 0,1,2
        if noiseFlag >=0 && noiseFlag <=2
            % We clip the voltage because everything must fall between 0 and
            % voltage swing.  This is true even if the responseType is
            % log.
            vSwing = sensorGet(sensor,'pixel voltage swing');
            sensor = sensorSet(sensor,'volts',ieClip(sensorGet(sensor,'volts'),0,vSwing));
        end
        
        
    elseif noiseFlag == -2
        % Only add photon noise.  No clipping or CDS or other noise
        % methods.  Unfortunately, the sensorAddNoise parameter doesn't
        % match the noiseFlag parameter closely.  So, we set it and then
        % put it back.
        sensor = sensorSet(sensor,'noiseFlag',1);  % Only Poisson noise
        sensor = sensorAddNoise(sensor);
        sensor = sensorSet(sensor,'noiseFlag',noiseFlag);  % Put it back
    elseif noiseFlag == -1
        % No photon no pixel no system
        
    else
        error('Bad noiseFlag %d\n',noiseFlag);
    end
    
    %% Quantization
    
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
        case 'gamma'
            warning('sensorComputeNoise:Gamma','Gamma quantization not yet implemented.')
        otherwise
            sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
    end
    
    %% Correlated double sampling
    if  sensorGet(sensor,'cds') && noiseFlag >= 0
        disp('CDS on')
        % Read a zero integration time image that we subtract from the
        % simulated image.  This removes much of the effect of dsnu.
        integrationTime = sensorGet(sensor,'integration time');
        sensor = sensorSet(sensor,'integration time',0);
        
        if showBar, waitbar(0.6,wBar,'Sensor image: CDS');  end
        cdsVolts = sensorComputeImage(oi,sensor);    %THIS WILL BREAK!!!!
        sensor = sensorSet(sensor,'integration time',integrationTime);
        sensor = sensorSet(sensor,'volts',ieClip(sensor.data.volts - cdsVolts,0,[]));
    end
    
    
    %% Check
    if isempty(sensorGet(sensor,'volts'))
        % Something went wrong.  Clean up the mess and return control to the main
        % processes.
        delete(wBar); return;
    end
    
    %% Macbeth chart management
    
    % Possible overlay showing center of Macbeth chart
    % sensor = sensorSet(sensor,'mccRectHandles',[]);
    if showBar, close(wBar); end
    
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
    
end


end