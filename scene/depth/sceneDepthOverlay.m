function h = sceneDepthOverlay(scene,n)
% Make an image of the depth map discontinuities overlaid on the image.
%
%  h = sceneDepthOverlay(scene,n)
%
% scene: Scene with a depth map
% n: Number of contours
% 
% Example:
%    scene = vcGetObject('scene'); nContours = 10;
%    h = sceneDepthOverlay(scene,nContours)
%
% Copyright ImagEval Consultants, LLC, 2011.

% TODO:  
%  Consider the gradient calculation below, as an alternative
% 
% dMap = sceneGet(scene,'depth map');
% [fx,fy] = gradient(dMap); 
% g =sqrt(fx.^2 + fy.^2); g = g/max(g(:));
% img = oiGet(oi,'rgb image');
% vcNewGraphWin;
% h = imshow(img);
% %Not sure how to set the color 
% set(h,'AlphaData',1 - g)

error('Use scenePlot, not sceneDepthOverlay');
return

%
% if ieNotDefined('scene'), scene = vcGetObject('scene'); end
% if ieNotDefined('n'), n = 5; end
% 
% d = sceneGet(scene,'depth map');
% d = ieScale(d,0,1);
% drgb = cat(3,d,d,d);
% 
% h = vcNewGraphWin; image(drgb); hold all
% v = (0:(n-1))/n;
% contour(d,v);
% 
% return


