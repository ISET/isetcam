function T = imageSensorTransform(sensorQE,targetQE,illuminant,wave, surfaces, whitept)
% Calculate sensor -> target linear transformation
%
% Synopsis
%  T = imageSensorTransform(sensorQE, targetQE,illuminant,wave, surfaces, whitept)
%
% Inputs
% sensorQE:   A matrix with columns containing the sensor spectral quantum
%             efficiencies.
% targetQE:   A matrix with columns containing the spectral quantum efficiency
%             of the viewer; normally the human visual system (XYZ) but it
%             could be something else, such as an ideal camera.
% illuminant: The name of the illuminant spectral power distribution.
%             Can be a vector of length(wave) or a name. Default is 'D65'
% wave:       The sample wavelengths.  Default 400:10:700
% surfaces:   Indicates which sample surfaces (mcc, esser, multisurface)
% whitept:    Force T to map the illuminant in the sensor space to the
%             1-vector in the target space.  For XYZ, this is a
%             chromaticity of 0.333,0.333.  (Logical, default: false).
%
% Output
%  T:         The nChannels x 3 linear transform
%
% Description
%  The routine computes a nChannels x nTargetspace transform, T, to
%  convert from sensor space to target space.
%
%  The linear transform maps data in sensor space, a row vector, into
%  target space
%
%    targetVec = rowVec * T
%
% Equivalently, if we have the QE of the sensor and target channel
% quantum efficients, then
%
%    targetQE = sensorQE * T
%
%  The returned transform, T, can be applied to image data (r,c,w) using:
%
%    img = imageLinearTransform(img,T);
%
%  In some cases, such as for an RGBW, we sometimes require that
%
%     [sensorLight]*T = [1 1 1]
%
% where sensorLightis the sensor response to the light source.  That
% is the purpose of the whitept parameter, recently added to
% ip.render.whitept.  I suppose we might allow whitept to be a vector
% in the target space some day (BW).
%
% The current implementation is trivial; in practice, the selection of
% the transformation can be much more nuanced.  ZL has been training
% small networks for this.
%
% See also
%   ieColorTransform, imageSensorCorrection, ipCompute
%

% Example
%{
s = sensorCreate('rgbw');
sensorQE = sensorGet(s,'spectral qe');
wave = sensorGet(s,'wave');
targetQE = ieReadSpectra('xyzQuanta',wave);

T = imageSensorTransform(sensorQE,targetQE,'',wave, 'mcc');
pred = sensorQE*T;
ieNewGraphWin; plot(wave,pred,'--',wave,targetQE,'k-');

% Compare to the straight pseudoinverse calculation, without the
% illuminant
% targetQE = sensorQE*A, so 
A = pinv(sensorQE)*targetQE;
pred = sensorQE*A;
ieNewGraphWin; plot(wave,pred,'--',wave,targetQE,'k-');
%}

%% PROGRAMMING

% Check the end for some code that validates whether the transform, T,
% does about the right thing.
%
%  We should have a variety of ways of computing this linear transform
%  including methods that account for known noise, use ridge methods
%  search to minimize deltaE, and perhaps others.
%

%% Check arguments
if ieNotDefined('illuminant'), illuminant = 'D65'; end
if ieNotDefined('wave'), wave = 400:10:700; end
if ieNotDefined('surfaces'), surfaces = 'multisurface'; end
if ieNotDefined('whitept'), whitept = false; end

%% Read the MCC surface spectra and a target illuminant, say D65.
if ischar(illuminant)
    % String was sent in
    ill = illuminantCreate(illuminant,wave);
    illQuanta = illuminantGet(ill,'photons');
else
    % Data were sent in
    illQuanta = illuminant;
end

% The method is based on finding a linear transformation fits the
% sensor response, for a selection of surfaces under a specific light,
% to the XYZ value under that light. Here we read which surface
% reflectances.
surfaces = ieParamFormat(surfaces);
switch surfaces
    case {'mccoptimized','mcc'}
        % fullfile(isetRootPath,'data','surfaces','macbethChart');
        fName  = which('macbethChart.mat');
        surRef = ieReadSpectra(fName,wave);
    case {'esseroptimized','esser'}
        % fullfile(isetRootPath,'data','surfaces','esserChart');
        fName = which('esserChart.mat');
        surRef = ieReadSpectra(fName,wave);
    case {'multisurface'}
        % By default, returns 96 surfaces.
        surRef = ieReflectanceSamples([],[],wave);
    otherwise
        error('Unknown method %s\n',surfaces);
end

%% Predicted sensor responses

% The sensorResponse is an XW format, nSurface x nChannels
sensorResponse = (sensorQE'*diag(illQuanta)*surRef)';

% These are the desired sensor responses to the surface reflectance
% functions under the illuminant in the internal color space. The target
% space should be correct for a photon (quanta) representation of the data.
% That is, targetQE should be something like XYZQuanta or stockmanQuanta.
% It will typically be nSurfacer x nTargetDims
targetResponse = (targetQE'*diag(illQuanta)*surRef)';

% This is the linear transformation that maps the sensor values into the
% target values, as illustrated in the comment below.  Should be calculated
% with a backslash, not this way.  Also, should deal with noise
% characteristics if possible.

% Find the linear transform that maps the sensor data into the target
% space.
%
% targetResponse = sensorResponse * T
T = sensorResponse \ targetResponse;

if whitept
    % Force the returned transform, T, to map the the 1-vector in the
    % sensor to the illuminant value (scaled).  Worked out in
    % s_autoLightGroups (isetauto).
    sensorLight = illQuanta'*sensorQE;
    sensorLight = sensorLight / max(sensorLight);
    sensorWhite = sensorLight*T;
    
    % Forces T to satisfy sensorLight * T = ones
    T = T * diag( 1 ./ sensorWhite);
end

%% Test code
%{
pred = sensorResponse*T;
predImg = XW2RGBFormat(pred,4,6);
ieNewGraphWin([],'tall'); 
subplot(3,1,1), imagescRGB(imageIncreaseImageRGBSize(predImg,20));
desiredImg = XW2RGBFormat(targetResponse,4,6);
subplot(3,1,2), imagescRGB(imageIncreaseImageRGBSize(desiredImg,20));
subplot(3,1,3), plot(pred(:),targetResponse(:),'.'); grid on; 
axis square; identityLine;
%}
end
