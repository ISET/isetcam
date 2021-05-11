%% Compute the acutance of a camera object.
%
% To simplify the code we often use the *camera object* to keep
% track of the different objects. It has slots for optics (oi)
% and the sensor and the image processor (ip).
%
% The *acutance metric* depends on the optics and sensor, but not
% the image processing steps.
%
% See also:  cameraCreate, cameraMTF, ISOAcutance,
% s_metricsColorAccuracy
%
% Copyright ImagEval Consultants, LLC, 2012.

%%
ieInit

%% Initialize the virtual camera.

% We illustrate the process at first by starting with the defaults.
camera = cameraCreate;
camera = cameraSet(camera, 'sensor auto exposure', true);
camera = cameraSet(camera, 'optics fnumber', 4);

%% Slanted edge MTF test

cMTF = cameraMTF(camera);

% This is the MTF in cpd for the luminance
lumMTF = cMTF.mtf(:, 4);

% ieAddObject(cMTF.vci); ipWindow

%% Compute acutance

% cycles/mm is the default for the ISO12233 MTF.  We would like to compute
% cy/deg, which is related by cpd = (cycles/mm) *(1/degPerMM)
% For the sensor, degrees is related to distance on the sensor with respect
% to the focal distance to the optics.
oi = cameraGet(camera, 'oi');
degPerMM = cameraGet(camera, 'sensor h deg per distance', 'mm', [], oi);
cpd = cMTF.freq / degPerMM;

% The CPIQ is a representation of someone's idea of the human contrast
% sensitivity function.  The camera MTF is a representation of what the
% camera sees.  To compute acutance we need the cpiq and the camera MTF.
% Here, we plot the MTF and the cpiq, and then we calculate the acutance
% inside the function below.  We put this in the title of the figure.
vcNewGraphWin;
cpiq = cpiqCSF(cpd);
plot(cpd, cpiq, '-k', cpd, lumMTF, '--r');
grid on;
hold on;
xlabel('Cycles per degree');
ylabel('SFR');

% Acutance is an ISO Standard.
Acutance = ISOAcutance(cpd, lumMTF);
title(sprintf('Acutance %.2f', Acutance))

legend('CPIQ', 'Camera MTF')

%%
