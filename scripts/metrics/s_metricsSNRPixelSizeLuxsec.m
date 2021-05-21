%% How parameters influence pixel signal-to-noise ratio (SNR)
%
% The *pixel SNR* is specified as
%
%     10*log10(sigPower / noisePower )
%
% Here, we calculate the effective of pixel size on SNR.
%
% Definitions
%
% *sigPower* :    The signal power at any voltage is the square of
% the number of electrons at that voltage.  Signal variance is
% Poisson and thus the signal variance equals the number of
% electrons at each voltage (i.e., the square root of the signal
% power).
%
% *noisePower* :  The noise power is the sum of the signal variance
% and the read noise variance. The read noise variance is a
% parameter of the technology.
%
% For each technology, the SNR varies as a function of the pixel
% voltage level.  The precise SNR depends on factors like the
% dark voltage. In general, as the pixel voltage  increases, the
% SNR also increases.
%
% To compute *pixel SNR* , we use pixel signal and noise specified
% in units of electrons (see pixelSNR).  This is important
% because the Poisson character of the noise is only true in
% units of electrons, but not in units of volts (the Poisson
% distribution is not invariant with respect to scaling).
%
% See also: pixelSizeSNRvolts, pixelSNRluxsec
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Sensor Parameters:

% You can set the parameters here according to your technology
% properties Each pixel size has associated noise
integrationTime = 0.010;                      % Sec
pixelSize    = [2 4 6 9 10]*1e-6;             % Pixel size in meters
readNoiseSD  = [5 4 3 2 1]*1e-3;              % std dev in volts
voltageSwing = [.7 1.2 1.5 2 3];              % voltage swing
darkVoltage  = [1 1 1 1 1]*1e-3;              % Volts per sec

%% Create a monochrome sensor

sensor = sensorCreate('monochrome');                %Initialize
sensor = sensorSet(sensor,'integrationTime',integrationTime);

%% Vary pixel size

clear SNR;
clear luxsec;

pixel  = sensorGet(sensor,'pixel');
SNR = cell(1,length(pixelSize));
luxsec = cell(1,length(pixelSize));
for ii=1:length(pixelSize)
    pixel = pixelSet(pixel,'size constant fill factor',[pixelSize(ii),pixelSize(ii)]);
    pixel = pixelSet(pixel,'readNoiseSTDvolts',readNoiseSD(ii));
    pixel = pixelSet(pixel,'voltageSwing',voltageSwing(ii));
    pixel = pixelSet(pixel,'darkVoltage',darkVoltage(ii));
    
    sensor = sensorSet(sensor,'pixel',pixel);
    [SNR{ii},luxsec{ii}] =  pixelSNRluxsec(sensor);
end

% The data were saved in the cell arrays SNR{} and luxsec{}.
% Here we make a summary plot.
vcNewGraphWin;
c = {'r','g','b','c','m','y','k'};
txt = cell(1,length(SNR));
for ii=1:length(SNR)
    semilogx(luxsec{ii},SNR{ii},['-',c{ii}])
    hold on;
    txt{ii} = sprintf('%.0f um',pixelSize(ii)*10^6);
end
xlabel('Lux-sec'), ylabel('SNR (db)'); title('SNR vs. Lux-sec')
grid on
legend(txt);

%%