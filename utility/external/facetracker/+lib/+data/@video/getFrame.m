 function frame = getFrame(obj,frameNum)
    frame = [];
    if(frameNum<=obj.frames)
        idx = find(obj.framesStart<=frameNum & obj.framesEnd>=frameNum);
        frameNum = frameNum-obj.framesStart(idx)+1;
        try
            frame = read(obj.files(idx).reader,frameNum);
        catch
            frame = uint8(zeros(obj.files(idx).height,obj.files(idx).width,3));
            fprintf('Error in reading frame\n');
        end
    end
 end