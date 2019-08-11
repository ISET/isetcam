% This function takes the light field buffer: LF(v,u,t,s,3) and
% "unshuffles" it into a 3 channel, 2D image (what the sensor would capture
% in a light field camera).

% img should have dimensions (yRes,xRes,3)
% (s,t) is the index of the microlens (t,s in MATLAB coord)
% (u,v) is the index of the subaperture (v,u in MATLAB coord)

% U,V are the size of the microlens, i.e. the number of pixels underneath
% (typically 9x9)
% S,T are the number of microlens 


function img = LFbuffer2image(LFbuffer)

    [T,S,V,U,C] = size(LFbuffer);
    img = zeros(T*V,S*U,C);
    
    for t = 1:T
        for s = 1:S
            img((t-1)*V+1:t*V,(s-1)*U+1:s*U,:) = squeeze(LFbuffer(t,s,:,:,:));
        end
    end
end