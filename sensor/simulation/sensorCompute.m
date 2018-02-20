function outSensor = sensorCompute(sensor,oi,showBar)
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
%    voltage data are stored in the sensor.
%
%  The computation checks a variety of parameters and flags in the sensor
%  structure to perform the calculation.  These parameters and flags can be
%  set either through the graphical user interface (sensorImageWindow) or
%  by scripts.
%
% NOISE FLAG
%  The noise flag is an important way to control the details of the
%  calculation.  The default value of the noiseFlag is 2.  In this case,
%  which is standard operating, photon noise, read/reset, FPN, analog
%  gain/offset, clipping, quantization, are all included.  Different
%  selections are made by different values of the noiseFlag.  
%
%   sensor = sensorSet(sensor,'noise flag',noiseFlag);   
%
% The conditions are:
%
%  noiseFlag | photon other-noises analog-gain/offset clipping quantization
%    -1      |   0         0            0                0        0
%     0      |   0         0            +                +        +
%     1      |   +         0            +                +        +
%     2      |   +         +            +                +        +
%
% Further control can be achieved by setting parameters
%   To remove analog-gain/offset, set the parameters to 1,0
%   To remove quantization, set 'quantization method' to 'analog'
%   These are both the default conditions. 
%
% COMPUTATIONAL OUTLINE:
%
%   This is an overview of the algorithms.  The specific algorithms are
%   described in the routines themselves.
%
%   1. Handle exposure: autoExposure (or not).
%   2. Compute the mean image: sensorComputeImage()
%   3. Etendue calculation
%   4. Noise, analog gain, clipping, quantization
%   5. Correlated double-sampling
%   6. Handle macbeth management
%
%  The value of showBar determines whether the waitbar is displayed to
%  indicate progress during the computation.
%
% See also:  sensorComputeNoise, sensorAddNoise
%
% Examples:
%   sensor = sensorCompute;   % Use selected sensor and oi
%   tmp = sensorCompute(vcGetObject('sensor'),vcGetObject('oi'),0);
%
%  Or, compute with specific sensors
%   scene = sceneCreate; scene = sceneSet(scene,'hfov',4);
%   oi = oiCreate; sensor = sensorCreate;
%   oi = oiCompute(oi,scene); sensor = sensorCompute(sensor,oi);
%   vcAddAndSelectObject(sensor); sensorWindow('scale',1);
%
% Copyright ImagEval Consultants, LLC, 2011

%% Define and initialize parameters
if ~exist('sensor','var') || isempty(sensor), sensor = vcGetSelectedObject('sensor'); end
if ~exist('oi','var') || isempty(oi),         oi = vcGetSelectedObject('oi');         end
if ~exist('showBar','var') || isempty(showBar), showBar = ieSessionGet('waitbar'); end

wBar = [];

% We allow sensor arrays.  This was necessary as a temporary edit to keep
% the code similar for a while.  Later, I will use thisSensor and simplify
% the logic.
masterSensor = sensor;
clear sensor;

