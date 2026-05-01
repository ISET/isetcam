function tests = test_macbeth()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% v_icam_macbeth - Gemini comments
%
% This script specifically tests certain utility functions related to the
% **Macbeth Color Checker (MCC)** within ISETCam. Its purpose is to validate
% functions that are unique to or primarily used with Macbeth charts, rather
% than general chart utilities (which are tested in `v_chart.m`).
%
% This script focuses on:
% * `macbethIlluminant`: Estimating the scene illuminant directly from an
%     image of a Macbeth Color Checker.
% * `macbethDrawRects`: Displaying and then hiding the patch rectangles
%     on an ISETCam object window.
%
% See also:
%   `chart<TAB>` (A hint for MATLAB's tab completion to find related chart functions)

%% Initialize ISETCam
ieInit; % Initializes the ISETCam environment and closes any open figures for a clean slate.

%% Illuminant Estimation Method
%
% This section validates the `macbethIlluminant` function, which estimates
% the spectral illuminant from a scene containing a Macbeth Color Checker.

% Create a default scene object. This scene will be used as the basis
% for simulating a Macbeth chart.
scene = sceneCreate;

% Get the wavelength sampling for the scene. This is important for
% spectral calculations.
wave = sceneGet(scene,'wave');

% Set the corner points of the Macbeth chart within the scene.
% This defines the spatial extent of the chart in the image.
% The `true` argument indicates that this function might allow interactive
% selection in a UI, though typically hardcoded for validation scripts.
% The function also returns the scene object with these corner points stored.
[cornerpoints, scene] = chartCornerpoints(scene,true);

% Add the local scene to the global session so UI functions can access it
ieAddObject(scene);

%% Estimate the illuminant photons from the MCC data
%
% Call the `macbethIlluminant` function to estimate the illuminant's spectral
% power distribution (in photons) based on the Macbeth Color Checker
% within the `scene` object.
illPhotons = macbethIlluminant(scene);

%% Compare the Original and the Estimated Illuminant
%
% This section compares the estimated illuminant against the original
% illuminant present in the scene, asserting their numerical closeness.

% Retrieve the original illuminant's spectral photon data from the scene.
illOrig = sceneGet(scene,'illuminant photons');

% Open a new MATLAB graph window to visualize the comparison.
ieFigure;

% Plot the original illuminant against the estimated illuminant on a log-log scale.
% This helps visualize spectral data and potential differences across magnitudes.
loglog(illOrig,illPhotons);

% Label the axes for clarity.
xlabel('Original');
ylabel('Estimated');
grid on; % Add a grid for easier reading of the plot.

% Assert that the estimated illuminant is very close to the original.
% The condition `max(illOrig./illPhotons) - 1 < 1e-6` checks if the maximum
% relative difference between the original and estimated illuminant is
% less than a very small tolerance (1e-6), indicating high accuracy.
assert( max(illOrig./illPhotons) - 1 < 1e-6)

%% Display and Manipulate Macbeth Rectangles
%
% This section demonstrates the `macbethDrawRects` utility, which draws
% bounding boxes around the Macbeth chart patches on a displayed ISETCam object.

% Open the scene window to display the scene object.
sceneWindow(scene);

% Draw the rectangles corresponding to the Macbeth chart patches on the
% currently displayed scene window. The 'on' argument makes them visible.
macbethDrawRects(scene,'on');

% Pause execution for 1 second to allow visual inspection of the drawn rectangles.
pause(1)

% Turn off the display of the Macbeth chart rectangles.
% The 'off' argument removes the rectangles, effectively refreshing the window.
macbethDrawRects(scene,'off');

%% END

%{
%% v_icam_macbeth
%
%  Test specific chart/macbeth utilities.  The general testing of the chart
%  utilities shuld happen in v_chart.
%
% * macbethIlluminant estimates the illuminant from the image of an MCC
% * macbethDrawRects:  Show and then eliminate the rects for the patches
%
% See also
%   chart<TAB>

%%
ieInit

%% Illuminant estimate method
scene = sceneCreate;
wave = sceneGet(scene,'wave');

% The whole image is the chart.  Set the cornerpoints and store them in the
% chartP of the scene.
[cornerpoints, scene] = chartCornerpoints(scene,true);

%% Estimate the illuminant photons from the MCC data

illPhotons = macbethIlluminant(scene);

%%  Compare the original and the estimated

illOrig = sceneGet(scene,'illuminant photons');

ieFigure;
loglog(illOrig,illPhotons);
xlabel('Original'); ylabel('Estimated'); grid on
assert( max(illOrig./illPhotons) - 1 < 1e-6)

%%
sceneWindow(scene);
macbethDrawRects(scene,'on');
pause(1)
macbethDrawRects(scene,'off');  % Just a refresh.

%% END
%}
end
