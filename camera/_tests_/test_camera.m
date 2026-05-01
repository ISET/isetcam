function tests = test_camera()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_icam_camera
%
% Tests the creation of the camera structure, ensuring it correctly
% utilizes the currently selected optical image (oi) and sensor objects
% from the ISETCam database by default. This script validates that edits
% to the core ISETCam calculations do not introduce errors in how camera
% objects are initialized and configured.

%% Initialize ISETCam
ieInit; % Initializes ISETCam environment and closes any open figures.

%% Test 'ideal' cameraCreate
%
% This section validates the default 'ideal' camera creation. An ideal
% camera typically has no noise and a single filter.
c = cameraCreate('ideal');

% Assertions to confirm the properties of the 'ideal' camera.
% An ideal sensor should have a noise flag of -1 (no noise).
assert(cameraGet(c,'sensor noise flag') == -1, 'Ideal camera sensor noise flag should be -1.');
% An ideal camera sensor typically has 1 filter.
assert(cameraGet(c,'sensor nfilters') == 1, 'Ideal camera sensor should have 1 filter.');

% Display the confirmed properties for verification.
fprintf('Ideal camera properties: Noise flag = %d, Nfilters = %d\n',...
    cameraGet(c,'sensor noise flag'), ...
    cameraGet(c,'sensor nfilters'));

%% Prepare and Add Optical Image (OI) to Environment
%
% This section creates a new optical image (OI) and modifies its optics
% before adding it to the ISETCam database. This OI should then be
% picked up by 'cameraCreate('current')'.
oi     = oiCreate; % Create a default optical image.
optics = oiGet(oi,'optics'); % Get the optics structure from the OI.
optics = opticsSet(optics,'fnumber',22); % Set the f-number of the optics to 22.
oi     = oiSet(oi,'optics',optics); % Update the OI with the modified optics.
ieAddObject(oi); % Add the modified OI to the ISETCam database, making it the 'current' OI.

%% Prepare and Add Sensor to Environment
%
% This section creates a new sensor and adds it to the ISETCam database.
% This sensor should then be picked up by 'cameraCreate('current')'.
sensor = sensorCreate('human'); % Create a 'human' sensor.
noiseFlag = sensorGet(sensor,'noise flag'); % Get the noise flag from the created sensor.
ieAddObject(sensor); % Add the sensor to the ISETCam database, making it the 'current' sensor.

%% Test 'current' cameraCreate
%
% This section validates that 'cameraCreate('current')' correctly
% incorporates the OI and sensor objects that were just added to the
% ISETCam environment.
c = cameraCreate('current'); % Create a camera using the 'current' OI and sensor from the database.

% Assertions to confirm the camera properties match the previously set OI and sensor.
% The sensor name in the camera should start with 'human'.
assert(strncmp(cameraGet(c,'sensor name'),'human',5), 'Camera sensor name does not match ''human''.');
% The optics f-number in the camera should be 22, matching our earlier setting.
assert(cameraGet(c,'optics fnumber')  == 22, 'Camera optics f-number does not match 22.');
% The sensor noise flag in the camera should match the 'human' sensor's noise flag.
assert(cameraGet(c,'sensor noise flag') == noiseFlag, 'Camera sensor noise flag does not match the set value.');
% Verify the pixel size of the sensor within the camera.
assert(isequal(cameraGet(c,'pixel size','um'),[1.5 1.5]), 'Camera pixel size does not match [1.5 1.5] um.');

%%


end
