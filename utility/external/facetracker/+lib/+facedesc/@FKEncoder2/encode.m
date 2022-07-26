function code = encode(obj, feats, varargin)
%ENCODE Encode features using the FK method

    prms = struct;
    prms.assign_idx = [];
    
    prms = vl_argparse(prms, varargin);
    
    if isempty(prms.assign_idx)
        % call sub-encoder to get hard/soft assignment
        assign_idx = obj.get_assignments(feats);
    else
        % assignments are pre-computed
        assign_idx = prms.assign_idx;
    end
    
    num_clusters = obj.codebook.n_gauss;
    num_feats = size(feats, 2);
    
    % TODO speed-up is possible by whitening the code rather than the features (as in Xerox's implementation and our VLAD code)
    
    % local whitening (within a cluster)
    feats = (feats - obj.codebook.mean(:, assign_idx)) .* obj.codebook.inv_std(:, assign_idx);
    
    % assignment matrix
    assign = sparse(1:num_feats, double(assign_idx), 1, num_feats, double(num_clusters));
    
    % 1st order
    code1 = single(double(feats) * assign);
    
    % 2nd order
    code2 = sqrt(0.5) * single(double(feats .^ 2 - 1) * assign);
    
    % stacking
    code = [code1, code2];
    
    % normalise
    
    switch obj.cluster_norm
        
        case 'l2'
            
            % cluster-wise L2 norm-n as in intra-VLAD
            
            cell_norm = sqrt(sum(code .^ 2, 1));
            code = bsxfun(@times, code, 1 ./ max(cell_norm, eps));
            
        case 'num_feat'
            
            % normalise by the number of features in a cluster
            
            % cluster occurence
            num_cluster_feat = single(full(sum(assign, 1)));
            norm_factor = 1 ./ max(num_cluster_feat, eps);
            
            code = bsxfun(@times, code, [norm_factor, norm_factor]);
            
    end
    
    % vectorise as in Xerox's implementation (1st order followed by 2nd order)
    code = code(:);
    
    % (re-)normalisation applied to the whole vector 
    switch obj.global_norm
        
        case 'num_feat'
            
            % original FV
            code = code * (1 / num_feats);
        
        case 'l2'
            
            code_norm = norm(code, 2);
            code = code * (1 / max(code_norm, eps));
            
        case 'helli'
            
            code = sign(code) .* sqrt(abs(code));
            code_norm = norm(code, 2);
            code = code * (1 / max(code_norm, eps));
    end

end

