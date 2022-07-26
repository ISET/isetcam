function show_detectionss(framesPath,framesPattern,detPath)




video = lib.data.videoFrames(framesPath,framesPattern);

facedets = [];

load(detPath)


for i=1:numel(facedets)
    frame = video.getFrame(facedets(i).frame);
    rect = facedets(i).rect;
    figure(1);
    imshow(frame)
    rectangle('position',[rect(1),rect(2),rect(3)-rect(1),rect(4)-rect(2)],'linewidth',2,'edgecolor','y');
end



end
