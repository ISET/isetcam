 function detect(obj,video,outPath)
    numFrames = video.frames;
    rhists = {};
    ghists = {};
    tic
    for i=1:numFrames    
%     parfor i=1:numFrames
      if (i/500 == 0)
        fprintf('%d\n',i);
      end
      im = double(video.getFrame(i));
      [rhist, ghist] = obj.computeRGHist(im);
      rhists{i} = rhist(:);
      ghists{i} = ghist(:);
    end;
    rhists = cat(2, rhists{:});
    ghists = cat(2, ghists{:});
    rdiff = sum(abs(diff(rhists, 1, 2)), 1);
    gdiff = sum(abs(diff(ghists, 1, 2)), 1);
    totalDiff = rdiff + gdiff; % min 0, max 4
    colorThresh = 0.3; % boundary threshold
    boundary_idxs = find(totalDiff > colorThresh) + 1;
    cellSz = 20;
    hog_diff = zeros(1, length(boundary_idxs));
    for j=1:length(boundary_idxs)
        frmIdx = boundary_idxs(j);
        prevIm = double(video.getFrame(frmIdx-1));
        im = double(video.getFrame(frmIdx));
        prevImHog = obj.features(prevIm, cellSz);
        imHog = obj.features(im, cellSz);
        hog_diff(j) = mean(abs(imHog(:) - prevImHog(:)));
    end;
    
    hogThresh = 0.01; %0.08;
    boundary_idxs = boundary_idxs(hog_diff > hogThresh);
    
    boundary_idxs = boundary_idxs(find(diff(boundary_idxs)>4)+1);

    obj.startFrames = [1 boundary_idxs];
    obj.endFrames = [boundary_idxs-1 numFrames];
    toc
    
    if(~isempty(outPath))
        startFrames = obj.startFrames;
        endFrames = obj.endFrames;
        save(outPath,'startFrames','endFrames');
    end
 end
