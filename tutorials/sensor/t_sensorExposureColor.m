%% Over-exposure causes color errors
%
% Over-exposure produces saturation and this also produces color artifacts.
% We illustrate the effect here by making a sensor that matches the
% PowerPoint illustration in Psych 221.
%
% In this case, we arrange the color filters so that the G response is
% larger than the R and B.  We set the illuminant correction.  Then we
% allow the saturation to occur and use the same illuminant correction
% scaling.  The white patch becomes purplish, as in the teaching slide.
% 
% Copyright Imageval Consulting, LLC, 2015

%%
ieInit

%% Set up the default scene and the oi

oi = oiCreate;
scene = sceneCreate;
oi = oiCompute(oi,scene);

%% Now, to make the effect in the PowerPoint we scale the green sensitivity

% Create a sensor
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),scene,oi);

% Adjust the sensor so that G is more sensitive
f = sensorGet(sensor,'filter transmissivities');
f(:,1) = f(:,1)*.2;
f(:,3) = f(:,3)*.5;
sensor = sensorSet(sensor,'filter transmissivities',f);

% Auto exposure to get the good timing
sensor = sensorSet(sensor,'auto exposure','on');

%% Compute the sensor response

% With auto exposure, it looks good
sensor = sensorCompute(sensor,oi);
eTime = sensorGet(sensor,'exposure time');
% ieAddObject(sensor); sensorWindow('scale',true);

ip = ipCreate; 
% ip = ipSet(ip,'correction method illuminant','gray world');
ip = ipCompute(ip,sensor);
ieAddObject(ip); ipWindow;

% This is how we scale the RGB for this case.
fprintf('The transform from sensor to display RGB\n')
ipGet(ip,'Combined transform')


%% Now increase the exposure and recompute

% Fix the transform.
ip = ipSet(ip,'transform method','current');

% Increase the exposure time and recompute
% Notice that the whitest surfaces becomes purplish in this overexposed case
% The gray surfaces, which are not over exposed, are still gray.
sensor = sensorSet(sensor,'auto exposure','off');
sensor = sensorSet(sensor,'exposure time',3*eTime);
sensor = sensorCompute(sensor,oi);
ip = ipCompute(ip,sensor);
ieAddObject(ip); ipWindow;

%% 


