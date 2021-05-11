function alpha = metricsMaskedError(imgV, E, method)
% Gateway routine for calculating the correlated part of the error
%
%   alpha = metricsMaskedError(imgV,E,[method='ls'])
%
% imgV:  An image as a vector.  This could be XYZ(:), or it could just be
%        Y(:) or it could be RGB(:), OPP(:), and so forth.
% E:     The error between this image and a distorted one, imgV + E
%
% alpha:  An estimate of how much of the error, E, should be treated as
% correlated with imgV.
%
% (c) Imageval 2011

if ieNotDefined('method'), method = 'ls'; end

% There will be various ways to calculate
method = ieParamFormat(method);
switch method
    case 'ls'
        % Least squared estimate for the whole image
        % E = alpha*imgV
        alpha = imgV(:) \ E(:);

    otherwise
        error('Unknown method: %s\n', method);
end

return
