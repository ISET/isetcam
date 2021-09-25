function [common, d1, d2] = ieStructCompare(s1,s2)
% Compare the values in two structs
%
% The method just calls comp_struct() without much thought.  That function
% has more arguments and we will set this up for managing that in the ISET
% way some day.  Maybe.
%
% See also
%   comp_struct

if ~isstruct(s1), error('s1 must be a struct'); end
if ~isstruct(s2), error('s2 must be a struct'); end

% External routine
[common, d1, d2] = comp_struct(s1,s2);

end

