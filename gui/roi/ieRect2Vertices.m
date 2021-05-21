function [xv,yv] = ieRect2Vertices(rect, closeFlag)
% Convert a rect to the four vertices
%
%   [xv,yv] = ieRect2Vertices(rect, closeFlag)
%
% You can use the vertices to call inpolygon and build a mask of the
% region.  Other applications will arise.
%
% Example
%  scene = sceneCreate; ieAddObject(scene);
%  [roiLocs,rect] = vcROISelect(scene);
%  closeFlag = 0;
%  [xv,yv] = ieRect2Vertices(rect, closeFlag)
%
%  r = sceneGet(scene,'rows');
%  c = sceneGet(scene,'cols');
%  [X,Y] = meshgrid(1:c,1:r);
%  IN = inpolygon(X,Y,xv,yv);
%  vcNewGraphWin; imagesc(IN); axis image
%
% See also: t_codeROI
%
% Copyright Imageval Consulting, LLC 2013

if ieNotDefined('closeFlag'), closeFlag = 0; end

xv = [rect(1), rect(1), rect(1) + rect(3), rect(1) + rect(3)]';
yv = [rect(2), rect(2) + rect(4), rect(2) + rect(4), rect(2)]';

if closeFlag
    xv(end+1) = xv(1);
    yv(end+1) = yv(1);
end

end