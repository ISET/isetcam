%% v_windowPosition
%
% Check that we can position the windows reasonably
%
% See also:  s_initWindow
%
% Imageval Consulting, LLC, 2013

%%
scene = sceneCreate;
oi = oiCreate;
sensor = sensorCreate;
ip = ipCreate;

oi = oiCompute(oi,scene);
sensor = sensorCompute(sensor,oi);
ip = ipCompute(ip,sensor);

%%
ieAddObject(scene); sceneWindow;
ieAddObject(oi);    oiWindow;
ieAddObject(sensor);sensorWindow;
ieAddObject(ip);    ipWindow;

%%  Arrange the ISET windows

scenew = ieSessionGet('scene window');
set(scenew,'position',[.1 .45 .32 .41])

oiw = ieSessionGet('oi window');
set(oiw,'position',[0.15    0.35    0.3    0.42])

sensorw = ieSessionGet('sensor window');
set(sensorw,'position',[0.2    0.25    0.35    0.38])

ipw = ieSessionGet('ip window');
set(ipw,'position',[ 0.3    0.15    0.32    0.37])


%%  Get window positions and save them in pref

saveFlag = 1;
wPos = ieWindowsGet(saveFlag);

% Now if you move the windows, this command will put them back to your
% preferred size and position
ieWindowsSet;
