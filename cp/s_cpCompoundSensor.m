% Support for sensors with multiple pixel types / exposure times
%
% D. Cardinal, Stanford Universidy, June, 2022
%
% Initial target is Samsung Corner Pixel Automotive technology
%

ieInit();
% some timing code, just to see how fast we run...
setpref('ISET', 'benchmarkstart', cputime);
setpref('ISET', 'tStart', tic);

% cpBurstCamera is a sub-class of cpCamera that implements simple HDR and Burst
% capture and processing
ourCamera = cpBurstCamera();

% We'll use a pre-defined sensor for our Camera Module, and let it use
% default optics for now. We can then assign the module to our camera:
sensor = sensorCreate('imx363'); % pixel sensor
% Cameras can eventually have more than one module (lens + sensor)
% but for now, we just create one using our sensor
ourCamera.cmodules(1) = cpCModule('sensor', sensor);

scenePath = 'ChessSet';
sceneName = 'chessSet';
filmResolution = 360;
sceneLuminance = 500;
numRays = 64;

if false % for now... pbrtLensFile % support for pbrt lens files is hit and miss
    pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
        'resolution', [filmResolution filmResolution], ...
        'numRays', numRays, 'sceneLuminance', sceneLuminance, ...
        'lensFile','dgauss.22deg.6.0mm.json',...
        'apertureDiameter', apertureDiameter);
else
    pbrtCPScene = cpScene('pbrt', 'scenePath', scenePath, 'sceneName', sceneName, ...
        'resolution', [filmResolution filmResolution], ...
        'numRays', numRays, 'sceneLuminance', sceneLuminance);
end