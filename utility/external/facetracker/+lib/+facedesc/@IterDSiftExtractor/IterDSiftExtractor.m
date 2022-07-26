%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef IterDSiftExtractor < handle
    %IterDSiftExtractor Feature extractor using iterative dsift
    
    properties
        scale_factor        
        num_scales
        step
        patch_size
        
        % dimensionality reducing projection
        lin_trans
        
        % augment features with their spatial coordinates
        aug_frames
        
        % rootSIFT
        sqrt_map
    end
    
    methods
        function obj = IterDSiftExtractor(varargin)
            
            obj.scale_factor = 2 ^ (1/2);
            obj.num_scales = 5;
            
%            obj.step = 1;
             obj.step = 2;
            
            obj.patch_size = 24;
    
            obj.lin_trans = [];            

            obj.aug_frames = true;
            obj.sqrt_map = true;

        end
        
        % copy-constructor
        function new = copy(obj)
            new = eval(class(obj));
            
            % Copy all non-hidden properties.
            p = properties(obj);
            
            for i = 1:numel(p)
                new.(p{i}) = obj.(p{i});
            end
        end
        
        function dim = get_output_dim(obj)
            
            if isempty(obj.lin_trans)
                % SIFT w/o projection
                dim = 128;
            else
                dim = size(obj.lin_trans.proj, 1);
            end
            
            if obj.aug_frames
                % add (x,y)
                dim = dim + 2;
            end
        end
        
        [feats, frames] = compute(obj, im)
    end
    
end

