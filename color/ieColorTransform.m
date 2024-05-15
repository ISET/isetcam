function T = ieColorTransform(sensor,targetSpace,illuminant,surface)
% Gateway routine to transform sensor data into a target color space
%
% Synopsis
%  T = ieColorTransform(sensor,[targetSpace='XYZ'],[illuminant='D65'],[surface='Macbeth'])
%
% Brief
%   A gateway to a collection of methods that find color space
%   transformations to map sensor data into a target color space. This
%   routine currently has only a few defaults. It will expand over
%   time, significantly.  The calling conventions are likely to
%   change, as well.
%
% Input
%   sensor      - Defines the sensor QE
%   targetSpace - Target color space (ICS)
%   illuminant  - Default illuminant SPD
%   surface     - Surface collection to use for estimation
%
% Output
%   T - Transform from sensor space to target space
%
% Description
%  The default method is to find a linear transformation that maps the the
%  sensor responses to the Macbeth ColorChecker into the Macbeth
%  ColorChecker values in XYZ under D65 using a least-squares minimization.
%
%  Optionally, the user can send in a spectral file name that contains a
%  different surface set (surface) or a file name that contains a
%  different illuminant (illuminant).
%
%  An alternative is to find the linear transformation that minimizes the
%  transformation into linear sRGB values for the Macbeth Color Checker.
%  These values are stored in a file.  In the future, we will implement a
%  set of linear sRGB values for other sets of surfaces and lights, or at
%  least a method of calculating them in here on the fly, and performing
%  that minimization.
%
%  More elaborate alternatives will be included later.  These are an
%  alternative is to minimize a weighted sum of the mean error and the
%  noise error.  (Ulrich Barnhoefer, SPIE paper).
%
%  We will aso build more complex maps, based on the Manifold methods
%  and return a lookup table for the transformation. (Jeff DiCarlo, JOSA
%  paper)
%
% Examples:
%    sensor = vcGetObject('sensor');
%    T = ieColorTransform(sensor,'XYZ','D65','mcc')
%    T = ieColorTransform(sensor,'Stockman','D65','mcc')
%    T = ieColorTransform(sensor,'linear srgb',[],'mcc')
%    T = ieColorTransform(sensor,'XYZ','D65','esser')
%    T = ieColorTransform(sensor,'XYZ','D65','esser',1)
%
%  The returned transform can be applied as:
%    img = imageLinearTransform(img,T);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%

% Example:
%{
scene = sceneCreate;
sXYZ = sceneGet(scene,'xyz');

oi = oiCreate('wvf');
oi = oiCompute(oi,scene,'crop',true); 

sensor = sensorCreate('rgbw');
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
sensor = sensorSet(sensor,'noise flag',0);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

T  = ieColorTransform(sensor,'XYZ','D65','mcc');
ip = ipCreate;
ip = ipCompute(ip,sensor);
sensorXYZ = imageLinearTransform(ip.data.sensorspace,T);
%}

%% Parse
if ieNotDefined('targetSpace'), targetSpace = 'XYZ';          end
if ieNotDefined('illuminant'),  illuminant  = 'D65';          end
if ieNotDefined('surface'),     surface     = 'multisurface'; end

wave     = sensorGet(sensor,'wave');
sensorQE = sensorGet(sensor,'spectral QE');

%%
switch lower(targetSpace)
    case {'stockman','xyz'}
        % This transforms the sensor values into a calibrated space -
        % either XYZ or Stockman cone coordinates.  The linear transform is
        % derived by calculating the relationship between the sensor
        % quantum efficiency and the target space quantum efficiency.
        %
        % The linear transformation is chosen by optimizing the match for a
        % specific surface reflectance target under some illuminant.
        
        % Make case correct for filename
        if     isequal(lower(targetSpace),'xyz'),     targetSpace = 'xyz';
        elseif isequal(lower(targetSpace),'stockman'),targetSpace = 'stockman';
        end
        targetSpace = which(sprintf('%sQuanta.mat',targetSpace));
        targetQE = ieReadSpectra(targetSpace,wave);
        
        % This is where the transform is calculated        
        T = imageSensorTransform(sensorQE,targetQE,illuminant,wave,surface);
        
        % We should check that targetQE ~ sensorQE*T
        
    case {'linearsrgb','lrgb'}
        % Probably unused
        T = linearsrgb(sensorQE,illuminant,wave);
    case {'sensor'}
        % The internal space is sensor, so we just leave the data alone
        nSensor = sensorGet(sensor,'nSensors');
        T = eye(nSensor,nSensor);
    case 'manifold'
        warning('Not yet implemented -- Returning T = identity'); %#ok<WNTAG>
        T = eye(3,3);
    otherwise
        error('Unknown optimization method.');
end

% Compare the transformed sensor CMF with the internal color space (target)
% CMF
% figure; subplot(1,2,1), plot(sensorQE*T); subplot(1,2,2), plot(targetQE)

end

%----------------------------------------------
function T = linearsrgb(sensorQE,illuminant,wave)
% Probably unused.
%
% Calculate the linear transformation from sensor into linear sRGB values.
%
% We read the MCC values in sRGB space (linear RGB).  The patch order in
% this file is based on ImagEval history, not the official Macbeth
% definition.
%
% Probably, we should calculate the linear sRGB values for the set of
% surfaces that are sent in.  I think this is fairly straightforward and
% should be implemented soon.

error('linear srgb is used');

%  TODO
%  Instead of this code, though, we should be using the standard color
%  compute functions.
%

% patchSize = 1; patchList = 1:24;
% macbethChartObject = macbethChartCreate(patchSize,patchList);
% load('MCClRGB','lrgbValuesMCC','patchOrder');
if ieNotDefined('wave'), wave = 400:700; end    % nanometers

load('macbethChartLinearRGB','mcc');
idealMacbeth = mcc.lrgbValuesMCC;

% Get the MCC surface spectra and the illuminant.  Combine them to
% estimate the sensor responses.
% fName = fullfile(isetRootPath,'data','surfaces','macbethChart');
%
% surRef = ieReadSpectra(fName,wave);
surRef = macbethReadReflectance(wave);

% surRef = surRef(:,patchOrder);
illSpectra  = ieReadSpectra(illuminant,wave);

% Sensor RGB
sensorMacbeth = (sensorQE'*diag(illSpectra)*surRef)';

% Solve: sensorMacbeth*T = lrgbValuesMCC
T = pinv(sensorMacbeth)*idealMacbeth;

end
