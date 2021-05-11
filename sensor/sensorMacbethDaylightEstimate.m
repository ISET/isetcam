function [illPhotons, cp, wgts, Cstacked, X] = sensorMacbethDaylightEstimate(sensor, varargin)
% Use sensor data with an MCC to estimate a daylight illuminant
%
%   There is currently a bug relating to photons/energy representation of
%   the daylight.  Some more work needed to compare
%
% Synopsis
%   [illPhotons,cp,wgts] = sensorMacbethDaylightEstimate(sensor,varargin)
%
% Inputs
%   sensor - An ISETCam sensor struct that contains an MCC in the image
%            data and all the sensor parameters
%
% Optional key/value pairs
%   cp -  Corner points of the MCC
%
% Outputs
%   illPhotons - Estimated illuminant (photons)
%   cp         - Corner points of the MCC
%   wgts       - Daylight basis weights w.r.t. daylightBasis in photons
%
% Description:
%   The logic of the calculation is explained in detail in the script
%   s_sensorMacbethEstimateIlluminant.  Briefly, we solve for the weights
%   of the daylight basis functions that best describe the measured sensor
%   data from the MCC.
%
% ieExamplesPrint('sensorMacbethDaylightEstimate');
%
% See also
%   s_sensorMacbethEstimateIlluminant

% Examples:
%{
% User selects cornerpoints of the MCC
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
fov = sceneGet(scene,'fov');
sensor = sensorCreate; sensor = sensorSet(sensor,'fov',fov,oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);
[illPhotons,cp,wgts] = sensorMacbethDaylightEstimate(sensor);
plotRadiance(sensorGet(sensor,'wave'),illPhotons);
%}
%{
% When you know the corner points you can run this code.

% Create a scene and set its illuminant to be the first daylight
% component
scene = sceneCreate;
wave = sceneGet(scene,'wave');
dayBasis = ieReadSpectra('cieDaylightBasis.mat',wave);
wgts = [1,-1,0.3]';
% Impomrtant to use this, not sceneSet()
scene = sceneAdjustIlluminant(scene,dayBasis*wgts,true);
sceneWindow(scene);

% Build the sensor data
oi = oiCreate; oi = oiCompute(oi,scene);
fov = sceneGet(scene,'fov');
sensor = sensorCreate; sensor = sensorSet(sensor,'fov',fov,oi);
sensor = sensorSet(sensor,'noise flag',1);
sensor = sensorCompute(sensor,oi);

% Estimate the daylight, should have weights as above
cp = [1   180
241   182
240    19
2    20];
[illPhotonEstimate,tst,wgtsEstimate] = sensorMacbethDaylightEstimate(sensor,'corner points',cp);
illPhotons = sceneGet(scene,'illuminant photons');
ieNewGraphWin; plot(wave,ieScale(illPhotonEstimate,1),'r-',wave,ieScale(illPhotons,1),'k-');
set(gca,'ylim',[ 0 1]);
wgts, wgtsEstimate
%}

%% Input

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('sensor', @(x)(isequal(x.type, 'sensor')));
p.addParameter('cornerpoints', [], @isnumeric);
p.addParameter('patchsizefraction', 0.4, @(x)(x < 1 && x > 0));

p.parse(sensor, varargin{:});
cp     = p.Results.cornerpoints;
psizef = p.Results.patchsizefraction;

%% Deal with the rects on the MCC chart

if isempty(cp)
    cp = chartCornerpoints(sensor);
    [rects, mlocs, pSize] = chartRectangles(cp, 4, 6, psizef);
else
    [rects, mlocs, pSize] = chartRectangles(cp, 4, 6, psizef);
end

% Show the user
recthdl = chartRectsDraw(sensor, rects);
pause(1); delete(recthdl)

% Now we have the 24 x 3 RGB values from the MCC
delta = round(psizef*pSize(1));
C = chartRectsData(sensor, mlocs, delta, false, 'electrons');
C = C';
Cstacked = C(:);

%% Calculation starts here by getting the key data

% Convert the illuminant data to a photon basis
wave = sensorGet(sensor, 'wave');
dayBasis = ieReadSpectra('cieDaylightBasis.mat', wave);
dayBasis = Energy2Quanta(wave, dayBasis);

reflectance = macbethReadReflectance(wave);
sensorFilters = sensorGet(sensor, 'spectral qe');

%{
% We compare the sensor data, C, with the expected values using the
% calculation on line below for X1/2/3
illPhotons = sceneGet(scene,'illuminant photons');
Ccheck = (sensorFilters'*diag(illPhotons)*reflectance)';
Ccheck = ieScale(Ccheck,1)*max(C(:));
ieNewGraphWin; plot(Ccheck(:),C(:),'o'); grid on; identityLine;
%}

%% Calculate the three matrices for the daylight basis

% There are three basis functions so the camera data, in the 3x24 matrix C,
% should be the weighted sum of these three matrices.
X1 = sensorFilters' * diag(dayBasis(:, 1)) * reflectance;
X2 = sensorFilters' * diag(dayBasis(:, 2)) * reflectance;
X3 = sensorFilters' * diag(dayBasis(:, 3)) * reflectance;

% Stack the three matrices
X = [X1(:), X2(:), X3(:)];

%% The daylight basis weights are supposed to solve this linear equation
%
%     Cstacked = X w
%

% We solve for w this way.
%    w =  inv(X'*X) * X' * Cstacked

% Or in Matlab's preferred formulation
A = X' * X;
b = X' * Cstacked;
wgts = A \ b;
wgts = wgts / wgts(1);

illPhotons = dayBasis * wgts;
% plotRadiance(wave,illPhotons);
%
end
