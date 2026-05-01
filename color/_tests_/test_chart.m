function tests = test_chart()
tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Chart validation - comments by Gemini
%
% v_icam_chart
%
% This script validates the process of defining and using chart rectangles
% across different ISETCam objects: Scene, Optical Image (OI), Sensor,
% and Image Processor (IP). It ensures that chart corner points and derived
% rectangles are correctly set, retrieved, and drawn for each object type.
% This is fundamental for analyzing targets like the Macbeth Color Checker
% within the ISETCam simulation pipeline.

%% Initialize ISETCam
ieInit; % Initializes the ISETCam environment and closes any open figures for a clean slate.

%% Scene Object Processing
%
% This section focuses on setting and verifying chart rectangles within a
% Scene object.
%
% Create a default Macbeth D65 scene. This scene contains the spectral
% radiance data of a Macbeth Color Checker illuminated by a D65 light source.
scene = sceneCreate('macbeth d65');

% The commented lines below show how to interactively get corner points
% using the scene window. For automated validation, hardcoded points are used.
% ieAddObject(scene); sceneWindow(scene); % Opens the scene window for visual inspection.
% cornerPoints = chartCornerpoints(scene,true); % Allows interactive selection of corner points.

% Hardcoded corner points for the Macbeth chart within the scene.
% These points define the four corners of the chart in pixel coordinates:
% [top-left; top-right; bottom-right; bottom-left].
cornerPoints = [1    65    % Top-left (col, row) or (x,y)
    96    64    % Top-right
    96     1    % Bottom-right
    1      1];  % Bottom-left

% Set the determined corner points into the scene object.
scene = sceneSet(scene,'corner points',cornerPoints);

% Retrieve the corner points back from the scene to verify they were set correctly.
cPoints = sceneGet(scene,'corner points');

% Assert that the retrieved corner points are identical to the ones that were set.
assert(isequal(cPoints,cornerPoints));

% The Macbeth Color Checker (MCC) is typically arranged as 4 rows x 6 columns.
% 'chartRectangles' calculates the bounding boxes for each patch based on the
% chart's corner points and dimensions. The '0.5' argument is a border percentage.
rects = chartRectangles(cornerPoints,4,6,0.5);

% Set the calculated patch rectangles into the scene object.
scene = sceneSet(scene,'chart rectangles',rects);

% Retrieve the chart rectangles back from the scene to verify.
newRects = sceneGet(scene,'chart rects');

% Assert that the retrieved rectangles are identical to the ones that were set.
assert(isequal(rects,newRects));

% Display the scene in a window and overlay the calculated chart rectangles.
%{
ieAddObject(scene);
sceneWindow(scene);
chartRectsDraw(scene,rects);
%}

%% Optical Image (OI) Object Processing
%
% This section processes the scene through optics to create an Optical Image
% and then sets/verifies chart rectangles within the OI.

% Create a default optical image (OI) object.
oi = oiCreate;

% Compute the optical image by applying the default optics to the scene.
oi = oiCompute(oi,scene);

% Crop the optical image to remove any border regions, often for cleaner analysis.
oi = oiCrop(oi,'border');

% Determine the corner points of the chart within the optical image.
% This can be done interactively (if 'true' is passed) or automatically.
cornerPoints = chartCornerpoints(oi,true);

% Calculate the patch rectangles for the OI based on its corner points,
% 4 rows, 6 columns, and 0.5 border percentage.
rects = chartRectangles(cornerPoints,4,6,0.5);

% Set the calculated patch rectangles into the optical image object.
oi = oiSet(oi,'chart rectangles',rects);

% Retrieve the chart rectangles back from the OI to verify.
newRects = oiGet(oi,'chart rects');

% Assert that the retrieved rectangles are identical to the ones that were set.
assert(isequal(rects,newRects));

% Display the optical image in a window and overlay the calculated chart rectangles.
% ieAddObject(oi); oiWindow(oi);
% chartRectsDraw(oi,rects);

%% Sensor Object Processing
%
% This section processes the optical image through a sensor to create sensor
% data, and then sets/verifies chart rectangles within the Sensor object.

% Create a default sensor object.
sensor = sensorCreate;

% Set the sensor's Field of View (FOV) to match approximately 1.3 times the
% scene's FOV, ensuring the entire chart fits within the sensor's view.
% The 'oi' object is passed to assist in FOV calculation.
sensor = sensorSet(sensor,'fov',1.3*sceneGet(scene,'fov'),oi);

% Compute the sensor response by applying the sensor's properties to the optical image.
sensor = sensorCompute(sensor,oi);

