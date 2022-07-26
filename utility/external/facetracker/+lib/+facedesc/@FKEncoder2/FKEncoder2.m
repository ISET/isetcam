classdef FKEncoder2 < handle
    %FKENCODER Bag-of-word histogram computation using the FK method
    
    properties
        codebook
        cluster_norm
        global_norm
    end
    
    methods
        
        function obj = FKEncoder2(codebook)
            
            assert(all(codebook.variance(:) > 0));
            
            obj.codebook = codebook;
            
            % pre-compute data
            % inverse variance
            obj.codebook.inv_var = 1 ./ obj.codebook.variance;
            
            % inverse standard deviation
            obj.codebook.inv_std = sqrt(obj.codebook.inv_var);
            
            % sum of log-variances
            obj.codebook.log_var_sum = sum(log(obj.codebook.variance), 1);
            
            obj.cluster_norm = 'none';
            obj.global_norm = 'none';
        end
        
        function dim = get_input_dim(obj)
            
            dim = obj.codebook.n_dim;
        end
        
        function dim = get_output_dim(obj)
            
            dim = 2 * obj.codebook.n_gauss * obj.codebook.n_dim;            
        end
        
        code = encode(obj, feats, varargin)
        
        assign_idx = get_assignments(obj, feats)
    end
    
end

