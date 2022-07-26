%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function [feats, frames] = compute(obj, im)
%COMPUTE computes DSIFT features

    scale = 1;
    
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    
    sift_bin_size = obj.patch_size / 4;
    step = obj.step;
    
    frames = cell(1, obj.num_scales);
    feats = cell(1, obj.num_scales);

    % scale loop
    for i = 1:obj.num_scales
        
        % resize image
        if scale > 1            
            im_scale = imresize(im, 1 / scale);
        else
            im_scale = im;
        end
        
        % compute DSIFT at this scale
        [frames{i}, feats{i}] = vl_dsift(im_scale, 'Size', sift_bin_size, 'Step', step, 'Fast');
        frames{i} = single(frames{i});
        
        % convert frames to the original resolution
        frames{i} = frames{i} * scale;        
        frames{i}(3, :) = obj.patch_size * scale;
        
        % increase scale
        scale = scale * obj.scale_factor;
        
    end
    
    % put all frames & features together
    frames = cat(2, frames{:});
    feats = cat(2, feats{:});

    feats = single(feats);
    
    % sqrt mapping (rootSIFT)
    if obj.sqrt_map
        feats = sqrt(feats);
        
        feats_norm = sqrt(sum(feats .^ 2, 1));
        feats = bsxfun(@times, feats, 1 ./ max(feats_norm, eps));
    end
    
    % linear transform (e.g. PCA)
    if ~isempty(obj.lin_trans)
        feats = obj.lin_trans.proj * feats;
    end
    
    % augmentation
    if obj.aug_frames
        
        w = size(im, 2);
        h = size(im, 1);        
        
        % augment with (x,y)
        feats = [feats; frames(1, :) / w - 0.5; frames(2, :) / h - 0.5];
    end
    
end

