function [T, actual, desired, whiteCMF] = imageSensorConversion(sensor,CMF,surfaces,illuminant)
% Return the linear transform from sensor catch to desired representation
%
%  [T, actual, desired, whiteCMF] = imageSensorConversion(sensor,CMF,surfaces,illuminant)
%
% The transformation, T, converts sensor data into the CMF representation.
%
%      correctedData(3xN) = T(3x3) * actualData(3xN)
%
% Inputs
%  sensor:      Sensor structure
%  CMF:         Color matching functions for space
%  surfaces:    surface reflectance functions
%  illuminant:  SPD of the illuminant
%
% Returns
%  T:         The matrix that converts the sensor spectralQE into the desired
%             (CMF) values.
%  actual:    The sensor responses to the surfaces under an illuminant
%  desired:   The CMF values of the surfaces under an illuminant
%  whiteCMF:  The CMF value to a white reflectance.  Useful for CIE
%             calculations
%
% See also: s_ipSensorConversion, imageSensorCorrection
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Argument checking
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
wave = sensorGet(sensor,'wave');

if ieNotDefined('CMF'), CMF = ieReadSpectra('XYZ.mat',wave); end
if ieNotDefined('surfaces'), error('Surfaces required'); end %Macbeth?
if ieNotDefined('illuminant'), error('Illuminant required'); end % D65?

%% Find the T based on the sensor spectral QE
spectralQE = sensorGet(sensor,'spectralQE');

% We should get noise in here somehow (Wiener calculation, or robust)
actual  = spectralQE'*diag(illuminant)*surfaces;
desired = CMF'*diag(illuminant)*surfaces;

% Matrix inversion - no correction for noise or white weighting
% desired = T*actual
T = desired / actual;

% predicted = T*actual;
% plot(desired(:),predicted(:),'.')

if nargout >= 4
    whiteCMF = CMF'*diag(illuminant)*ones(length(wave),1);
end

return