% The commented line shows how to interactively get corner points from the sensor data.
% For automated validation, hardcoded points are used.
% cornerPoints = chartCornerpoints(sensor);

% Hardcoded corner points for the chart within the sensor data.
% These points define the chart's location in sensor pixel coordinates.
cornerPoints = ...
    [38   208
    276   210
    276    50
    39    48];

% Calculate the patch rectangles for the sensor based on its corner points,
% 4 rows, 6 columns, and 0.5 border percentage.
rects = chartRectangles(cornerPoints,4,6,0.5);

% Set the calculated patch rectangles into the sensor object.
sensor = sensorSet(sensor,'chart rectangles',rects);

% Retrieve the chart rectangles back from the sensor to verify.
newRects = sensorGet(sensor,'chart rects');

% Assert that the retrieved rectangles are identical to the ones that were set.
assert(isequal(rects,newRects));

% Display the sensor data in a window and overlay the calculated chart rectangles.
% ieAddObject(sensor); sensorWindow(sensor);
% chartRectsDraw(sensor,rects);

%% Image Processor (IP) Object Processing
%
% This section processes the sensor data through an Image Processor to create
% an output image, and then sets/verifies chart rectangles within the IP object.

% Create a default image processor (IP) object.
ip = ipCreate;

% Compute the image processor output from the sensor data.
% This typically involves demosaicing, color balancing, and tone mapping.
ip = ipCompute(ip,sensor);

% The commented line shows how to interactively get corner points from the IP data.
% For automated validation, hardcoded points are used.
% ipWindow; cornerPoints = chartCornerpoints(ip);

% Hardcoded corner points for the chart within the IP data.
% These points define the chart's location in IP pixel coordinates.
cornerPoints = ...
    [39   207
    278   209
    278    50
    39    50];

% Calculate the patch rectangles for the IP based on its corner points,
% 4 rows, 6 columns, and 0.5 border percentage.
rects = chartRectangles(cornerPoints,4,6,0.5);

% Set the calculated patch rectangles into the IP object.
ip = ipSet(ip,'chart rectangles',rects);

% Retrieve the chart rectangles back from the IP to verify.
newRects = ipGet(ip,'chart rects');

% Assert that the retrieved rectangles are identical to the ones that were set.
assert(isequal(rects,newRects));

% Display the processed image in an IP window and overlay the calculated chart rectangles.
% ieAddObject(ip); ipWindow(ip);
% chartRectsDraw(ip,rects);

%% END

%{
%% Chart validation
%
%  v_chart
%
%

%%
ieInit

%%
scene = sceneCreate('macbeth d65');
% ieAddObject(scene); sceneWindow(scene);
%  cornerPoints = chartCornerpoints(scene,true);
cornerPoints = [1    65
    96    64
    96     1
    1     1];
scene = sceneSet(scene,'corner points',cornerPoints);
cPoints = sceneGet(scene,'corner points');
assert(isequal(cPoints,cornerPoints));

% The MCC is 4 x 5
rects = chartRectangles(cornerPoints,4,6,0.5);
scene = sceneSet(scene,'chart rectangles',rects);
newRects = sceneGet(scene,'chart rects');
assert(isequal(rects,newRects));

ieAddObject(scene); sceneWindow(scene); chartRectsDraw(scene,rects);

%% Now the oi
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');

cornerPoints = chartCornerpoints(oi,true);
rects = chartRectangles(cornerPoints,4,6,0.5);
oi = oiSet(oi,'chart rectangles',rects);
newRects = oiGet(oi,'chart rects');
assert(isequal(rects,newRects));
ieAddObject(oi); oiWindow(oi); chartRectsDraw(oi,rects);


%% Now the sensor

sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',1.3*sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);

% cornerPoints = chartCornerpoints(sensor);
cornerPoints = ...
    [38   208
    276   210
    276    50
    39    48];
rects = chartRectangles(cornerPoints,4,6,0.5);
sensor = sensorSet(sensor,'chart rectangles',rects);
newRects = sensorGet(sensor,'chart rects');
assert(isequal(rects,newRects));

ieAddObject(sensor); sensorWindow(sensor); chartRectsDraw(sensor,rects);

%% IP

ip = ipCreate;
ip = ipCompute(ip,sensor);

% ipWindow; cornerPoints = chartCornerpoints(ip);
cornerPoints = ...
    [39   207
   278   209
   278    50
    39    50];
rects = chartRectangles(cornerPoints,4,6,0.5);
ip = ipSet(ip,'chart rectangles',rects);
newRects = ipGet(ip,'chart rects');
assert(isequal(rects,newRects));

ieAddObject(ip); ipWindow(ip); chartRectsDraw(ip,rects);

%% END

%}




end
