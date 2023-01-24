function out = rotate90(in, n)
%rotate90: 90 degree counterclockwise rotations of matrix
%
%[out] = rotate90(in, n) 
% in  = input matrix (n,m) or (n,m,k)
% n   = number of 90 degree rotation
% out = rotated matrix
%       default = 1
% Usage:
%  out = rotate90(in)
%  out = rotate90(in, n)
% Needs:
%  r90 (in this file)
%
% Author: Peter Burns
% Copyright (c) 2015 Peter D. Burns

if nargin < 2
 n = 1;
end

nd = ndims(in);

if nd < 1
 error('input to rotate90 must be a matrix');
end

for i = 1:n
 out = r90(in);
 in = out;
end

end


%%
function [out] = r90(in)

[nlin, npix, nc] = size(in);
temp = zeros (npix, nlin);
temp = 0*in(:,:,1);
cl = class(temp);
arg1=['out = ',cl,'(zeros(npix, nlin, nc));'];
eval(arg1);

for c = 1: nc;

    temp =  in(:,:,c);
    temp = temp.';
    out(:,:,c) = temp(npix:-1:1, :);
                     
end

out = squeeze(out);
end