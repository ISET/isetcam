%% Chart validation
% 
%  v_chart
%
%

%%
ieInit

%%
scene = sceneCreate('macbeth d65');
sceneWindow(scene);
%  cornerPoints = chartCornerpoints(scene,true);
cornerPoints = [1    65
    96    64
    96     1
    1     1];
scene = sceneSet(scene,'corner points',cornerPoints);
sceneGet(scene,'corner points')
% The MCC is 4 x 5
rects = chartRectangles(cornerPoints,4,6,0.5);
scene = sceneSet(scene,'chart rectangles',rects);
sceneGet(scene,'chart rects')
tic
chartRectsDraw(scene,rects);
toc

%% Now the oi
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
oiWindow(oi);

cornerPoints = chartCornerpoints(oi,true);
rects = chartRectangles(cornerPoints,4,6,0.5);
oi = oiSet(oi,'chart rectangles',rects);
oiGet(oi,'chart rects')
tic
chartRectsDraw(oi,rects);
toc

%% Now the sensor
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',1.3*sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

% cornerPoints = chartCornerpoints(sensor);
cornerPoints = [    9   228
   309   229
   307    33
     9    31];
      
rects = chartRectangles(cornerPoints,4,6,0.5);
sensor = sensorSet(sensor,'chart rectangles',rects);
sensorGet(sensor,'chart rects')
tic
chartRectsDraw(sensor,rects);
toc

%% IP

ip = ipCreate;
ip = ipCompute(ip,sensor);

% ipWindow; cornerPoints = chartCornerpoints(ip);
cornerPoints = [9   228
   310   228
   307    31
    10    32];

rects = chartRectangles(cornerPoints,4,6,0.5);
ip = ipSet(ip,'chart rectangles',rects);
ipGet(ip,'chart rects')

%%  The uiaxes typically do not draw in this case without a pause.
%
% Worth debugging.

ipWindow(ip);
pause(2);
tic
chartRectsDraw(ip,rects);
toc

%% END





