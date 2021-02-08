ieInit();
filmResolution = 256;
numRays = 64;
sceneLuminance = 100;
ourCamera = cpBurstCamera();
sensor = sensorFromFile('ar0132atSensorRGB');
ourCamera.cmodules(1) = cpCModule('sensor', sensor);

% scene with no lens file (yet)
simpleScene = cpScene('pbrt', 'scenePath', 'CornellBoxReference', ...,
    'sceneName', 'CornellBoxReference', ...
    'resolution', [filmResolution filmResolution], ...
    'numRays', numRays, 'sceneLuminance', sceneLuminance);

ourCamera.cmodules(1).sensor = ...
    sensorSet(ourCamera.cmodules(1).sensor, ...
    'size', [filmResolution, filmResolution]);

cpCameraWindow(ourCamera, simpleScene);

