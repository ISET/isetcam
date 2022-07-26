%  Copyright (c) 2015, Omkar M. Parkhi
%  All rights reserved.

classdef ConvNet < handle
    
    properties        
	net
    end
    
    methods
        
        function obj = ConvNet(varargin)                        
            
	    temp = load('/dev/shm/net-epoch-11-cpu.mat');
	    obj.net = vl_simplenn_move(temp.net,'cpu');
    	    obj.net.layers{end}.type = 'softmax';


            % DSIFT extractor
            
        end
        
        desc = compute(obj,video, track_data, varargin)
        desc = computeFrame(obj,faceImg, box,pts,varargin)
            
        function name = get_name(obj)
            name = 'convnet';
        end
        
        
        
        function dim = get_dim(obj)            
            dim = 4096;%obj.encoder.get_output_dim();
        end
        
    end
    
end
