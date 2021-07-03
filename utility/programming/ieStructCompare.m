function [common, d1, d2] = ieStructCompare(s1,s2)
% Compare the values in two structs
%

if ~isstruct(s1), error('s1 must be a struct'); end
if ~isstruct(s2), error('s2 must be a struct'); end

% External routine
[common, d1, d2] = comp_struct(s1,s2);

end

