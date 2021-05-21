function [res,cmap] = imagescOPP(oppImg,gam,nTable,varargin)
% Display three opponent-colors images
%
% Not yet fully implemented ...
%
%   res = imagescOPP(oppImg,[gamma],[nTable],);
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
% Copyright ImagEval Consultants, LLC, 2010.

if ieNotDefined('oppImg'), error('Opponent image required.'); end
if ieNotDefined('gam'),    gam = 0.3; end
if ieNotDefined('nTable'), nTable = 256; end

res = zeros(size(oppImg));
cmap = zeros(nTable,3,3);

% Create the images and the maps Three color maps (cm) are built.  One for
% black-white (luminance), and others for red/green and blue/yellow.
cm = {'bw','rg','by'};

for ii=1:3
    % Color map with a gamma specified.
    cmap(:,:,ii) = ieCmap(cm{ii},nTable,gam);
    
    tmp = oppImg(:,:,ii);
    mx  = max(abs(tmp(:)));
    
    % The luminance image doesn't get scaled much.
    if ii==1, res(:,:,ii)  = (tmp/mx)*nTable;
    else
        % Scale the opponent images so that 0 maps to 0.5, the range is
        % between -1 and 1.
        res(:,:,ii)  = (0.5*(tmp/mx) + 0.5)*nTable;
    end
    
    vcNewGraphWin;
    image(res(:,:,ii));
    colormap(cmap(:,:,ii)); axis image; axis off; truesize
end

return
