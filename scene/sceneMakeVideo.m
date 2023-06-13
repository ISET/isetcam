function [videoFile] = sceneMakeVideo(sceneList)
%SCENEMAKEVIDEO Make a video from a cell array of scenes

% Initialize a videowriter
% ...
for ii = 1:numel(sceneList)
    % Get an image, but don't show
    im = sceneShowImage(sceneList{ii}, -1, 2.2);
    imFrame = im2frame(im)
    
end

