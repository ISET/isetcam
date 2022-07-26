function faceRectsSmoothed = smoothRects(obj,faceRects)
    lambda = [1.5 1.5 4 4].^2;
    %lambda = [4 4 10 10].^2;
    faceRects(3,:) = faceRects(3,:)-faceRects(1,:);
    faceRects(4,:) = faceRects(4,:)-faceRects(2,:);
    
    
    diagEntries = 2*ones(1,size(faceRects,2)*4);
    diagEntries(1:4) = 1;
    diagEntries(end-3:end) = 1;
    diagEntries = repmat(lambda,1,numel(diagEntries)/4).*diagEntries;
    
    bandDiagEntries = -1*ones(1,(size(faceRects,2)*4)-4);
    bandDiagEntries = repmat(lambda,1,numel(bandDiagEntries)/4).*bandDiagEntries;
    
    M1 = diag(diagEntries);
    
    M2 = diag(bandDiagEntries,4);
    M3 = diag(bandDiagEntries,-4);
    
    M4 = M1 + M2 + M3;
    pts = reshape(faceRects,[],1);
    M5 = eye(size(M4,2))+M4;
    faceRectsSmoothed = reshape(M5\pts,4,[]);
    
    
end
