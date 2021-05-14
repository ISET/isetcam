function [dv, voltImage, dsnu, prnu] = binSensorComputeImage(OI,ISA,bMethod,wBar)
%Computes the sensor voltage data from the optical image using binning
%
%  [dv, voltImage, dsnu,prnu] = binSensorComputeImage(OI,ISA,bMethod,wBarHandles)
%
% Compute the sensor voltage image from the sensor parameters and the
% optical image. This is the main computational routine used to compute
% the sensor image, and it calls a variety of sub-routines that implement
% many parts of the calculation.
%
% The spatial array of volts is routined by this routine.  In addition,
% the fixed pattern offset (dsnu) and photoresponse nonuniformity (prnu)
% can also be returned.
%
% To suppress the display of waitbars, set showWaitBar to 0.  Default is 1.
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
%   Many more notes on the calculation, including all the units are
%   embedded in the comments below.
%
%   If the waitBar handles are provided, they are used to show progress.
%   Without the waitbar handles, no waitbars are shown.
%
%  Example:
%     volts = sensorComputeImage(vcGetObject('oi'),vcGetObject('ISA'));
%
% Copyright ImagEval Consultants, LLC, 2003.


%% Define parameters
if ieNotDefined('wBar'), showWaitBar = 0; else showWaitBar = 1; end
if ieNotDefined('OI'), errordlg('Optical image required.'); end
if ieNotDefined('ISA'), errordlg('Image sensor array required.'); end
if ieNotDefined('bMethod'), bMethod = 'kodak2008'; end

q = vcConstants('q');                       %Charge/electron
pixel = sensorGet(ISA,'pixel');

%% Define current
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
cur2volt = sensorGet(ISA,'integrationTime')*pixelGet(pixel,'conversionGain') / q;
cur2volt = cur2volt(:);

% Calculate the signal current assuming cur2volt = 1;
if showWaitBar, unitSigCurrent = signalCurrent(OI,ISA,wBar);
else            unitSigCurrent = signalCurrent(OI,ISA);
end

%% Current to volts
if numel(cur2volt) == 1
    % There is only one exposure time.  Conventional calculation
    voltImage = cur2volt*unitSigCurrent;
else
    % Multiple exposure times, so we copy the unit term into multiple
    % dimensions
    voltImage = repmat(unitSigCurrent,[1 1 length(cur2volt)]);
    % Multiply each dimension by its own scale factor
    for ii=1:length(cur2volt)
        voltImage(:,:,ii) = cur2volt(ii)*voltImage(:,:,ii);
    end
end

%% Etendue
% We want an array (wavelength-independent) of scale factors that account
% for the loss of light() at each pixel as a function of the chief ray
% angle. This method only works for wavelength-independent relative
% illumination. See notes in signalCurrentDensity for a much more complex
% approach that might use some day in the distant future.
if showWaitBar, waitbar(0.4,wBar,'Sensor image: Optical Efficiency'); end
ISA       = sensorVignetting(ISA);
etendue   = sensorGet(ISA,'sensorEtendue');
voltImage = voltImage .* repmat(etendue,[1 1 sensorGet(ISA,'nExposures')]);
ISA       = sensorSet(ISA,'volts',voltImage);

% This can be a single matrix or it can a volume of data.  We should
% consider whether we want to place the volume elsewhere and always have
% voltImage be a matrix is displayed into the sensor window.
ISA = sensorSet(ISA,'volts',voltImage);

% Something went wrong.  Return data empty,  including the noise images.
if isempty(voltImage),
    dsnu = []; prnu = [];
    return;
end

%% Add the dark current
if showWaitBar, waitbar(0.8,wBar,'SensorImage: Noise'); end
darkCurrent = pixelGet(pixel,'darkCurrentDensity');
if darkCurrent ~= 0
    % At this point the noise dark current is the same at all pixels.
    % Later, we apply the PRNU gain factor to the sum of the signal and
    % noise, so that the noise dark current effectively varies across
    % pixels.  Sam Kavusi says that this variation in gain (also called
    % PRNU) is not precisely the same for signal and noise.  But we have no
    % way to assess this for most cases, so we treat the PRNU for noise and
    % signal as the same until forced to do it otherwise.
    eTimes = sensorGet(ISA,'expTime');
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
ISA = sensorSet(ISA,'volts',voltImage);

%% Add shot noise.
% Note that you can turn off shot noise in the calculation
% by setting the shotNoiseFlag to false.  Default is true.  This flag is
% accessed only through scripts at the moment.  There is no way to turn it
% off from the user interface.
if sensorGet(ISA,'shotNoiseFlag')
    voltImage = noiseShot(ISA);
    ISA = sensorSet(ISA,'volts',voltImage);
end


%% Apply binning method
% Many of the noises except  contribute to the individual pixel response.
% Some of the noise, however, happens after the binning. The read noise is
% after binning. The fixed pattern noise is also after binning (we think).
% We are treating the shot noise, etendue, and dark current as present in
% the individual pixels.  We then combine the charge between pixels (noise
% free combination, no noise in the binning process).  Then there is read
% noise and signal amplification (offset and gain) noise after the binning
% process. The statistics of the read noise, offset (DSNU) and gain (PRNU)
% are the same as in the general sensor specification.  They differ only by
% being applied to fewer read out values.
%
% Let's get Okincha to tell us something about this.
ISA = binPixel(ISA,bMethod);

%% Fixed pattern noises - DSNU and PRNU
% noiseFPN combines the offset and gain (dsnu,prnu) images with
% the current voltage image to produce a noisier image.  If these images
% don't yet exist, we compute them.
dsnu = sensorGet(ISA,'dsnuImage');
prnu = sensorGet(ISA,'prnuImage');

% In the binning process, after the pixelBin above, we are computing with
% values that are in the digital values slot, not the voltage slot.  The
% values at this point are still volts, but we are about to add the final
% pieces of noise and then quantize.
dv = sensorGet(ISA,'digitalValues');
if (isempty(dsnu) || isempty(prnu)) || ...
        ~isequal(size(dv),size(dsnu)) || ...
        ~isequal(size(dv),size(prnu))
    % disp('Initiating dsnu and prnu images');
    [dv,dsnu,prnu]  = binNoiseFPN(ISA);
else
    dv = binNoiseFPN(ISA);
end
ISA = sensorSet(ISA,'digitalValues',dv);

%% Column FPN
% Now we check for column FPN value.  If data exist then we compute column
% FPN noise.  Otherwise, we carry on.
if isempty(sensorGet(ISA,'coloffsetfpnvector')) || ...
        isempty(sensorGet(ISA,'colgainfpnvector'))
    % Do nothing
else
    % Compute column FPN
    dv = binNoiseColumnFPN(ISA);
end


%% Add read noise
readNoise = pixelGet(ISA.pixel,'readnoisevolts');
if readNoise ~= 0,  dv = binNoiseRead(ISA); end

%% Returns dv, dsnu and prnu

return;

