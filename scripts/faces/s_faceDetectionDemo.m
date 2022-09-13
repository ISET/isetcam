% Simple version of face detection
% Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022

% Default detector is set for faces
faceDetect = vision.CascadeObjectDetector();

% merge threshhold impacts accuracy (1 finds tons of things, 4 is default, 8 max?)
% from some simple experiments, 3 seems like a good compromise
faceDetect.MergeThreshold = 3;

% Read an image or a video frame
ourImg = imread('multiple_faces.jpg');

foundFaces = step(faceDetect, ourImg);

faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');
figure, imshow(faceOut), title('Found faces:');

% Fetch some face images using WebImageBrowser or the tool of your choice
% and put them in local/images/faces, then this will test them:
inputFiles = dir(fullfile(isetRootPath(),'local','images','faces','*.jpg'));
if numel(inputFiles) == 0
    warning('no files');
else

for ii = 1:numel(inputFiles)
    inFile = inputFiles(ii);
    ourImg = imread(fullfile(inFile.folder,inFile.name));
    foundFaces = step(faceDetect, ourImg);
    faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face');
    figure, imshow(faceOut), title('Found faces:');
    pause;
end

end
