function ucData = ieUncompressData(cData,mn,mx,bitDepth)
%Invert the data compression, ieCompressData
%
%   ucData = ieUncompressData(cData,mn,mx,bitDepth)
%
%  This routine uncompresses the multispectral data stored in SCENE and
%  OPTICALIMAGE structures. The formula is:
%
%       ucData = ((mx-mn)/mxCompress)*(double(cData)) + mn
%
%  This routine, like ieCompressData, is called only through sceneGet and
%  sceneSet (or oiGet and oiSet).
%
%  The returned ucData value is always double precision unless there is a
%  memory error.  In that case, we try with single precision.
%
% Copyright ImagEval Consultants, LLC, 2005.

% warning('Deprecated.');

% if ieNotDefined('bitDepth'),error('bitDepth required'); end
mxCompress = (2^bitDepth) - 1;

if mn > mx,      error('Min/Max error.');
elseif mn == mx, s = mx;       % In this case, cData should be all zeros
else             s = (mx - mn);
end
if s > mxCompress

end

try
    % Usually we return double precision
    s  = double(s);
    mn = double(mn);

    % Compression formula is:   cData = uint(mxCompress * (data - mn)/(s));
    % Uncompression formula is the inverse
    ucData = (s/mxCompress)*double(cData) + mn;


catch
    % If we run out of memory, we return single precision and warn user.
    % Hasn't happened in a while at Stanford site.
    s  = single(s);
    mn = single(mn);

    % Compression formula is:   cData = uint(mxCompress * (data - mn)/(s));
    % Uncompression formula is the inverse
    ucData = (s/mxCompress)*single(cData) + mn;
    warning('ISET:ieUncompress','Photons: Single precision'); 
end

return;