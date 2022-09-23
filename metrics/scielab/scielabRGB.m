function [errorImage, scene1, scene2, theDisplay] = scielabRGB(file1,file2,dispCal,vDist)
% Compute the mean spatial-CIELAB difference between two rgb images
%
%  [errorImage, scene1, scene2, theDisplay] = scielabRGB(file1,file2,dispCal,vDist)
%
% Typically, two RGB files are sent in and they are compared as if they
% were shown on a calibrated display.  It is possible to send in the file
% names or the RGB data.
%
% Instead of sending in the file names, you can also send in two ISET scene
% objects.
%
% Inputs:
%  file1, file2:  RGB file names, RGB data, ISET scene objects    (required)
%  dispCal:       Display structure ('crt.mat')
%  vDist:         Viewing distance  (0.38 meters)
%
% Returns
% errorImage - SCIELAB error between the two scenes
% sceneX     - The two scenes
% theDisplay - Display model.
%
% The images are assumed to be displayed on a calibrated display and seen
% at a specific viewing distance.
%
%
% Examples:
%   file1 = fullfile(isetRootPath, 'data','images','RGB','hats.jpg');
%   file2 = fullfile(isetRootPath, 'data','images','RGB','hatsC.jpg');
%   vDist = 0.38;               % 15 inches
%   dispCal = 'crt.mat';  % Calibrated display
%   errorImage = scielabRGB(file1, file2, dispCal, vDist)
%
%   [errorImage,s1,s2] = scielabRGB(file1, file2, dispCal, vDist);
%   ieAddObject(s1); ieAddObject(s2);sceneWindow;
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('vDist'), vDist = 0.38; end  % 15 inches
if ieNotDefined('dispCal'), dispCal = 'crt.mat'; end

meanLuminance = [];

%% Estimate the XYZ for each scene to send to scielab

if ischar(file1) || isnumeric(file1)
    % sceneFromFile takes either strings or numeric RGB data
    scene1 = sceneFromFile(file1,'rgb',meanLuminance,dispCal);
    scene1 = sceneSet(scene1,'distance',vDist);
    % ieAddObject(scene1); sceneWindow;
    
    scene2 = sceneFromFile(file2,'rgb',meanLuminance,dispCal);
    scene2 = sceneSet(scene2,'distance',vDist);
    % ieAddObject(scene2); sceneWindow;
    
    sceneXYZ1 = sceneGet(scene1,'xyz');
    sceneXYZ2 = sceneGet(scene2,'xyz');
elseif isstruct(file1) && isequal(file1.type,'scene')
    % Data are already a scene structure
    sceneXYZ1 = sceneGet(file1,'xyz');
    sceneXYZ2 = sceneGet(file1,'xyz');
end


%% Read the display white point
if ischar(dispCal)
    theDisplay = displayCreate(dispCal);
elseif isstruct(dispCal) && isequal(dispCal.type,'display')
    theDisplay = dispCal;
end
whiteXYZ = displayGet(theDisplay,'white point');

%% Determine scene FOV

% The FOV depends on the display dpi and image size
sz = sceneGet(scene1,'size');
imgWidth = sz(2)*displayGet(theDisplay,'meters per dot');  % Image width (meters)
fov = rad2deg(2*atan2(imgWidth/2,vDist));         % In deg

scene1 = sceneSet(scene1,'fov',fov);
scene2 = sceneSet(scene2,'fov',fov);

%%  Run the scielab function.

% The round is used so that the filter support and filter size match.
sampPerDeg = 1/sceneGet(scene1,'degrees per sample');
imageformat = 'xyz';

% Run S-CIELAB based on CIELAB 2000
params.deltaEversion = '2000';
params.sampPerDeg    = sampPerDeg;
params.imageFormat   = imageformat;
params.filterSize    = sampPerDeg;
params.filters = [];
params.filterversion = 'distribution';
errorImage = scielab(sceneXYZ1, sceneXYZ2, whiteXYZ, params);

end



