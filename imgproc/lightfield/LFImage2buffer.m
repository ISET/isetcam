function LFbuffer = LFImage2buffer(img,ydim,xdim)
% Shuffles 2D light field sensor image into a light field buffer
%
% Syntax:
%    LFbuffer = LFImage2buffer(img,ydim,xdim)
%
% Brief Description
%
% Inputs
%   img - dimensions (yRes,xRes,N)
%   S,T - microlens array dimensions
%
% Outputs
%    LFbuffer - LF(t,s,v,u,N) where t,s are the microlens indices and v,u
%               are the subaperture indices
%
% Wandell, modified from image2LFbuffer
%
% See also
%   external/LFtoolbox
%

% Original comments
% (s,t) is the index of the microlens (t,s in MATLAB coord)
% (u,v) is the index of the subaperture (v,u in MATLAB coord)
%
% U,V are the size of the microlens, i.e. the number of pixels underneath
% (typically 9x9)
% S,T are the number of microlens


[yRes,xRes,C] = size(img);
V = yRes/xdim;
U = xRes/ydim;

LFbuffer = zeros(xdim,ydim,V,U,C);

for kv = 1:V
    for ku = 1:U
        LFbuffer(:,:,kv,ku,:) = ...
            img(kv:V:end, ku:U:end,:);
    end
end

end