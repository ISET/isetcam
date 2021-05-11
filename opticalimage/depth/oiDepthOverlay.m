function h = oiDepthOverlay(oi, n)
% Make an image of the depth map discontinuities overlaid on the image.
%
%  h = oiDepthOverlay(oi,n)
%
% oi: OI with a depth map
% n: Number of contours
%
% Example:
%    h = oiDepthOverlay(oi,10)
%
%
%
% Copyright ImagEval Consultants, LLC, 2011.

% TODO:  Check out the gradient calculation below, as an alternative
%
% dMap = oiGet(oi,'depth map');
% [fx,fy] = gradient(dMap);
% g =sqrt(fx.^2 + fy.^2); g = g/max(g(:));
% img = oiGet(oi,'rgb image');
% vcNewGraphWin;
% h = imshow(img);
% %Not sure how to set the color
% set(h,'AlphaData',1 - g)

error('Obsolete.  Use oiPlot with depth map contour');

% if ieNotDefined('oi'), oi = vcGetObject('oi'); end
% if ieNotDefined('n'), n = 5; end
%
% d = oiGet(oi,'depth map');
% d = ieScale(d,0,1);
% drgb = cat(3,d,d,d);
%
% h = vcNewGraphWin;
% image(drgb)
% hold all
% v = (0:(n-1))/n;
% contour(d,v);

return
