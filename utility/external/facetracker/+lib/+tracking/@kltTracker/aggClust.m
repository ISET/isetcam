function clus = aggClust(obj,C, th)
% Build clusters based on the similarity matrix C
% Clusters are merged until there is no single similarity larger than th

% Initialize clusters : assign item i to cluster i
clus = cell(size(C, 1), 1);
for i = 1:length(clus)
    C(i,i) = -inf;
    clus{i} = i;
end

tic;
while true
    if toc > 1
        fprintf('agglomclus: %d clusters\n',size(C,1));
        tic;
    end
    
    [md, mi] = max(C(:)); % pick maximum value of matrix
    if md < th % stop if max value is lower than threshold
        break
    end
    [i, j] = ind2sub(size(C), mi);
    if j < i, [i, j] = deal(j, i); end % ensure i < j
    clus{i} = [clus{i} ; clus{j}]; % merge i & j clusters into i
    clus = clus([1:j-1 j+1:end]); % remove cluster j from final list
    c = max(C(:,i), C(:,j)); % compute new similaries
    c(isinf(C(:,i))) = -inf; % remove unreachable clusters
    c(isinf(C(:,j))) = -inf; % remove unreachable clusters
    C(:,i) = c; % update similarities
    C(i,:) = c';
    C(:,j) = []; % remove cluster j from similarity matrix
    C(j,:) = [];
end
end
