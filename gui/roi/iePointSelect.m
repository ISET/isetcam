function [pointLoc,pt] = iePointSelect(obj,msg,nPoints)
% Select point locations from an ISET window.
%
%   [pointLoc, pt] = iePointSelect(obj,[msg],[nPoints])
%
% Input
%   obj:      An ISETCam struct (scene, oi, sensor, ip)
%   msg:      Message for the window
%   nPoints:  If you want more than one point, set this to the number
%
% Output
%  pointLoc: Returns the (x,y) = (col,row) values. During the point
%            selection process.  The upper left is (1,1).
%
% Description:
%
%
% Example:
%   pointLoc  = iePointSelect(vcGetObject('OI'))
%   pointLocs = iePointSelect(vcGetObject('OI'),3)
%   pointLoc  = iePointSelect(vcGetObject('sensor'),3,'Help me')
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ieROISelect
%

if ieNotDefined('obj'), error('Object is required (isa,oi,scene ...)'); end
if ieNotDefined('msg')
    msg = sprintf('Click to select point');
end
if ieNotDefined('nPoints'), nPoints = 1; end

% Find the app and its image axis
[app, appAxis] = ieAppGet(obj);

% Select a points
ieInWindowMessage(msg,app);

x = zeros(nPoints,1);
y = zeros(nPoints,1);

axis(appAxis);
for ii=1:nPoints
    pt = drawpoint(appAxis);
    x(ii) = round(pt.Position(1)); y(ii) = round(pt.Position(2));
end

ieInWindowMessage('',app);

pointLoc(:,1) = x(:); pointLoc(:,2) = y(:);

end
