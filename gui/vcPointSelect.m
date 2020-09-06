function [pointLoc,pt] = vcPointSelect(obj,nPoints,msg)
% Select point locations from an ISET window. 
%
% Synopsis
%   [pointLoc, pt] = vcPointSelect(obj,[nPoints = 1],[msg])
%
% Description
%   Pick a point, used for plotting routines.
%   We need a txtMessage slot in the app for every window.
%
% Input
%   obj:      One of the ISETCam main types
%   nPoints:  How many points if more than one
%   msg:      Message for the txtMessage slot in the app
%
% Output
%  pointLoc: Returns the (x,y) = (col,row) values. During the point
%  selection process.  The upper left is (1,1).
%
% Text below Needs a re-write ... this is how it used to work.
%
%  If nPoints is not specified, then nPoints = 1 is assumed.  In that case,
%  a single right click is all that is required. 
%
%  In general, the number of points is checked and a message is printed if
%  it is incorrect.  But the pointLoc values are still returned.
%
% Example:
%   pointLoc = vcPointSelect(vcGetObject('OI'))
%   pointLocs = vcPointSelect(vcGetObject('OI'),3)
%   pointLoc = vcPointSelect(vcGetObject('sensor'),3,'Help me')
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ieROISelct
%

%%
if ieNotDefined('obj'), error('Object is required (isa,oi,scene ...)'); end
if ieNotDefined('nPoints'), nPoints = 1; end
if ieNotDefined('msg')
    msg = sprintf('Click to select point');
end

if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end

[app,appAxis] = vcGetFigure(obj);

% if isempty(app) || ~isvalid(app)
%     error('No window open f

% Select a point message.  All the apps have this slot, I think.
app.txtMessage.Text = msg;

pt = drawpoint(appAxis);
x = round(pt.Position(2)); y = round(pt.Position(1));

app.txtMessage.Text = '';

if length(x) < nPoints
    pointLoc = [];
    warning('ISET:vcPointSelect1','Returning only %.0f points',length(x));
    list = (1:length(x));
elseif length(x) > (nPoints) 
    warning('ISET:vcPointSelect2','Returning first of %.0f points',nPoints);
    list = (1:nPoints);
else
    list = (1:nPoints);
end

pointLoc(:,1) = y(list);
pointLoc(:,2) = x(list);

end
