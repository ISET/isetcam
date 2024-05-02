function oiPreviewVideo(inputOIPath)
%OIPREVIEWVIDEO Generate preview of OI sequence
%   can be a single .mat file or a per-frame folder

% Initially we just show it, but could add output
% for saving

%{
oiPreviewVideo('c:\iset\iset3d\local\road_020\scene_OIs.mat')
%}

oiVideo = VideoWriter('foo','MPEG-4');
oiVideo.open;

if isfile(inputOIPath) % just one array with multiple frames

    % create output name based on path

    % s.b. a parameter:(
    ourOICellArray = load(inputOIPath, 'scenesToSave');
    ourOIStruct = cell2struct(ourOICellArray);
    for ii =  1:numel(ourOICellArray.scenesToSave)
        % use a window to test
        %oiWindow(ourOICellArray.scenesToSave{ii});
        %oiVideo.writeVideo(ourOIArray);

    end
    
else
    % is a folder
end

oiVideo.close;
oiVideo.writeVideo;

% play video

end

