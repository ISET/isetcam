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
%   pointLoc = vcPointSelect(vcGetObject('OI'))
%   pointLocs = vcPointSelect(vcGetObject('OI'),3)
%   pointLoc = vcPointSelect(vcGetObject('sensor'),3,'Help me')
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

% Find the app and its main axis
[app, appAxis] = vcGetFigure(obj);

% Select a points  
ieInWindowMessage(msg,app); 

x = zeros(nPoints,1);
y = zeros(nPoints,1);

axis(appAxis);
for ii=1:nPoints
    pt = drawpoint(appAxis);
    x(ii) = round(pt.Position(2)); y(ii) = round(pt.Position(1));
end

ieInWindowMessage('',app); 

pointLoc(:,1) = y(:); pointLoc(:,2) = x(:);

end
