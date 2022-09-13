 function frame = getFrame(obj,frameNum)
    frame = [];
    if(frameNum<=obj.frames)
	frame = imread(sprintf(obj.pattern,frameNum));
    end
 end
