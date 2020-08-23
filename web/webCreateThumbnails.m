function webCreateThumbnails(folderPath)
% Utility script to create RGB thumbnails of HDR or other "multispectral"
% scenes (e.g. ones stored as MAT files) so we can browse them visually.
%
ourFiles = dir(fullfile(folderPath,"*.mat"));
for i = 1:length(ourFiles)
    fullPath = fullfile(ourFiles(i).folder, ourFiles(i).name);
    ourScene = sceneFromFile(fullPath, 'multispectral');
    useHDR = false; % for HDR rendering
    if useHDR
        rgbImage = sceneShowImage(ourScene, -3); % try hdr rendering
        thumbName = strrep(fullPath, ".mat", ".png");
        imwrite(rgbImage, thumbName);
    else
        thumbName = strrep(fullPath, ".mat", ".png");
        sceneSaveImage(ourScene, thumbName);
    end
end
end
