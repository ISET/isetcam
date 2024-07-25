function sensor = sensorAddNoise(sensor)
% Add electrical and photon noise to the sensor voltage image
%
% Synopsis
%    sensor = sensorAddNoise(sensor)
%
% Brief
%  The sensor structure enters with the mean voltage image (without
%  noise). Here, we compute the photon noise, sensor electrical noise,
%  and quantization error here and add them into the voltage image.
%
% Certain noise terms (fixed pattern noise, seed parameters?) are stored
% and returned in the sensor structure that is returned.  Hence if you want
% to run exactly the same noise simulation again, you can do it by calling
% the function with these seed and related parameters.
%
% An important reason for this routine is to let us generate multiple
% (noisy) samples of the same mean image.
%
% IMPORTANT NOTE:
% noiseFlag cases that are correctly handled.
%   0 - No noise at all, so we shouldn't even be here. We return.
%   1 - Shot noise only (arises from the photons)
%   2 - Shot noise and other electronic noise
%  -2 - Shot noise only
%
% We are not sure whether the -1 and -2 cases are handled correctly.
%
% Additional factors (analog gain/offset, clipping, quantization
% called FPN) are handled in the main sensorCompute routine.  The
% inclusion of these operations are managed by other values of the
% noiseFlag.
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See also:
%    sensorComputeNoise
%

%% Add noise

% We create a noise parameter structure
pixel = sensorGet(sensor,'pixel');

% 0 no noise
% 1 Photon noise
% 2 Photon and electronic noise
noiseFlag = sensorGet(sensor,'noise Flag');

if noiseFlag == 0, return; end

% Random noise generator seed issues must be handled here.  This is tough
% to make sure we can absolutely replicate the noise to test code accuracy.
if sensorGet(sensor,'reuse noise')
    % Get the state stored in the sensor
    noiseSeed = sensorGet(sensor,'noise seed');
    if isempty(noiseSeed)
        warning('sensorAddNoise:NoPreviousNoise','No previous noise. Initiating new seed');
        try noiseSeed = rng;
        catch err
            noiseSeed = randn('seed');
        end
        sensorSet(sensor,'noise seed',noiseSeed);
    else
        % Initialize with current seed.
        try  rng(noiseSeed);
        catch err
            randn('seed',noiseSeed);
        end
    end
    
    % We should really get rid of the stored dsnu/prnu images. Although
    % we might decide we want it transiently so we can plot it or check it.
    % So it is still in the structure, but not used in any computational
    % path.
    sensor = sensorSet(sensor,'dsnu image',[]);
    sensor = sensorSet(sensor,'prnu image',[]);
else
    % Not reusing.  But remember the initial noise state for this calculation
    try noiseSeed = rng;
    catch err
        noiseSeed = randn('seed');
    end
    sensor = sensorSet(sensor,'noise seed',noiseSeed);
end

%% Perform the noise addition steps here

nExposures = sensorGet(sensor,'nExposures');
eTimes = sensorGet(sensor,'exposure times');
volts = sensorGet(sensor,'volts');

for ii=1:nExposures
    
    vImage = volts(:,:,ii);
    
    % Add the dark current, which is the same at all pixels. Later, we
    % apply the PRNU gain factor to the sum of the signal and noise,
    % so that the noise dark current effectively varies across pixels.
    %
    % We add the dark voltage into the signal and we treat the (small
    % amount of) dark voltage variation as if it has the same noise as
    % the shot noise, arising from the photons.
    %
    % Sam Kavusi says that the variation in gain (also called PRNU) is
    % not precisely the same for signal (photons) and noise.  But we
    % have no way to assess this for most cases. So, we treat the PRNU
    % for noise and signal as the same.
    if noiseFlag == 2
        % Treating the dark voltage as if it were caused by light.
        vImage = vImage + pixelGet(pixel,'dark Voltage')*eTimes(ii);
        sensor = sensorSet(sensor,'volts',vImage);
    end
    
    % Calculated after adding the dark current.  Runs for -2, 1 and 2
    vImage = noiseShot(sensor);

    % If noiseFlag = 2, add the read noise, too.
    if noiseFlag == 2
        vImage = vImage + (pixelGet(pixel,'read noise volts') * randn(size(vImage)));
        sensor = sensorSet(sensor,'volts',vImage);
    end
    
    sensor = sensorSet(sensor,'volts',vImage);

    %% PRNU DSNU

    if noiseFlag == 1 || noiseFlag == 2
        vImage = noiseFPN(sensor);
        sensor = sensorSet(sensor,'volts',vImage);

        %% Column fixed pattern noise
        vImage = noiseColumnFPN(sensor);
        % sensor = sensorSet(sensor,'volts',vImage);
    end

    % That's is.  Store it in the volume image ...
    volts(:,:,ii) = vImage;
end

sensor = sensorSet(sensor,'volts',volts);

end
