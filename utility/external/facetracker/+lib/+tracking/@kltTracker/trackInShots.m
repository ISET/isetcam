function [dets,nc] = trackInShots(obj,video,dets, s1, s2, klt_mask,nc)

Kf = [];
Kb = [];

fdf = [dets.frame];
for step = [1, -1]
    if step == 1
        f1 = s1;
        f2 = s2;
    else
        f1 = s2;
        f2 = s1;
    end
    
    tc = obj.tc;
    
    K   = zeros(3, tc.nfeats, max(f1, f2) - min(f1, f2) + 1, 'single');
    
    f = f1;
    
    % reading frame
    im = video.getFrame(f);

    I = single(rgb2gray(im))/255;
    
    M = obj.detsToMask(dets, f, I, klt_mask);
    
    [tc, P] = obj.kltSelFeats(tc, I, M);
    K(:, :, f - min(f1, f2) + 1) = P;
    
%     if step == 1
%         fprintf('Forward tracking of features\n');
%     else
%         fprintf('Backward tracking of features\n');
%     end
    
    
    for f = (f1 + step):step:f2
        %fprintf('\tFrame %d in [%d-%d]\r', f, f1, f2);
        
        % reading frame
        im = video.getFrame(f);
        I = single(rgb2gray(im)) / 255;
        
        M = obj.detsToMask(dets, f, I, klt_mask);
        
        [tc, P] = obj.kltTrack(tc, P, I, [],[]); % use mask here ?
        %[tc, P] = obj.kltTrack(tc, P, I, M,[]); % use mask here ?
        if f ~= f2
            [tc, P] = obj.kltSelFeats(tc, I, M, P);
        end
        K(:,:,f - min(f1, f2) + 1) = P;
    end
    fprintf('\n');
    
    if step == 1
        Kf = K;
        K = [];
    else
        K = K(:, :, end:-1:1);
        Kb = K;
        K = [];
    end
end


    [TX, TY] = obj.kltParseSparse(Kf);
    [TXb, TYb] = obj.kltParseSparse(Kb);
    TXb = TXb(end:-1:1, :);
    TYb = TYb(end:-1:1, :);
    TX = [TX TXb];
    TY = [TY TYb];
    
    FeatInBox = sparse(size(TX, 2), length(fdf));
    FeatInFrame = sparse(size(TX, 2), length(fdf));
    FeatInBox = logical(FeatInBox);
    FeatInFrame = logical(FeatInFrame);
    tic;
    %fprintf('Associating klt tracks with detections\n');
    for i = 1:length(dets)
%         if toc > 1 || i == length(dets)
%             fprintf('\tDetection %d/%d\r', i, length(fdf));
%             tic;
%         end
        fa = dets(i).frame;
        bba = dets(i).rect;
        in_box = TX(fa - s1 + 1, :) > 0 &...
            TX(fa - s1 + 1, :) >= bba(1) &...
            TX(fa - s1 + 1, :) <= bba(3) &...
            TY(fa - s1 + 1, :) >= bba(2) &...
            TY(fa - s1 + 1, :) <= bba(4);
        in_f = TX(fa - s1 + 1, :) > 0;
        FeatInFrame(:, i) = in_f';
        FeatInBox(:, i) = in_box';
    end
    %fprintf('\n');
    
    C = zeros(length(dets)); % similarity matrix
    NI = zeros(length(dets)); % number of intersecting tracks
    
%     tic;
%     fprintf('Computing klt tracks intersections\n');
    for i = 1:length(dets)
        C(i, i) = -inf;
        for j = 1:i-1
            if fdf(i) == fdf(j)
                c = -inf;
                ni = 0;
            else
                
            	ni = sum(FeatInBox(:, i) & FeatInBox(:, j));
            	nio = nnz(FeatInBox(:, i)); % points in box i
            	nis = nnz(FeatInBox(:, i) & FeatInFrame(:, j)); % survive points nio in frame j;
            	njo = nnz(FeatInBox(:, j)); % points in box j
            	njs = nnz(FeatInBox(:, j) & FeatInFrame(:, i)); % survive points of njo in frame i;           	 
           	 
            	sr1 = nis/nio; sr2 = njs/njo; % survival rate
            	if (sr1 < 0.5) && (sr2 < 0.5) 
                	c = 0;
            	else	 
                	c = full(ni / (sum((FeatInBox(:, i) & FeatInFrame(:, j)) | (FeatInBox(:, j) & FeatInFrame(:, i)))));
            	end
            end
            C(i, j) = c;
            C(j, i) = c;
            NI(i, j) = ni;
            NI(j, i) = ni;
        end
        
%         if toc > 1 || i == numel(dets)
%             fprintf('\tDetection %d/%d\r', i, numel(dets));
%             tic;
%         end
    end
    %fprintf('\n');
    
    

fdf = [dets.frame]';
FD = repmat(fdf, 1, numel(fdf)) - repmat(fdf', numel(fdf), 1);
C(~FD) = -inf;

clus = obj.aggClust(C, 0.5);
    

for i = 1:length(clus)
    nc = nc + 1;
    for j = 1:length(clus{i})
        k = clus{i}(j);
        dets(k).track = nc;
    end
end

dets = obj.updateTracksLen(dets);
dets = obj.updateTracksConf(dets);

end
