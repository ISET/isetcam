function [videoFile] = sceneMakeVideo(sceneList)
%SCENEMAKEVIDEO Make a video from a cell array of scenes

% video structure with frames for creating clips
ourVideo = struct('cdata',[],'colormap',[]);

% Initialize a videowriter
videoFile = strcat("Auto-Video", "-", 'output');
v = VideoWriter(videoFile, 'MPEG-4');
v.FrameRate = 3; % 

open(v);

for ii = 1:numel(sceneList)
    % Get an image, but don't show
    im = sceneShowImage(sceneList{1,ii}, -3, 2.2);
    ourVideo(ii) = im2frame(im);

end

writeVideo(v, ourVideo);

close(v);

