%% v_windowPosition
%
% Check that we can position the windows reasonably
%
% See also
%   s_initWindow

%% 
ieInit

%%
scene = sceneCreate; oi = oiCreate; sensor = sensorCreate; ip = ipCreate;

oi     = oiCompute(oi,scene);
sensor = sensorCompute(sensor,oi);
ip     = ipCompute(ip,sensor);

%%
sceneWindow(scene);
oiWindow(oi);
sensorWindow(sensor);
ipWindow(ip);

%%  Get window positions and save them in pref

saveFlag = 1;
wPos = ieWindowsGet(saveFlag);

%%
% Now if you move the windows, this command will put them back to your
% preferred size and position
ieWindowsSet;

%%
