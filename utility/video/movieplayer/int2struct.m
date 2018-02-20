function S=int2struct(R,G,B)
%INT2STRUCT Convert intensity movie frames to a movie structure.
%   INT2STRUCT(I) converts a 3-D intensity movie array, I, into a
%   standard MATLAB movie structure.
%
%   INT2STRUCT(R,G,B) converts separate 3-D intensity movies R, G,
%   and B, representing the red, green, and blue color planes of an
%   RGB video, respectively, into a standard MATLAB movie structure.

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2004/12/17 02:43:25 $

if nargin==1,
    % Intensity input
    for j=1:size(R,3),
        S(j).cdata=R(:,:,j);
        S(j).colormap=[];
    end
else
    % RGB inputs
    error(nargchk(3,3,nargin));
    for j=1:size(R,3),
        S(j).cdata=cat(3,R(:,:,j),G(:,:,j),B(:,:,j));
        S(j).colormap=[];
    end
end
