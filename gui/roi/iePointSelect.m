function [pointLoc,pt] = iePointSelect(obj,msg)
% Select point locations from an ISET window. 
%
%   [pointLoc, pt] = iePointSelect(obj,[msg])
%
% Input
%   obj:      An ISETCam struct (scene, oi, sensor, ip)
%   msg:      Message for the window
%
% Output
%  pointLoc: Returns the (x,y) = (col,row) values. During the point
%            selection process.  The upper left is (1,1).
%
% Description
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

% Find the app and its main axis
[app, appAxis] = vcGetFigure(obj);

% Select a points  
app.txtMessage.Text = msg;

pt = drawpoint(appAxis);
x = round(pt.Position(2)); y = round(pt.Position(1));

app.txtMessage.Text = '';

pointLoc(:,1) = y; pointLoc(:,2) = x;

end
