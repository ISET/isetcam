%% s_sensorMacbethEstimateIlluminant
%
% It is possible to use sensor measurements of an MCC to estimate a
% daylight illuminants.  This script illustrates the logic of the
% calculation.  We also wrote a function that implements this calculation
% starting from a sensor image with an MCC image in it.
%
% There are 3 daylight basis functions and we aim to estimate three weights
% for those functions.  We can express the predicted camera data,C, for the
% MCC this way:
%
%     C = sum w_i SQE * diag(dayBasis_i) * MCC
%
% where 
%    C are the RGB values of the sensor (3 x 24) 
%    SQE is the spectral quantum efficiency of the camera, 
%    dayBasis_i is the ith basis function of the cie daylights, 
%    MCC columns are the reflectance functions of the Macbeth Color Checker. 
%
% See also
%        sensorMacbethDaylightEstimate(sensor,varargin);
%

%%  Read the reflectance functions of the MCC

wave = 400:10:700;
reflectance = macbethReadReflectance(wave);
% plotReflectance(wave,reflectance);

%% Pick the default sensor

sensor = sensorCreate;
sensorFilters = sensorGet(sensor,'spectral qe');
% ieNewGraphWin; plot(wave,sensorFilters);

%%  These are the CIE basis functions for daylights

% Read the daylight basis, which is specified in energy.  Convert the basis
% terms to photons because we normally compute with photons in ISETCam.
dayBasis = ieReadSpectra('cieDaylightBasis.mat',wave); 
dayBasis = Energy2Quanta(wave,dayBasis);
% plotRadiance(wave,dayBasis);

%%  Make up a set of weights for the illuminant
illuminant = illuminantCreate;

w = [1 0 0];
illuminant = illuminantSet(illuminant,'photons',dayBasis*w');
illPhotons = illuminantGet(illuminant,'photons');
% plotRadiance(wave,illPhotons); 

%% Calculate the sensor data

C = sensorFilters'*diag(illPhotons)*reflectance;

%% Estimation process

% There are three basis functions so the camera data, in the 3x24 matrix C,
% should be the weighted sum of these three matrices.
X1 = sensorFilters'*diag(dayBasis(:,1))*reflectance;
X2 = sensorFilters'*diag(dayBasis(:,2))*reflectance;
X3 = sensorFilters'*diag(dayBasis(:,3))*reflectance;

%% Stack the three matrices 

% Each matrix is a big column
X = [X1(:), X2(:), X3(:)];

% Stack the camera data into a big column
Cstacked = C(:);

%% The weights are supposed to solve this:
%
%     Cstacked = X w
%

% We solve for w this way.
%    w =  inv(X'*X) * X' * Cstacked

% Or in Matlab's preferred formulation
A = X'*X;
b = X'*Cstacked;
estimatedW = A\b;
estimatedW = estimatedW/estimatedW(1);
disp(estimatedW)

%% END

