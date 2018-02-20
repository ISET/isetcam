function [voltImage, dsnu, prnu] = sensorComputeImage(oi,sensor,wBar)
%Main routine for computing the sensor voltage data from the optical image
%
%  [voltImage,dsnu,prnu] = sensorComputeImage(oi,sensor,wBarHandles)
%
% Compute the sensor voltage image from the sensor parameters and the
% optical image. This is the main computational routine used to compute
% the sensor image, and it calls a variety of sub-routines that implement
% many parts of the calculation.
%
% The spatial array of volts is routined by this routine.  In addition, the
% fixed pattern offset (dsnu) and photoresponse nonuniformity (prnu) can
% also be returned.  
%   
% To suppress the display of waitbars, set showBar to 0.  Default is 1.
%
%   COMPUTATIONAL OVERVIEW
%
%       1.  The current generated at each pixel by the signal is computed
%       (signalCurrent).  This is converted to a voltage using the cur2volt
%       parameter.
%
%       2.  The dark voltage is computed and added to the signal.
%
%       3.  Shot noise is computed for the sum of signal and dark voltage
%       signal. This noise is added.  Hence, the Poisson noise includes
%       both the uncertainty due to the signal and the uncertainty due to
%       the dark voltage.  (It is possible to turn this off by a scripting
%       command using sensorSet(sensor,'shotNoiseFlag',0)).
%
%       4.  Read noise is added.
%
%       5.  If the sensor fixed pattern noises, DSNU and PRNU  were
%       previously stored, they are added/multipled into the signal.
%       Otherwise, they are computed and stored and then combined into the
%       signal.
%
%       6.  If column FPN is selected and stored, it is retrieved and
%       combined into the signal.  If column FPN is selected but not
%       stored, it is computed and applied. Finally, if it is not selected,
%       it is not applied.
%
%       7.  Analog gain (ag) and analog offset (ao) are applied to the
%       voltage image: voltImage = (voltImage + ao)/ag;
%
%   Many more notes on the calculation, including all the units are
%   embedded in the comments below. 
%
%   If the waitBar handles are provided, they are used to show progress.
%   Without the waitbar handles, no waitbars are shown.
%
%  Example:
%     volts = sensorComputeImage(vcGetObject('oi'),vcGetObject('sensor'));
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Define parameters
if ~exist('sensor','var') || isempty(sensor), errordlg('sensor required.'); end
if ~exist('oi','var') || isempty(oi), errordlg('Optical image required.'); end
if ~exist('wBar','var') || isempty(wBar), showBar = 0; else showBar = 1; end

q = vcConstants('q');                       %Charge/electron
pixel = sensorGet(sensor,'pixel');

%% Calculate current
% This factor converts pixel current to volts for this integration time.
% The conversion units are  
%
%   sec * (V/e) * (e/charge) = sec * V / charge = V / current. 
%
% Given the basic rule V = IR, k is effectively a measure of resistance
% that converts current into volts given the exposure duration.
%
% We handle the case in which the integration time is a vector or matrix,
% by creating a matching conversion from current to volts.
cur2volt = sensorGet(sensor,'integrationTime')*pixelGet(pixel,'conversionGain') / q;
cur2volt = cur2volt(:);

% Calculate the signal current assuming cur2volt = 1;
if showBar, unitSigCurrent = signalCurrent(oi,sensor,wBar);
else        unitSigCurrent = signalCurrent(oi,sensor);
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
sensor = sensorVignetting(sensor);
etendue = sensorGet(sensor,'sensorEtendue');
voltImage = voltImage .* repmat(etendue,[1 1 sensorGet(sensor,'nExposures')]);
sensor   = sensorSet(sensor,'volts',voltImage);

% This can be a single matrix or it can a volume of data.  We should
% consider whether we want to place the volume elsewhere and always have
% voltImage be a matrix is displayed into the sensor window.
sensor = sensorSet(sensor,'volts',voltImage);

% Something went wrong.  Return data empty,  including the noise images.
if isempty(voltImage),  
    dsnu = []; prnu = []; 
    return; 
end

%% Add the dark current
if showBar, waitbar(0.8,wBar,'SensorImage: Noise'); end
darkCurrent = pixelGet(pixel,'darkCurrentDensity');
if darkCurrent ~= 0
    % At this point the noise dark current is the same at all pixels.
    % Later, we apply the PRNU gain factor to the sum of the signal and
    % noise, so that the noise dark current effectively varies across
    % pixels.  Sam Kavusi says that this variation in gain (also called
    % PRNU) is not precisely the same for signal and noise.  But we have no
    % way to assess this for most cases, so we treat the PRNU for noise and
    % signal as the same until forced to do it otherwise.
    eTimes = sensorGet(sensor,'expTime');
    nTimes = numel(eTimes);
    if nTimes == 1
        voltImage = voltImage + pixelGet(pixel,'darkVoltage')*eTimes;
    else
        for ii=1:nTimes
            voltImage(:,:,ii) = voltImage(:,:,ii) + ...
                pixelGet(pixel,'darkVoltage')*eTimes(ii);
        end
    end
end
sensor = sensorSet(sensor,'volts',voltImage);

%% Add shot noise.  
% Note that you can turn off shot noise in the calculation
% by setting the shotNoiseFlag to false.  Default is true.  This flag is
% accessed only through scripts at the moment.  There is no way to turn it
% off from the user interface.
if sensorGet(sensor,'shotNoiseFlag')
    voltImage = noiseShot(sensor);
    sensor = sensorSet(sensor,'volts',voltImage);
end

%% Add read noise
readNoise = pixelGet(sensor.pixel,'readnoisevolts');
if readNoise ~= 0,  voltImage = noiseRead(sensor); end
sensor = sensorSet(sensor,'volts',voltImage);

%% noiseFPN 
% This combines the offset and gain (dsnu,prnu) images with
% the current voltage image to produce a noisier image.  If these images
% don't yet exist, we compute them. 
dsnu = sensorGet(sensor,'dsnuImage');
prnu = sensorGet(sensor,'prnuImage');
if isempty(dsnu) || isempty(prnu)
    [voltImage,dsnu,prnu]  = noiseFPN(sensor);
    sensor = sensorSet(sensor,'dsnuImage',dsnu);
    sensor = sensorSet(sensor,'prnuImage',prnu);
    % disp('Initiating dsnu and prnu images');
else  
    voltImage = noiseFPN(sensor);
end
sensor = sensorSet(sensor,'volts',voltImage);

% Now we check for column FPN value.  If data exist then we compute column
% FPN noise.  Otherwise, we carry on.
if isempty(sensorGet(sensor,'coloffsetfpnvector')) || isempty(sensorGet(sensor,'colgainfpnvector'))
else voltImage = noiseColumnFPN(sensor);
end

%% Analog gain simulation
% We check for an analog gain and offset.  For many years there was no
% analog gain parameter.  This was added in January, 2008 when simulating
% some real devices. The manufactureres were clamping at zero and using the
% analog gain like wild men, rather than exposure duration. We set it in
% script for now, and we will add the ability to set it in the GUI before
% long.  If these parameters are not set, we assume they are returned as 1
% (gain) and 0 (offset).
%
% Note that in this application the gain is a divisor, so that 10 reduces
% the output voltage and 0.1 increases the output voltage.
ag = sensorGet(sensor,'analogGain');
ao = sensorGet(sensor,'analogOffset');
voltImage = (voltImage + ao)/ag;

return;

