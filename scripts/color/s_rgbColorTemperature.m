%% Estimate RGB image color temperature
%
%   * Read in an RGB image, assuming it is sRGB display ready
%   * Convert them to XYZ
%   * Calculate the mean chromaticity of the top 10 percent of the Y
%   values
%   * Calculate the chromaticity of a white surface under different
%   color temperature blackbody radiators
%   * Find a close match and return the color temperature
%
% See also
%   sceneFromFile
%

%% Create a scene with a low color temperature

scene = sceneCreate('macbeth tungsten');
oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
ip = ipCreate; ip = ipCompute(ip,sensor);
% ipWindow(ip);

rgb = ipGet(ip,'srgb');
cTemp = srgb2colortemp(rgb);

disp(cTemp)

%%  Not quite perfect for the MCC because, we think
%   the white isn't really white
%
scene = sceneCreate('macbeth d65');
oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
ip = ipCreate; ip = ipCompute(ip,sensor);
% ipWindow(ip);

rgb = ipGet(ip,'srgb');
[cTemp,cTable] = srgb2colortemp(rgb);

disp(cTemp)

disp(cTable(:,1))
disp(cTable(:,2:3))

%% END
