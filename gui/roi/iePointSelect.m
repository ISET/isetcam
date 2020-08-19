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

if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
app = vcGetFigure(obj);

% Select points.  
app.txtMessage.Text = msg;

% Would be good to figure out which click and how to validate ...
switch class(app)
    case 'sceneWindow_App'
        pt = drawpoint(app.sceneImage);
    case 'oiWindow_App'
        pt = drawpoint(app.oiImage);
    otherwise
        error('Not yet implemented for %s\n',class(app));
end

x = round(pt.Position(2)); y = round(pt.Position(1));

app.txtMessage.Text = '';

%{
if length(x) < nPoints
    pointLoc = [];
    warning('ISET:iePointSelect1','Returning only %.0f points',length(x));
    list = (1:length(x));
elseif length(x) > (nPoints) 
    warning('ISET:iePointSelect2','Returning first of %.0f points',nPoints);
    list = (1:nPoints);
else
    list = (1:nPoints);
end
%}

pointLoc(:,1) = y;
pointLoc(:,2) = x;

end
