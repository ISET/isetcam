function [im, mn, mx] = ieScale(im, b1, b2)
% Scale the value in im into a specified range
%
%   [im,mn,mx] = ieScale(im,b1,b2)
%
% Changes in syntax produce different scaling operations
%
%  im = ieScale(im)                             scale from 0 to 1
%  im = ieScale(im,b1,b2)                       scale and offset to range b1, b2
%  im = ieScale(im,maxValue)                    scale  largest value to maxValue
%
%   Scale the values in im into the specified range.  There can be one or
%   two bounds.
%   The data are scaled into the range [0,1]:   (im - min) / (max - min)
%   Then they are transformed to                (b2 - b1)*im + b1;
% Examples:
%   im = -10:50;
%   [min(im(:)),max(im(:))]
%   im = ieScale(im,20,90);
%   [min(im(:)),max(im(:))]
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('im'), error('Input data must be defined.'); end

% Find data range
mx = max(im(:));
mn = min(im(:));

% If only one bounds argument, just set peak value
if nargin == 2
    im = im * (b1 / mx);
    return;
end

% If 0 or 2 bounds arguments, we first scale data to 0,1
im = (im - mn) / (mx - mn);

if nargin == 1
    % No bounds arguments, assume 0,1
    b1 = 0;
    b2 = 1;
elseif nargin == 3
    if b1 >= b2
        error('ieScale: bad bounds values.');
    end
end

% Put the (0,1) data into the range
range = b2 - b1;
im = range * im + b1;

return;
