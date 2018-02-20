function vci = vcimageSRGB(sceneName)
% Calculate an sRGB image (vci) of a scene using current oi and sensor
%
%   vci = vcimageSRGB([sceneName = 'macbethD65'])
%
% The sceneName can be any valid argument to sceneCreate. 
% 
% The scene is computed using the current oi and sensor.  If none exist,
% then the default oi and sensor are created and used. The sRGB image is
% created using an image processing step that has the properties:
%
%   'demosaicMethod','Adaptive Laplacian'
%   'colorBalanceMethod','Gray World'
%   'internalCS','XYZ'
%   'colorconversionmethod','MCC Optimized'
%
% Example:
%   vci = vcimageSRGB; vcReplaceObject(vci); ipWindow;
%   vci = vcimageSRGB('macbethD50'); ieAddObject(vci) ipWindow;
%   vci = vcimageSRGB('sweep'); ieAddObject(vci)
%   ipWindow;
%
%   resultSRGB = ipGet(vci,'result');
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sceneName'), sceneName = 'macbethD65'; end

% Create the scene
scene = sceneCreate(sceneName);

oi = vcGetObject('oi');
if isempty(oi), oi = oiCreate; end
oi = oiCompute(scene,oi);

% Create an XYZ sensor, I guess.  
sensor = vcGetObject('isa');
if isempty(sensor), sensor = sensorCreate; end

sensor = sensorSet(sensor,'size',[256,256]);
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'size',[3,3]*1e-6);
sensor = sensorSet(sensor,'pixel',pixel);
wave = sensorGet(sensor,'wave');
XYZ = ieReadSpectra('XYZ',wave);
sensor = sensorSet(sensor,'colorfilters',XYZ);
sensor = sensorCompute(sensor,oi);

vci = ipCreate;
vci = ipSet(vci,'demosaicMethod','Adaptive Laplacian');
vci = ipSet(vci,'colorBalanceMethod','Gray World');
vci = ipSet(vci,'internalCS','XYZ');
vci = ipSet(vci,'colorconversionmethod','MCC Optimized');

vci = ipCompute(vci,sensor);

return;

