%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef poolFVTrackJitt < handle
    
    properties        
        featextr
        encoder
        cropHeight
        cropWidth
        aspectRatio
        actualCropWidth
        actualCropHeight
        actHalfHeight
        actHalfWidth
    end
    
    methods
        
        function obj = poolFVTrackJitt(varargin)                        
            
            % DSIFT extractor
            obj.featextr = lib.facedesc.IterDSiftExtractor();
            
            % FV encoder
            obj.encoder = [];
         
            obj.cropHeight = 150;
            obj.cropWidth = 150;
            obj.actualCropHeight = obj.cropHeight;
            obj.aspectRatio = obj.cropHeight/obj.cropWidth;
            obj.actualCropWidth = round(obj.actualCropHeight/obj.aspectRatio);
            obj.actHalfHeight = floor(obj.actualCropHeight/2);
            obj.actHalfWidth = floor(obj.actualCropWidth/2);
            
        end
        
        desc = compute(obj,video, track_data, varargin)
                        
        function name = get_name(obj)
            
            name = 'poolfv';
        end
        
        function set_feat_proj(obj, lin_trans)
            obj.featextr.lin_trans = lin_trans;
        end
        
        function set_codebook(obj, codebook)
            
            % encoder
            obj.encoder = lib.facedesc.FKEncoder2(codebook);
        end
        
        function dim = get_dim(obj)            
            
            dim = obj.encoder.get_output_dim();
        end
        
    end
    
end
