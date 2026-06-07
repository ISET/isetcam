%% s_pixelSizeDR
%
% Calculate pixel dynamic range assuming various technology properties
%
% Pixel dynamic range is an important property that specifies the range of
% illuminance levels that can be reliably measured by a pixel.
%
% The formula for pixel dynamic range is
%
%     20 log10 ( pixVoltageRange / pixNoise )
%
% with definitions
%
%  pixVoltageRange:  the max voltage swing minus the accumulated dark
%  voltage (for a particular integration time)
%
%  pixNoise: the standard deviation of the combined read noise plus dark
%  voltage noise.
%
% The dynamic range depends on the integration time because the dark
% voltage accumulates over time.  It is possible to calculate the dynamic
% range assuming that there is no dark voltage.  But we leave this for the
% marketing people ;).
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Set up

% You should set the parameters here according to your technology
% properties.  Different types of pixel manufacturing processes produce
% different sets of read noise, dark voltage, and voltage swing parameters.
integrationTime = 0.010;                          % Sec (10 ms)
pixelSize =    [2 4 6 9 10]*1e-6;                 % Pixel size in meters
readNoiseSD =  [5 4 3 2 1]*1e-3;                  % std dev in volts
voltageSwing = [.7 1.2 1.5 2 3];                  % voltage swing
darkVoltage  = [1 1 1 1 1]*1e-3;                  % Volts per sec

%% Run

% After setting your own parameters, run this code to see the dynamic range
% of your pixel.
sensor = sensorCreate('monochrome');              %Initialize
pixel = sensorGet(sensor,'pixel');
sensor = sensorSet(sensor,'integrationTime',integrationTime);

for ii=1:length(pixelSize)
    pixel = pixelSet(pixel,'size',[pixelSize(ii),pixelSize(ii)]);
    pixel = pixelSet(pixel,'readNoiseSTDvolts',readNoiseSD(ii));
    pixel = pixelSet(pixel,'voltageSwing',voltageSwing(ii));
    pixel = pixelSet(pixel,'darkVoltage',darkVoltage(ii));
    
    sensor = sensorSet(sensor,'pixel',pixel);
    dr(ii) =  pixelDR(sensor);
end

%% Plot the results
vcNewGraphWin; plot(pixelSize/1e-6,dr,'-o')
xlabel('Size (um)'), ylabel('Dynamic range (db)')
grid on

%% End of Script