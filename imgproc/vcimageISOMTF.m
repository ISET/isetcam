function vci = vcimageISOMTF(camera)
% Creates a slanted bar in the vcimage window for evaluating the ISO 12233
%
%   vci = vcimageISOMTF([camera]);
%
% The function creates a slanted bar scene.  Then, it uses the optics,
% sensor and image processing parameters to compute the vcimage.
%
% The camera is an optional structure that contains .oi, .sensor, and .vci.
% If the camera structure is not sent in a camera is created with the
% default oi, sensor and vci (image processing).
%
% The routine then invokes the ISO 12233 routine from within the vcimage
% window to produce the MTF figure.  The frequency and mtf data can be
% retrieved from the figure via
%
%  data = get(gcf,'userdata');
%
% Comment (and check!)
%   Frequency is specified in cycles/mm at the sensor surface.  This can be
%   converted into cycles per degree by calculating the sensor field of
%   view and sensor size (horizontal).  This gives deg/mm.
%
%     deg = sensorGet(sensor,'fov')
%     mm = sensorGet(sensor,'width','mm');
%     freqInCpd = data.freq*(mm/deg);
%     plot(freqInCpd,data.mtf)
%
%  Example:
%   camera.oi = vcGetObject('oi');
%   camera.sensor = sensorCreate;
%   vci = vcimageISOMTF(camera);
%
% Copyright ImagEval Consultants, LLC, 2005.


%% We create a version when there is a camera and when there isn't
if ieNotDefined('camera'), camera = cameraCreate; end

%% Create the test scene.
meanLuminance = 100;
scene  = sceneCreate('slanted edge',256);
scene  = sceneAdjustLuminance(scene,meanLuminance);
scene  = sceneSet(scene,'fov',5);

% Make sure the scene and sensor FOV match
sensor = cameraGet(camera,'sensor');
sensor = sensorSetSizeToFOV(sensor,5);
camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,scene);

% Compute and then return the vci
vci    = cameraGet(camera,'vci');
vci    = ipSet(vci,'name','iso12233');

end

