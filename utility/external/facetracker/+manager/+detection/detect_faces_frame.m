function detect_faces_frame(framesPath,pattern,modelPath,outPath)

    video = lib.data.videoFrames(framesPath,pattern);
    %video.gatherinfo();
    numFrames = video.frames;
    
    fprintf('Detecting Faces\n');
    facedet = lib.facedet.dpmCascadeDetector(modelPath);
    scale = 1;
    dets = {};
    tic
    for i =1:numFrames    
%     parfor i =1:numFrames
        
        fprintf('detecting faces for frame no. %d\n',i);
        img = video.getFrame(i);
        img = imresize(img,scale);
        det = facedet.detect(img);
        dets{i} = det;
    end
    toc

    facedets = [];
    idx = 1;
    for i=1:numel(dets)
        frameDets = dets{i};
        if(~isempty(frameDets))
            for j=1:size(frameDets,2)
                frameDet = frameDets(:,j);
                facedets(idx).frame = i;
                facedets(idx).conf = frameDet(6);
                facedets(idx).rect = frameDet(1:4)./scale;
                facedets(idx).pose = frameDet(5);
                facedets(idx).track = 0;
                facedets(idx).trackconf = -inf;
                facedets(idx).tracklength = 0;
                idx = idx + 1;
            end
        end
    end
    save(outPath,'facedets');
    fprintf('Done\n');
end
