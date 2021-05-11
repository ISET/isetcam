function [depthEdges, imageDist, oDefocus] = oiDepthEdges(oi, defocus, inFocusDepth)
% Determine depth edges to achieve defocus values
%
%  oi:       ISET optics
%  defocus:  Vector of defocus values
%  inFocusDepth:  Depth for perfect focus
%
% Example:
%    oi = oiCreate; optics = oiGet(oi,'optics');
%    f = opticsGet(optics,'focal length','m');
%    optics = opticsSet(optics,'focal length',5*f);
%
% The defocus range should always start out as negative because when the
% image plane is at the focal length infinite distance is in focus and
% everything closer has negative defocus in diopters.
%
%    defocus = -1.2:.2:0;   % Defocus when at image in focal plane
%    inFocusDepth = 5;      % Desired in focus depth (m)
%    [depthEdges, imageDist, oDefocus] = oiDepthEdges(oi,defocus,inFocusDepth)
%
% depthEdges: depths that achieve the relative defocus spacing when image
%    is in the focal plane.
% imageDist: image distance the optics to achieve a best focus at inFocusDepth
% oDefocus: the defocus at these depthEdges when the image plane is
%    imageDist.
%
% Copyright ImagEval Consultants, LLC, 2011.


optics = oiGet(oi, 'optics');
fLength = opticsGet(optics, 'focal length');
defocus(defocus >= 0) = -0.01;

% Calculate depths assuming image plane at focal length.
depthEdges = opticsDefocusDepth(defocus, optics, fLength);
[v, idx] = min(abs(inFocusDepth - depthEdges));

% If the user wants a particular image depth in focus, tell them where the
% image plane should be.
oDist = depthEdges(idx);
[tmp, imageDist] = opticsDepthDefocus(oDist, optics, fLength);

% This is the defocus for each depth when the image plane is at imageDist.
oDefocus = opticsDepthDefocus(depthEdges, optics, imageDist);

return
