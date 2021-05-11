function [camera, img] = cameraCompute(camera, pType, mode, sensorResize)
% Compute an image of a scene using a camera model
%
%   [camera,img] = cameraCompute(camera,pType,mode,sensorResize)
%
% Start with a camera structure and compute from the scene to the oi to the
% sensor and ip.  The returned camera object has the updated objects.  To
% open a window showing the different structures, use cameraWindow().
%
% INPUTS:
%  camera: Camera object
%  pType:  Indicates where to start the processing.
%          If pType is a scene structure, then we begin with the scene If
%          pType is a string 'oi' or 'sensor' we begin with the data in
%          those structures.
%  mode:
%   'normal'    - Typical calculation from scene -> oi -> sensor -> ip
%                 At the end of the calculation, the result field in the ip
%                 contains an sRGB image?  Or an lRGB image?
%   'ideal xyz' - Replaces the sensor with an ideal (noise-free) sensor
%                 that has XYZ filters.
%  sensorResize - True (default) or false By default, we adjust the sensor
%                 size to match the scene field of view.
%
% The calculations for each of the objects remain in those objects within
% the camera structure.  This allows us to call the routine again, but
% start from those structures.
%
% RETURN
%   img:  This contains the linear RGB display values.  To check ... are
%   these lrgb?  or sRGB?  or Are they the rgb for the particular display?
%   And if the display is not exactly an sRGB are we upset?
%
% See also: cameraCreate, cameraWindow, cameraSet, cameraGet
%
% Examples:
%
% To start from a scene, use
%
%   scene = sceneCreate; camera = cameraCreate;
%   camera = cameraCompute(camera,scene);
%
%  Show the result using
%     cameraWindow(camera,'ip')
%
% By default, the camera sensor is set to match the scene.  If you do not
% want that, then you can set the 4th argument (sensorResize) to false.
%
%   scene = sceneSet(scene,'fov',2); camera = cameraCreate;
%   camera = cameraCompute(camera,scene,[],false);
%   cameraWindow(camera,'ip')
%
%   scene = sceneSet(scene,'fov',20);
%   camera = cameraCompute(camera,scene,[],false);
%   cameraWindow(camera,'ip')
%
% This will create the oi, sensor and ip objects for that scene.  The
% updated objects are returned in the camera structure.
%
% Suppose you then make a change to the sensor and you would like to
% recompute.  Rather than recompute the optical image, which takes some you
% can run starting with the oi
%
%   camera = cameraCompute(camera,'oi');    % Must have computed oi attached
%   cameraWindow(camera,'ip');
%
% Finally, if you change the image processor, you can start with the sensor
%
%   camera = cameraCompute(camera,'sensor');  % Equivalent to default
%
% The default, when no second argument is specified, is to run the 'sensor'
% case
%
%   camera = cameraCompute(camera);
%
% which is equivalent to
%
%   camera = cameraCompute(camera,'sensor');
%
% -- This might go away some day ---
% If you want to scale result image to match mean value of 2nd lrgb image
%   camera = cameraCompute(camera,X,lrgbim);  %X is any of previous entries
% ----------------------------------
%
% There is a special case for computing XYZ values at the corresponding
% sensor resolution. We add a 'ideal XYZ' flag.  This uses the same general
% camera parameters but eliminates the noise and changes the sensor
% spectral QE to be xyzQuanta.  If you don't understand this, don't try it.
%
%   xyzcamera = cameraCompute(camera, scene,'ideal xyz');
%   srgb = cameraGet(xyzcamera,'ip srgb');
%   vcNewGraphWin; imagescRGB(srgb);
%
%   xyzcamera = cameraCompute(xyzcamera,'oi','ideal xyz');
%   srgb = cameraGet(xyzcamera,'ip srgb');
%   vcNewGraphWin; imagescRGB(srgb);
%
% (c) Stanford VISTA Toolbox, 2012

% This was an early design for parsing the arguments that should get
% simplified.  The problem is that pType is sometimes used to bring in the
% scene rather than to specify the processing type.  So we trap the
% different conditions in this maze of conditions.

%% By default do not scale output image
adjustScale = 0;

if ieNotDefined('camera'), error('Camera structure required.'); end
if ieNotDefined('pType'), pType = 'sensor';
elseif isstruct(pType)
    if strcmp(sceneGet(pType, 'type'), 'scene'), scene = pType;
        pType = 'scene';
    else, error('Bad input object %s\n', pType);
    end
end

if ieNotDefined('mode'), mode = 'normal'; end
if ~ischar(mode), lrgbScale = mode;
    mode = 'normal';
    adjustScale = 1;
end

if ieNotDefined('sensorResize'), sensorResize = true; end

mode  = ieParamFormat(mode);
pType = ieParamFormat(pType);

