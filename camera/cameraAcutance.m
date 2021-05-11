function acutance = cameraAcutance(camera, plotFlag)
%Compute and possibly plot the acutance of a camera using CPIQ formula
%
%   acutance =  cameraAcutance(camera,plotFlag)
%
% Input:
%   camera: A camera model
%   plotFlag:  Put up a graph (or not) of the CPIQ and Camera MTF
%
% Runs ISOAcutance
%
% Returns
%   Acutance, and it may produce a plot showing the CPIQ MTF along with the
%   camera MTF.  The acutance is the camera MTF weighted by the CPIQ MTF.
%
% Example:
%   camera = cameraCreate;
%   cameraAcutance(camera)
%   cameraAcutance(camera,false)
%
%   camera = cameraCreate('monochrome');
%   cameraAcutance(camera)
%
% See also: cameraMTF, s_metricsAcutance
%
% Copyright Imageval LLC, 2014

%%
if ieNotDefined('camera'), error('camera required'); end
if ieNotDefined('plotFlag'), plotFlag = true; end

%% Compute acutance

% First, compute the MTF.  Get the luminance term.
cMTF = cameraMTF(camera);
if size(cMTF.mtf, 2) == 4
    lumMTF = cMTF.mtf(:, 4);
elseif size(cMTF.mtf, 2) == 1
    lumMTF = cMTF.mtf;
else
    error('Unexpected cMTF %f', cMTF);
end

% cycles/mm is the default for the ISO12233 MTF.  We would like to compute
% cy/deg, which is related by cpd = (cycles/mm) *(1/degPerMM)
% For the sensor, degrees is related to distance on the sensor with respect
% to the focal distance to the optics.
sensor   = cameraGet(camera,'sensor');
oi = cameraGet(camera, 'oi');
degPerMM = sensorGet(sensor, 'h deg per distance', 'mm', [], oi);
cpd = cMTF.freq / degPerMM;

% Acutance is an ISO Standard.
acutance = ISOAcutance(cpd, lumMTF);

% The CPIQ is a representation of someone's idea of the human contrast
% sensitivity function.  The camera MTF is a representation of what the
% camera sees.  To compute acutance we need the cpiq and the camera MTF.
% Here, we plot the MTF and the cpiq, and then we calculate the acutance
% inside the function below.  We put this in the title of the figure.
if plotFlag
    vcNewGraphWin;
    cpiq = cpiqCSF(cpd);
    plot(cpd, cpiq, '-k', cpd, lumMTF, '--r');
    grid on;
    hold on;
    xlabel('Cycles per degree');
    ylabel('SFR');
    title(sprintf('Acutance %.2f', acutance))
    legend('CPIQ', 'Camera MTF')
end

%% End