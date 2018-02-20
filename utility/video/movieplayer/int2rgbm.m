function S=int2rgbm(R,G,B)
%INT2RGBM Convert intensity arrays to RGB movie.
%   INT2RGBM(R,G,B) converts separate 3-D intensity movies R, G, 
%   and B, representing the red, green, and blue color planes of
%   an RGB video, respectively, into a 4-D RGB movie array.

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2004/12/17 02:43:25 $

error(nargchk(3,3,nargin));
sz=size(R);
sz=[sz(1:2) 1 sz(3)];
S = cat(3,reshape(R,sz),reshape(G,sz),reshape(B,sz));
