%% Evaluate the color accuracy of a camera
%
% The camera object is a structure with slots for optics (oi)
% image sensor (sensor), and image processing pipeline (vci).  We
% frequently use the camera structure to evaluate whole system
% properties.
%
% Here, the accuracy is measured for a Macbeth Color Checker
% under D65.  Running this script requires some user-interaction.
%
% See also:  cameraColorAccuracy, macbethCompareIdeal,
%            s_metricsAcutance, macbethDrawRects,
%            imageIncreaseImageRGBSize
%
% Copyright ImagEval Consultants, LLC, 2012.

%%
ieInit

%% Initialize a camera objects.

% The camera object contains an optics structure, a sensor, and a default
% processing pipeline.  You can change the parameters of these structure.
camera = cameraCreate;
camera  = cameraSet(camera,'sensor auto exposure',1);

%% Color accuracy test

% Measure the CIELAB delta E values for rendering a Macbeth Color
% Checker under a D65 illuminant.
%
% Run the color accuracy analysis.  This creates an MCC scene,
% passes it all the way to the processed image, and then
% calculates the error plot.
[cAccuracy, camera]     = cameraColorAccuracy(camera);

%% Make visual comparisons of the rendered and target MCC
ip = cameraGet(camera,'ip'); ipWindow(ip);
macbethCompareIdeal(cameraGet(camera,'ip'));

% Print out the $\Delta E$ values
dE = reshape(cAccuracy.deltaE,4,6);
fprintf('Here are the Delta E values for each patch\n')
fprintf('-----\n')
dE
fprintf('-----\n')

%% Or make an image of the delta E values
%{
    pSize = 25;
    deimage = imageIncreaseImageRGBSize(dE,pSize);
    vcNewGraphWin; imagesc(deimage); colormap(gray(64))
    colorbar; axis image; axis off
    title('\DeltaE values')
%}

%% END



