function assign_idx = get_assignments(obj, feats)
%GET_ASSIGNMENTS Get hard assignment of features

    assign_idx = lib.utils.dist.mah_nn_mex(feats, obj.codebook.mean, obj.codebook.inv_var, obj.codebook.log_var_sum);
end

