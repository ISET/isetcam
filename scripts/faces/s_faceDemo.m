% Simple version of face detection
% Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022

% Default detector is set for faces
faceDetect = vision.CascadeObjectDetector();

% Read an image or a video frame
ourImg = imread('multiple_faces.jpg');

foundFaces = step(faceDetect, ourImg);

faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');
figure, imshow(faceOut), title('Found faces:');



