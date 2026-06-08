%% s_sensorPixelReadNoise
%
%   Illustrate an experimental approach to measuring pixel read noise.
%
% The method is described in the paper by Farrell, Feng and Kavusi. We
% simulate a large number of short exposure durations to a black scene. The
% distribution of values to these short reads (mean and sd) define the read
% noise.  At these short times there is no dark voltage and the scene is
% black.  So read noise is all that is left to measure.
%
% There are some possible problems, however.  In particular, when the data
% are clipped at 0 the statistic is mis-estimated.  To avoid this in the
% current simulation, we use a small analog offset (which is present in
% many sensors).  You can try setting this to 0 to see the problems that
% can arise due to clipping.
%
% Under those conditions, the smallest values are clipped and the estimated
% std dev is smaller than the true read noise.  If we lift the image out of
% the darkness to a positive value, then we have photon noise.  But for
% large read noise levels, that dominates and we get an accurate estimate.
% It is hard to know where the right level is, though.  In this script, a
% mean luminance of 100 gets a good estimate, but 10 does not.
%
% Experiment to see how the methods interact with other noise terms.
%
% Also, notice that if the read noise gets too large, we clip again. Too
% many little interactions for a beautiful theory.
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Experiment with sensor and pixel parameters
dsnuLevel = 0.0;        % Std. dev. of offset in volts
prnuLevel = 0.0;        % Std. dev of gain, around 1, as a percentage
readNoise = 0.003;      % Read noise in volts
analogOffset = 0.005;   % Analog offset (5 mv)

% Set a brief exposure time for DSNU estimation.  Because of the short
% exposure, the PRNU level is irrelevant.  The read noise can matter.  If
% it is very large, you must average over more trials.
expTime = 0.001;

% We acquire the image multiple times so we can average out the read noise
nRepeats = 25;
meanL    = 100;

%% Make a black scene and a sensor
scene = sceneCreate('uniformee');
darkScene = sceneAdjustLuminance(scene,meanL);

oi = oiCreate('default',[],[],0);

sensor = sensorCreate;
sensor = sensorSet(sensor,'size',[128 128]);

% Set scene to be larger than the sensor field of view.
darkScene = sceneSet(darkScene,'fov',sensorGet(sensor,'fov')*1.5);

% Compute optical image
darkOI = oiCompute(oi,darkScene);

% Set up sensor parameters
sensor = sensorSet(sensor,'DSNU level',dsnuLevel);
sensor = sensorSet(sensor,'PRNU level',prnuLevel);
sensor = sensorSet(sensor,'Analog offset',analogOffset);
pixel  = sensorGet(sensor,'pixel');
pixel  = pixelSet(pixel,'Read noise volts',readNoise);
sensor = sensorSet(sensor,'pixel',pixel);
sensor = sensorSet(sensor,'Exposure Time',expTime);

%%  Acquire multiple short exposures of the dark image
clear volts

nSamp = prod(sensorGet(sensor,'size'))/2;
volts = zeros(nSamp,nRepeats);

for ii=1:nRepeats
    sensor = sensorCompute(sensor,darkOI,0);
    % The G pixels are in the rows.  Multiple reads across the columns.
    volts(:,ii) = sensorGet(sensor,'volts',2);
end
% ieAddObject(sensor); sensorImageWindow;

%% Estimate the standard deviation at each pixel.

% The std at each pixel.
pSTD = std(volts,[],2);

% The histogram is the distribution of the estimated pixel read noises
ieNewGraphWin;
histogram(pSTD,50)
grid on;

title(sprintf('Variation in repeated reads (N=%d)',nRepeats))
xlabel('Standard deviation (volts)')
ylabel('Number of pixels')

% Print it out for comparison
fprintf('---------------------------\n')
fprintf('Read noise:  Estimated: %.3f and Set %.3f\n',median(pSTD), readNoise);
fprintf('---------------------------\n')
%% End
