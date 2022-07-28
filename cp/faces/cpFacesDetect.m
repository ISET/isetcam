function  [faceOut, foundFaces] = cpFacesDetect(options)
%CPFACESDETECT Summary of this function goes here
%   Detect Faces in images using Viola-Jones algorithm
%   Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022
%
% 
% Find what we are looking for
arguments
    options.file = ''; % name of an image file to open & check
    options.image = []; % image object that's already read in
    options.scene = ''; % get a flat image from a scene and evaluate it
    options.interactive = true; % whether to show results
end

% Default detector is set for faces
faceDetect = vision.CascadeObjectDetector();

% merge threshhold impacts accuracy (1 finds tons of things, 4 is default, 8 max?)
% from some simple experiments, 3 seems like a good compromise
faceDetect.MergeThreshold = 3;

% Read an image or a video frame or an ISET scene
if isfile(which(options.file))
    ourImg = imread(which(options.file));
elseif ~isempty(options.image)
    ourImg = options.image;
elseif ~isempty(options.scene)
    % get temp png file
    imgFile = [tempname() '.png'];
    sceneSaveImage(options.scene, imgFile);
    ourImg = imread(imgFile);
    delete(imgFile);
else
    error('Face Detection called with invalid input');
end

% step asks our detector to look at an image
foundFaces = step(faceDetect, ourImg);

% add a rectangle showing any found faces as a box with text
faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');

% show result directly to the user if asked
if options.interactive
    figure, imshow(faceOut), title('Found faces:');
end

end


