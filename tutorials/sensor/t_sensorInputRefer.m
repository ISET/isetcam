%% Calculate the mean absorption count at a detector
%
% Then illustrate how to set the scene luminance of a uniform, equal energy
% scene to achieve any specified absorption rate.
%
% Conversely, when we know the number of electrons in a particular type of
% pixel, we can estimate the illuminance of an equal energy light at the
% sensor, or the luminance of an equal energy light in the scene, prior to
% the optics.
%
% Copyright Imageval Consulting, LLC 2015
%
% See also:
%    signalCurrent, poissrnd, getMiddleMatrix
%

%%
ieInit

%% A target photon absorption rate for the sensor
targetCount = 3;

fprintf('Adjusting to a target mean count of %.4f\n',targetCount);

%%  Calculate the photon absorption rate for a 1 cd/m2 at 1 sec

s = sceneCreate('uniform ee');
lum = 1;
s = sceneAdjustLuminance(s,lum);  % 1 cd/m2

oi = oiCreate;
oi = oiCompute(oi,s);

sensor = sensorCreate('monochrome');
noiseFlag = 1;
sensor = sensorSet(sensor,'noise flag',noiseFlag);
sensor = sensorSet(sensor,'exp time',1);

%% Calculate the mean photon absorption rate from the oi and sensor

% This is a form of the code from signalCurrent.m
q = vcConstants('q');     %Charge/electron

% signalCurrent estimates volts, like this.  We want current to electrons
% (which for the human case is current to photons)
%
% Convert current (Amps) to volts
% Check the units:
%    S * (V / e) * (Coulombs / e)^-1   % https://en.wikipedia.org/wiki/Coulomb
%     = S * (V / e) * (( A S ) / e) ^-1
%     = S * (V / e) * ( e / (A S)) = (V / A)
%    c2v = sensorGet(sensor,'integrationTime')*sensorGet(sensor,'pixel conversion gain') / q;
%
%   S * (Coulombs / e)^-1
%    = S * ( A S / e)^-1
%    = e / A
c2e = sensorGet(sensor,'integration time')/ q;

% Signal current returns Amps/pixel/sec
%   c2e * Amps/pixel/sec
%     = (e/A) * (A/pixel/sec)
%     = e / pixel / sec
eImage = c2e*signalCurrent(oi,sensor);

fprintf('Initial electron count:  %.4f \n',mean(eImage(:)))

%%  The ISET calculation produces the same mean rate

sensor = sensorCompute(sensor,oi);

% Get the electrons from the first pixel type
electrons = sensorGet(sensor,'electrons');

% In the middle of the image to avoid the edges
electrons = getMiddleMatrix(electrons,[40,40]);

% This is the Photon absorptions per exposure (which is 1 sec)
eCount = mean(electrons(:));

% ieAddObject(oi); ieAddObject(sensor);
% oiWindow; sensorImageWindow;

%% Adjust the scene luminance

% Scale the scene luminance
newLum = lum * (targetCount/eCount);
fprintf('Adjusting the scene luminance to %e cd/m^2\n',newLum);
s = sceneAdjustLuminance(s,newLum);  % 1 cd/m2

%% Compute the electron count at the new scene luminance level

oi = oiCompute(oi,s);
fprintf('Through the optics the illuminance is %e lux\n',oiGet(oi,'mean illuminance'));

sensor = sensorCompute(sensor,oi);
electrons = sensorGet(sensor,'electrons',1);

% Photon absorptions per exposure
fprintf('Adjusted electron count %e\n',mean(electrons(:)))

c2e = sensorGet(sensor,'integration time')/ q;

% Signal current returns Amps/pixel/sec
%   c2e * Amps/pixel/sec
%    = (e/A) * (A/pixel/sec)
%    = e / pixel / sec
eImage = c2e*signalCurrent(oi,sensor);

fprintf('Direct calculation of electron count:  %.4f (target = %.4f)\n',mean(eImage(:)),targetCount)

%% Histogram of photon numbers and expected Poisson distribution

ieNewGraphWin;
xval = 0:(targetCount + 3*sqrt(targetCount));
h = histogram(electrons(:),xval,'Normalization','probability');
h.FaceColor = [0 .3 1];
h.EdgeColor = [0 0 0];

hold on;
y = poisspdf(xval,targetCount);
plot(xval + 0.5,y,'r-o','LineWidth',2);
xlabel('Electron count'); ylabel('Probability')

title(sprintf('Electron distribution (mean %.3f)',mean(eImage(:))));
legend({'Count','Poisson pdf'});
grid on

%%
