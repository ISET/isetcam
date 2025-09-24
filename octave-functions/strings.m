function out = strings(varargin)
    %STRINGS Emulate MATLAB's strings() in Octave using cell array of char vectors
    
    dims = cell2mat(varargin);
    
    % Use cell array of empty character vectors
    out = repmat({''}, dims);
end
