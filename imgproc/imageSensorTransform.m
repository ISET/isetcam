function T = imageSensorTransform(sensorQE,targetQE,illuminant,wave, method)
% Calculate sensor -> target linear transformation 
%
%  T = imageSensorTransform(sensorQE, targetQE,illuminant,wave, method)
%  
% sensorQE:   A matrix with columns containing the sensor spectral quantum
%             efficiencies. 
% targetQE:   A matrix with columns containing the spectral quantum efficiency
%             of the viewer; normally the human visual system (XYZ) but it
%             could be something else, such as an ideal camera. 
% illuminant: The name of the illuminant spectral power distribution.
%             Can be a vector of length(wave) or a name. Default is 'D65'
% wave:       The sample wavelengths
% method:     Indicates the estimation method, which decides on the sample
%             surfaces and perhaps other choices
%
% The routine computes a nSensor x nTargetspace transform, T, to convert
% from sensor space to target space. 
%
%  The returned transform can be applied as:
%
%            img = imageLinearTransform(img,T);
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2005.

%% PROGRAMMING TODO:
%  We should have a variety of ways of computing this linear transform,
%  including methods that account for known noise, use ridge methods,
%  search to minimize deltaE, and perhaps others.
%

%% Check arguments
if ieNotDefined('illuminant'), illuminant = 'D65'; end
if ieNotDefined('wave'), wave = 400:10:700; end
if ieNotDefined('method'), method = 'multisurface'; end

%% Read the MCC surface spectra and a target illuminant, say D65. 
if ischar(illuminant)
    % String was sent in
    ill = illuminantCreate(illuminant,wave); 
    illQuanta = illuminantGet(ill,'photons');
else 
    % Data were sent in
    illQuanta = illuminant;
end

% The method mostly defines the surfaces at this point.  In the future, it
% might do more, I hope.
method = ieParamFormat(method);
switch method
    case {'mccoptimized','mcc'}
        % fullfile(isetRootPath,'data','surfaces','macbethChart');
        fName  = which('macbethChart.mat'); 
        surRef = ieReadSpectra(fName,wave);
    case {'esseroptimized','esser'}
        % fullfile(isetRootPath,'data','surfaces','esserChart');
        fName = which('esserChart.mat');   
        surRef = ieReadSpectra(fName,wave);
    case {'multisurface'}
        surRef = ieReflectanceSamples([],[],wave);
    otherwise
        error('Unknown method %s\n',method);
end

%% Predicted sensor responses
%
% The sensorMacbeth is an XW format, nSurface x nSensor
sensorMacbeth = (sensorQE'*diag(illQuanta)*surRef)';

% These are the desired sensor responses to the surface reflectance
% functions under the illuminant in the internal color space. The target
% space should be correct for a photon (quanta) representation of the data.
% That is, targetQE should be something like XYZQuanta or stockmanQuanta.
% It will typically be nSurfacer x nTargetDims
targetMacbeth = (targetQE'*diag(illQuanta)*surRef)';

% This is the linear transformation that maps the sensor values into the
% target values, as illustrated in the comment below.  Should be calculated
% with a backslash, not this way.  Also, should deal with noise
% characteristics if possible.

% T = pinv(sensorMacbeth)*targetMacbeth;
T = sensorMacbeth \ targetMacbeth;

%% Test code
% pred = sensorMacbeth*T; 
% predImg = XW2RGBFormat(pred,6,4);
% figure; title('mcc')
% subplot(1,2,1), imagescRGB(imageIncreaseImageRGBSize(predImg,20));
% desiredImg = XW2RGBFormat(targetMacbeth,6,4);
% subplot(1,2,2),imagescRGB(imageIncreaseImageRGBSize(desiredImg,20));
% figure; plot(pred(:),targetMacbeth(:),'.'); grid on

end