for ss=1:length(masterSensor)   % Number of sensors
    sensor = masterSensor(ss);
    %% Standard compute path
    if showBar, wBar = waitbar(0,sprintf('Sensor %d image:  ',ss)); end
    
    % Determine the exposure model
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
    % vcNewGraphWin; imagesc(voltImage); colormap(gray)
    
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
    
    %% We have the mean image computed.  We add noise, clip and quantize

    % See sensorComputeNoise to run just this noise section when you have a
    % mean image and just want many noisy, clipped, quantized examples.
    noiseFlag = sensorGet(sensor,'noise flag');
    
    % Follow noise flag rules
    % noiseFlag = -1 - no noise, no analog-clipping-quant
    % noiseFlag = 0  - no photon noise or other noise, but analog-clipping-quant are OK
    % noiseFlag = 1  - photon noise plus analog-clipping-quant
    % noiseFlag = 2  - dark current + photon + read-reset + FPN + colFPN
    %
    % In noiseFLag 0,1,2, 
    %  the analog gain/offset can be eliminated by setting gain to 1 and
    %  offset to 0 
    % 
    %  Quantization can be turned off by setting the quantization method
    %  to 'analog'
    
    % Skip this block if noiseFlag == -1.  That means no photon
    % noise, no other noises, no analog gain/offset, no clipping, no
    % quantization 
    if noiseFlag > -1
        
        % if noiseFlag = 0, no photon or other noise, but we will do analog
        % gain/offset, clipping, and quantization
        if noiseFlag > 0
            % if noiseFlag = 1, add photon noise only
            % if noiseFlag = 2, add photon noise and other noises
            sensor = sensorAddNoise(sensor);
        end
        
        %% Analog gain simulation
        
        % We check for an analog gain and offset.  For many years there was
        % no analog gain parameter.  This was added in January, 2008 when
        % simulating some real devices. The manufacturers were clamping at
        % zero and using the analog gain like wild men, rather than
        % exposure duration. We set it in script for now, and we will add
        % the ability to set it in the GUI before long.  If these
        % parameters are not set, we assume they are returned as 1 (gain)
        % and 0 (offset).
        % Note that we added a print out for the 'log' sensor type.s
        ag = sensorGet(sensor,'analogGain');
        ao = sensorGet(sensor,'analogOffset');
        if ag ~=1 || ao ~= 0
            if strcmp(responseType,'log')
                warning('log sensor with gain/Offset');
            end
            volts = sensorGet(sensor,'volts');
            volts = (volts + ao)/ag;
            sensor = sensorSet(sensor,'volts',volts);
        end
        
        
        %% Clipping
        % We clip the voltage because everything must fall between 0 and
        % voltage swing.  This is true even if the responseType is
        % log.
        vSwing = sensorGet(sensor,'pixel voltage swing');
        sensor = sensorSet(sensor,'volts',ieClip(sensorGet(sensor,'volts'),0,vSwing));
        
        %% Quantization
        % Compute the digital values (DV).   The results are written into
        % sensor.data.dv.  If the quantization method is Analog, then the
        % data.dv field is cleared and the data are stored only in
        % data.volts.
        
        if showBar, waitbar(0.95,wBar,'Sensor image: A/D'); end
        switch lower(sensorGet(sensor,'quantization method'))
            case 'analog'
                % dv = [];
                % Could just copy rather than calling analog2digital.  How bout
                % it?
                sensor = sensorSet(sensor,'volts',analog2digital(sensor,'analog'));
            case 'linear'
                sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'linear'));
            case 'sqrt'
                sensor = sensorSet(sensor,'digital values',analog2digital(sensor,'sqrt'));
            case 'lut'
                warning('sensorComputeNoise:LUT','LUT quantization not yet implemented.')
            case 'gamma'
                warning('sensorComputeNoise:Gamma','Gamma quantization not yet implemented.')
            otherwise
                sensor = sensorSet(sensor,'digitalvalues',analog2digital(sensor,'linear'));
        end
    end
    
    %% Correlated double sampling
    if  sensorGet(sensor,'cds')
        % Read a zero integration time image that we will subtract from the
        % simulated image.  This removes much of the effect of dsnu.
        integrationTime = sensorGet(sensor,'integration time');
        sensor = sensorSet(sensor,'integration time',0);
        
        if showBar, waitbar(0.6,wBar,'Sensor image: CDS'); end
        cdsVolts = sensorComputeImage(oi,sensor);    %THIS WILL BREAK!!!!
        sensor = sensorSet(sensor,'integration time',integrationTime);
        sensor = sensorSet(sensor,'volts',ieClip(sensor.data.volts - cdsVolts,0,[]));
    end
    
    if isempty(sensorGet(sensor,'volts'))
        % Something went wrong.  Clean up the mess and return control to the main
        % processes.
        delete(wBar); return;
    end
    
    %% Macbeth chart management
    % Possible overlay showing center of Macbeth chart
    sensor = sensorSet(sensor,'mccRectHandles',[]);
    
    if showBar, close(wBar); end
    
    % The sensor structure has new fields at this point, so reassigning to
    % the input sensor array doesn't work.  Explain, please.
    outSensor(ss) = sensor;
    
end


end