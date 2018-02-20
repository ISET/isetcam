%% s_scielabTutorial
%
% This script is a long exploration of the S-CIELAB calculations in the
% context of ISET.  There are shorter example scripts as well that
% illustrate specific S-CIELAB properties.
%
% Read an image and process it through S-CIELAB, illustrating the
% intermediate image results.  You can also experiment to see the effects
% of changing the viewing distance (size of image in deg)
% 
% It is possible to run SCIELAB either on scene data directly (comparing
% two scenes) or on data from the image processing end of the pipeline.  In
% both cases, the data can be converted to XYZ format and thus SCIELAB
% applies.
%
% This script emphasizes the processing at the image RGB stage.  The script
% s_scielabExample emphasizes comparisons at the scene stage.
%
% See Also:  s_scielabExample
%
% Copyright ImagEval Consultants, LLC, 2010

%%
ieInit

%% Create a multispectral scene
fName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(fName,'multispectral');        
scene = sceneSet(scene,'fov',8); 
ieAddObject(scene); 
sceneWindow;

%% Optical image
oi = oiCreate;  
oi = oiCompute(scene,oi);
ieAddObject(oi); 
% oiWindow

% Sensor
sensor = sensorCreate; 
sensor = sensorSetSizeToFOV(sensor,1.1*sceneGet(scene,'fov'),scene,oi);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);
% sensorImageWindow;

% Rendered image
vci = ipCreate; 
vci = ipSet(vci,'correction method illuminant','grayworld');
vci = ipCompute(vci,sensor);
ieAddObject(vci);
ipWindow;

%% Retrieve the rendered image and start processing
srgb = ipGet(vci,'result');    % Between 0 and 1.

imgXYZ   = srgb2xyz(srgb);        % Y = imgXYZ(:,:,2); imtool(Y/max(Y(:)))
whiteXYZ = srgb2xyz(ones(1,1,3)); % max(Y(:)); whiteXYZ(2)

%% Set up scP, experiment with different samples per degree
% Changing the samplesPerDeg effectively changes the FOV
% High quality might be 250, low quality 80

% When N = 40, the image spans 6.4 degrees
% It has no real high frequency  content (beyond 20 cpd)
% So, there isn't much to blur
% When N = 250, we are simulating a 1 deg image. In that case, the image
% content has spatial frequencies up to 125 c/deg and thus the blurred
% version is very different from the original.
scP = scParams;
N = 50;                    % Try values from 20 to 200, for example
scP.sampPerDeg    = N;   
scP.filterSize    = N;
% Image size
fprintf('Image size (deg): %.3f\n',size(imgXYZ,1)/scP.sampPerDeg)

%% These are unblurred renderings of the opponent colors images
gam = 0.4;
imgOpp = imageLinearTransform(imgXYZ, colorTransformMatrix('xyz2opp', 10));
imagescOPP(imgOpp,gam);

%% Now we prepare the filters and blur them
[scP.filters, scP.support] = scPrepareFilters(scP);
[imgFilteredXYZ, imgFilteredOpp] = scOpponentFilter(imgXYZ,scP);
imagescOPP(imgFilteredOpp,gam);

%% Compare the original and spatially blurred XYZ image, back in srgb space
vcNewGraphWin; 
subplot(1,2,1), imagescRGB(xyz2srgb(imgXYZ));
subplot(1,2,2), imagescRGB(xyz2srgb(imgFilteredXYZ));

%% The effect of image size
%
% Return to the top and do this and set other N values, say between N = 20
% to N=200.  These illustrate the different amounts of blurring as the
% image is simulated from 1 deg in width to 8 deg in width
%

%%  All of these operations are part of the general SCIELAB computation

% The S-CIELAB representation can be computed this way.  Notice that there
% are nonlinear parts of the calculation so that the three images (L,A,B)
% look different from the opponent images above.  Though, the relative
% blurring is similar.
[result,whitePt] = scComputeSCIELAB(imgXYZ,whiteXYZ,scP);
imagescOPP(result, gam);

% These are in LAB space.  
% Check rg/by ordering.
% Add features to imagescOPP
 
%% 