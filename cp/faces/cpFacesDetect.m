function  [faceOut, foundFaces] = cpFacesDetect(options)
%CPFACESDETECT Summary of this function goes here
%   Detect Faces in images using Viola-Jones algorithm
%   Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022
%
% NEXT: Add support for show/noshow of output
% 
% Find what we are looking for
arguments
    options.file = '';
    options.image = [];
    options.scene = '';
    options.interactive = true; % whether to show results
end

% Default detector is set for faces
faceDetect = vision.CascadeObjectDetector();

% merge threshhold impacts accuracy (1 finds tons of things, 4 is default, 8 max?)
% from some simple experiments, 3 seems like a good compromise
faceDetect.MergeThreshold = 3;

% Read an image or a video frame
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


foundFaces = step(faceDetect, ourImg);

faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');

% show result if asked
if options.interactive
    figure, imshow(faceOut), title('Found faces:');
end

end


