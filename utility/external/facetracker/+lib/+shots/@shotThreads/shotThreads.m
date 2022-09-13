%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef shotThreads < handle
    
    
    properties
    end
    
    methods
        
        function obj = shotThreads()
            
        end
        
        function [threds] = process(obj,video,shots)
            nShot = size(shots.startFrames,2);
            startSifts = cell(2, nShot);
            endSifts = cell(2, nShot);
            maxDist = 10;
            for i=1:nShot
                im1 = video.getFrame(shots.startFrames(i));
                im2 = video.getFrame(shots.endFrames(i));
                im1 = single(rgb2gray(im1)) ;
                im2 = single(rgb2gray(im2)) ;
                [startSifts{1,i}, startSifts{2,i}] = vl_sift(im1);
                [endSifts{1,i}, endSifts{2,i}] = vl_sift(im2);
            end
            isMatch = zeros(nShot);
            for i=1:nShot
                for u=1:maxDist
                    j = i+u;
                    if j > nShot
                        break
                    end;
                    isMatch(i,j) = obj.isSiftMatch(endSifts(:,i), ...
                        startSifts(:,j), size(im1,1), size(im1,2));
                end;
            end;
            [IY, IX] = ind2sub([nShot, nShot], find(isMatch));
            if nShot == 1
                threads = {1};
            else
                pairs = [IY, IX; IX, IY];
                AdjM = accumarray(pairs, 1, [nShot, nShot]);
                AdjM(1:(nShot+1):end) = 1;
                % use Dulmage-Mendelsohn decomposition to find connected components
                % a good tutorial is: http://blogs.mathworks.com/steve/2007/03/20/connected-component-labeling-part-3/
                [p,~,r,~] = dmperm(AdjM);
                nCC = length(r) - 1; % number of connected components
                % sort by first appearance
                firstShot = p(r(1:nCC));
                [~, ccOrder] = sort(firstShot, 'ascend');
                threads = cell(1, nCC);
                for j=1:nCC
                    ccIdx = ccOrder(j);
                    threads{j} = p(r(ccIdx):r(ccIdx+1)-1);
                end;
            end;
        end
        
        function [isMatch, nMatch] = isSiftMatch(obj,f1d1, f2d2, imH, imW)
            nMatchThresh = 40;
            xThresh = imW/4;
            yThresh = imH/4;
            
            [matches, ~] = vl_ubcmatch(f1d1{2}, f2d2{2}) ; % matching descriptor
            
            % location of the matched points
            f1 = f1d1{1}(:, matches(1,:));
            f2 = f2d2{1}(:, matches(2,:));
            
            xDiff = f1(1,:) - f2(1,:);
            yDiff = f1(2,:) - f2(2,:);
            isGood = and(abs(xDiff) < xThresh, abs(yDiff) < yThresh);
            nMatch = sum(isGood);
            %isMatch = nMatch >= max(nMatchThresh, 0.1*min(size(f1d1{1},2), size(f2d2{1},2)));
            isMatch = nMatch >= nMatchThresh;
        end

    end
    
end


