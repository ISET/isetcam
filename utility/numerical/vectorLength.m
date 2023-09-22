function f = vectorLength(m,dim)
% Calculate vector length for matrix in specific dimension
%
%    f = vectorlength(m,dim)
%
% <m> is a matrix
% <dim> (optional) is the dimension of interest.
%   if supplied, calculate vector length of each case oriented along <dim>.
%   if [] or not supplied, calculate vector length of entire matrix
%
% Calculate vector length of <m>, either of individual cases (in which case
% the output is the same as <m> except collapsed along <dim>) or globally
% (in which case the output is a scalar).
%
% We ignore NaNs gracefully.
%
% Note weird cases:
%   vectorLength([]) is [].
%   vectorLength([NaN NaN]) is 0
%
% Example:
%   a = [1 1];
%   isequal(vectorLength(a),sqrt(2))
%   a = [1 NaN; NaN NaN];
%   isequal(vectorLength(a,1),[1 0])
%
% Taken from Kendrick Kay

% deal with NaNs
m(isnan(m)) = 0;

% handle weird case up front
if isempty(m)
    f = [];
    return;
end

% do it
if ~exist('dim','var') || isempty(dim)
    f = sqrt(dot(m(:),m(:),1));
else
    f = sqrt(dot(m,m,dim));
end

end
