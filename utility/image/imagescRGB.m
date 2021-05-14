function [h,rgbim] = imagescRGB(rgbim,varargin)
% Display a scaled to unit RGB image
%
%   [h, rgbimg] = imagescRGB(rgbim,row,col,[gamma])
%
%  Prior to display negative values are clipped, and the clipped data are
%  scaled to a maximum of 1.
%
%  If the exponent gamma is included, then rgbim .^ gamma are displayed;
%
%    The routine accepts data in XW and RGB format.
%    In XW format case use:                imagescRGB(img,row,col,[gamma])
%    If the data are in RGB format use:    imagescRGB(img,[gamma])
%
% Examples:
%   foo = load('trees'); [r,c] = size(foo.X);
%   for ii=1:3, rgb(:,:,ii) = reshape(foo.map(foo.X,ii),r,c); end
%
%   rgbScaled = imagescRGB(rgb);
%   rgbScaled = imagescRGB(rgb,0.3);
%
%   rgbXW = RGB2XWFormat(rgb);
%   rgbScaled = imagescRGB(rgbXW,r,c,0.3);
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
% I am concerned about the ordering of the ^gam and the scale operations.
% Perhaps scaling should be first, and then the gamma.  As things stand, we
% apply gamma and then scale. That applies here and in other routines.

%% This is a theory of display.
% I am not sure I should be clipping before scaling.  But over the years
% that has seemed better.
rgbim = ieClip(rgbim,0,[]);
s = max(rgbim(:));
if s ~= 0, rgbim = rgbim/max(rgbim(:)); end

if ismatrix(rgbim)
    
    if  nargin - 1 < 2, error('2-dimensional input requires row and col arguments.');
    else,               row = varargin{1}; col = varargin{2};
    end
    
    rgbim = XW2RGBFormat(rgbim,row,col);
    if nargin - 1 >= 3
        gam = varargin{3};
        rgbim = rgbim .^ gam;
    end
    
elseif ndims(rgbim) == 3
    % row = size(rgbim,1);
    % col = size(rgbim,2);
    if nargin - 1 >= 1
        gam = varargin{1};
        rgbim = rgbim .^ gam;
    end
else
    error('Bad image input');
end

h = imshow(rgbim);
axis image;

end
