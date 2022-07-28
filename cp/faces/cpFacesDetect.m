function  foundFaces = cpFacesDetect(imgFile)
%CPFACESDETECT Summary of this function goes here
%   Detect Faces in images using Viola-Jones algorithm
%   Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022

% Default detector is set for faces
faceDetect = vision.CascadeObjectDetector();

% merge threshhold impacts accuracy (1 finds tons of things, 4 is default, 8 max?)
% from some simple experiments, 3 seems like a good compromise
faceDetect.MergeThreshold = 3;

% Read an image or a video frame
ourImg = imread(imgFile);

foundFaces = step(faceDetect, ourImg);

faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');
figure, imshow(faceOut), title('Found faces:');


end