switch mode

        %% Normal camera operation (not ideal XYZ case)
    case 'normal'
        switch pType
            case 'scene'
                oi = cameraGet(camera, 'oi');
                sensor = cameraGet(camera, 'sensor');
                vci = cameraGet(camera, 'vci');

                % Warn when FOV from scene and camera don't match
                hfovScene = sceneGet(scene, 'fov horizontal');
                hfovCamera = sensorGet(sensor(1), 'fov horizontal', scene, oi);
                if sensorResize
                    vfovScene = sceneGet(scene, 'vfov');
                    vfovCamera = sensorGet(sensor(1), 'fov vertical', scene, oi);

                    if abs((hfovScene-hfovCamera)/hfovScene) > 0.01 || ...
                            abs((vfovScene-vfovCamera)/vfovScene) > 0.01

                        % More than 1% off.  A little off because of
                        % requirements for the CFA is OK.
                        % warning('ISET:Camera','Resizing sensor to match scene FOV (%.1f)',hfovScene);
                        fov = [hfovScene, vfovScene];
                        N = length(sensor);
                        for ii = 1:N
                            sensor(ii) = sensorSetSizeToFOV(sensor(ii), fov, oi);
                        end
                    end
                end

                % Compute
                oi = oiCompute(oi, scene);
                sensor = sensorCompute(sensor, oi);
                vci = ipCompute(vci, sensor);

                camera = cameraSet(camera, 'oi', oi);
                camera = cameraSet(camera, 'sensor', sensor);

            case 'oi'

                % Load camera properties
                oi = cameraGet(camera, 'oi');
                sensor = cameraGet(camera, 'sensor');
                vci = cameraGet(camera, 'ip');

                % Compute
                sensor = sensorCompute(sensor, oi);
                vci = ipCompute(vci, sensor);

                camera = cameraSet(camera, 'sensor', sensor);

            case 'sensor'

                % Load camera properties
                sensor = cameraGet(camera, 'sensor');
                % ieAddObject(sensor); sensorWindow('scale',1);
                vci = cameraGet(camera, 'vci');
                % vci = ipSet(vci,'color balance method','gray world');
                % ieAddObject(vci); ipWindow;

                % Compute
                vci = ipCompute(vci, sensor);

            otherwise
                error('Unknown pType conditions %s\n', pType);
        end

        % Adjust scale of rendered lrgb image to match mean of passed in
        % image.  Generally the rendered images need to be scaled for
        % display.  By scaling to match the mean of another image, the two
        % images will appear approximately equally bright.  This helps
        % remove the arbitrary scaling that may differ between cameras.
        if adjustScale
            lrgb = ipGet(vci, 'result');
            % Ignore pixels within 10 pixels of edges of image
            meanlrgb = mean(mean(mean(lrgb(11:end - 10, 11:end - 10, :))));
            meanlrgbScale = mean(mean(mean(lrgbScale(11:end - 10, 11:end - 10, :))));
            lrgb = lrgb * meanlrgbScale / meanlrgb;
            vci = ipSet(vci, 'result', lrgb);
        end

        % Store vci into camera
        camera = cameraSet(camera, 'vci', vci);

        if nargout > 1, img = ipGet(vci, 'result'); end

    case 'idealxyz'

        %% Use optics and sensor but compute with sensor XYZQuanta
        % The returned values are not mosaicked and there is no processing.
        % We just return the XYZ values at the same spatial/optical
        % resolution as the camera. This is useful for training and
        % testing.
        oi = cameraGet(camera, 'oi');
        sensor = cameraGet(camera, 'sensor');

        % Turn off noise, quantization, gain ...
        sensor = sensorSet(sensor, 'NoiseFlag', -1);

        % Set the field of view of the camera to match our best guess about
        % the scene.
        fovScene = oiGet(oi, 'fov') * (1 / 1.2);
        tmp = sceneCreate;
        tmp = sceneSet(tmp, 'fov', fovScene);
        fovCamera = sensorGet(sensor, 'fov', tmp, oi);
        if abs((fovScene-fovCamera)/fovScene) > 0.01
            % More than 1% off.  A little off because of
            % requirements for the CFA is OK.
            warning('ISET:Camera', 'FOV for scene %.1f and camera %.1f do not match', fovScene, fovCamera)
            end

            %
            switch pType
                case 'scene'
                    % Compute
                    oi = oiCompute(oi, scene);
                    camera = cameraSet(camera, 'oi', oi);

                case 'oi'
                    % Compute

                otherwise
                    error('Unknown pType conditions %s\n', pType);
            end

            % Load and interpolate filters
            wave = oiGet(oi, 'wave');
            transmissivities = ieReadSpectra('XYZQuanta', wave);
            sensor = sensorSet(sensor, 'wave', wave);
            img = sensorComputeFullArray(sensor, oi, transmissivities);

            %%
        otherwise
            error('Unknown mode conditions %s\n', mode);
        end

end
